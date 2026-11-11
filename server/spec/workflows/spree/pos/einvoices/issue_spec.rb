# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_einvoice_helpers'

# Completing a sale queues its e-invoice; the outbox issues it after the sale
# committed. A provider that fails never stops the sale: the invoice waits as
# `failed` and the queue tries again with backoff until it issues.
RSpec.describe Spree::Pos::Einvoices::Issue do
  include PosEinvoiceHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { einvoice_store(credentials: { 'username' => 'shop-user', 'password' => 'S3cret-pass' }) }
  let(:branch) { credit_branch(store) }

  def failing_adapter(message: 'Gateway timeout', retryable: true)
    adapter = instance_double(Spree::Pos::Einvoices::SandboxProvider)
    allow(adapter).to receive(:issue).and_raise(Spree::Pos::Einvoices::Provider::Error.new(message, code: 'timeout', retryable: retryable))
    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).and_return(adapter)
    adapter
  end

  it 'queues the invoice with the sale and issues it through the outbox' do
    sale = completed_sale(store, branch)
    einvoice = einvoice_of(sale)
    expect(einvoice).to have_attributes(status: 'pending', invoice_type: 'cash_register', currency: 'VND')
    expect(issue_entries(einvoice).count).to eq(1)

    drain_outbox
    expect(einvoice.reload).to have_attributes(status: 'issued', provider: 'sandbox', template_code: '1', symbol: 'C26MAA',
                                               lookup_url: 'https://tracuu.example.test')
    expect(einvoice.number).to be_present
    expect(einvoice.cqt_code).to start_with('M1-')
    expect(einvoice.seller).to include('name' => 'Cửa hàng thử', 'tax_code' => '0101234567', 'outlet_code' => branch.code)
    expect(einvoice.buyer).to eq('label' => 'Bán cho người tiêu dùng')
    expect(issue_entries(einvoice).pluck(:status)).to eq(['processed'])
    expect(Spree::Pos::AuditEntry.where(action: 'einvoice.issued', subject_id: einvoice.id).count).to eq(1)
  end

  it 'completes the sale while the provider fails, then retries with backoff until it issues' do
    adapter = failing_adapter
    sale = completed_sale(store, branch)
    expect(sale.workspace.operational_status).to eq('completed')
    einvoice = einvoice_of(sale)

    now = Time.current
    drain_outbox(at: now)
    expect(einvoice.reload).to have_attributes(status: 'failed', attempts: 1)
    expect(einvoice.last_error).to eq('timeout: Gateway timeout')
    expect(einvoice.next_attempt_at).to be_within(5.seconds).of(now + 1.minute)
    expect(issue_entries(einvoice).sole).to have_attributes(status: 'pending')

    drain_outbox(at: now + 30.seconds)
    expect(einvoice.reload.attempts).to eq(1)

    drain_outbox(at: now + 61.seconds)
    expect(einvoice.reload).to have_attributes(status: 'failed', attempts: 2)
    expect(einvoice.next_attempt_at).to be_within(5.seconds).of(now + 61.seconds + 5.minutes)
    expect(Spree::Pos::AuditEntry.where(action: 'einvoice.failed', subject_id: einvoice.id).count).to eq(1)

    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).and_call_original
    drain_outbox(at: now + 7.minutes)
    expect(einvoice.reload).to have_attributes(status: 'issued', attempts: 3, last_error: nil)
    expect(adapter).to have_received(:issue).twice
  end

  it 'backs off 1, 5, 15 and 60 minutes, then every 6 hours' do
    expect((1..6).map { |attempt| described_class.backoff(attempt) }).
      to eq([1.minute, 5.minutes, 15.minutes, 1.hour, 6.hours, 6.hours])
  end

  it 'leaves a failure a person must fix to a manual retry' do
    failing_adapter(message: 'Invalid symbol', retryable: false)
    einvoice = einvoice_of(completed_sale(store, branch))
    drain_outbox

    expect(einvoice.reload).to have_attributes(status: 'failed', next_attempt_at: nil)
    expect(issue_entries(einvoice).sole.status).to eq('processed')
  end

  it 'issues once however often it is run' do
    einvoice = einvoice_of(completed_sale(store, branch))
    adapter = Spree::Pos::Einvoices::SandboxProvider.new(Spree::Pos::EinvoiceSetting.for_branch(branch))
    allow(Spree::Pos::Einvoices::SandboxProvider).to receive(:new).and_return(adapter)
    allow(adapter).to receive(:issue).and_call_original

    3.times { described_class.call(einvoice.reload) }
    Spree::Pos::Einvoices.queue!(einvoice)
    drain_outbox

    expect(adapter).to have_received(:issue).once
    expect(Spree::Pos::Einvoice.where(order_id: einvoice.order_id).count).to eq(1)
    expect(issue_entries(einvoice).pluck(:status).uniq).to eq(['processed'])
  end

  it 'never calls the adapter for an invoice another worker is issuing' do
    einvoice = einvoice_of(completed_sale(store, branch))
    einvoice.update!(status: 'issuing')
    adapter = failing_adapter

    retry_at = described_class.call(einvoice)
    expect(adapter).not_to have_received(:issue)
    expect(retry_at).to be > Time.current
    expect(einvoice.reload.status).to eq('issuing')

    # A claim older than the timeout belongs to a worker that died.
    einvoice.update_columns(updated_at: 11.minutes.ago)
    described_class.call(einvoice)
    expect(adapter).to have_received(:issue).once
  end

  it 'gives a dispatcher that loses the claim nothing to do' do
    einvoice = einvoice_of(completed_sale(store, branch))
    entry = issue_entries(einvoice).sole
    entry.update!(status: 'processing', available_at: 10.minutes.from_now)
    adapter = failing_adapter

    Spree::Pos::DispatchOutboxJob.perform_now
    expect(adapter).not_to have_received(:issue)
    expect(entry.reload.status).to eq('processing')
  end

  it 'keeps credentials out of the stored error and the log' do
    failing_adapter(message: 'Login failed for shop-user with S3cret-pass')
    einvoice = einvoice_of(completed_sale(store, branch))
    drain_outbox

    expect(einvoice.reload.last_error).to eq('timeout: Login failed for [FILTERED] with [FILTERED]')
    expect(einvoice.to_pos.to_json).not_to include('S3cret-pass')
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    expect(filter.filter('credentials' => { 'password' => 'S3cret-pass' })).to eq('credentials' => '[FILTERED]')
  end

  it 'fails without settings and issues once a provider is chosen' do
    Spree::Pos::EinvoiceSetting.where(store_id: store.id).update_all(status: 'disabled')
    einvoice = einvoice_of(completed_sale(store, branch))
    drain_outbox
    expect(einvoice.reload).to have_attributes(status: 'failed')
    expect(einvoice.last_error).to start_with('einvoice_not_configured')

    Spree::Pos::EinvoiceSetting.where(store_id: store.id).update_all(status: 'active')
    drain_outbox(at: 2.minutes.from_now)
    expect(einvoice.reload.status).to eq('issued')
  end

  it 'queues nothing for a store that issues no e-invoice' do
    plain = einvoice_store(type: 'none')
    sale = completed_sale(plain, credit_branch(plain))

    expect(Spree::Pos::Einvoice.where(workspace_id: sale.workspace.id)).to be_empty
    expect(Spree::Pos::OutboxEntry.where(event_type: 'einvoice.issue', store_id: plain.id)).to be_empty
  end

  it 'carries the buyer the cashier entered and refuses a malformed one before selling' do
    buyer = { tax_code: '0312345678', name: 'Công ty TNHH ABC', address: '2 Hai Bà Trưng, Quận 1', email: 'ketoan@abc.vn' }
    einvoice = einvoice_of(completed_sale(store, branch, einvoice_buyer: buyer))
    drain_outbox
    expect(einvoice.reload.buyer).to eq(buyer.transform_keys(&:to_s))

    sale = credit_sale(store, branch, price: 10_000)
    take_tender(sale, 'cash', 10_000)
    expect { Spree::Pos::Workspaces::Complete.call(**editing_args(sale), einvoice_buyer: { tax_code: '0312345678' }) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('einvoice_buyer_invalid') }
    expect(sale.workspace.reload.operational_status).not_to eq('completed')
  end

  it 'waits for buyer details from the bill QR before issuing, never past the calendar day' do
    allow(Spree::Pos::Einvoices::BuyerLink).to receive(:base_url).and_return('https://pos.example.test')
    now = Time.zone.parse('2026-11-11 03:00:00 UTC')
    einvoice = travel_to(now) { einvoice_of(completed_sale(store, branch)) }
    expect(issue_entries(einvoice).sole.available_at).to be_within(1.second).of(now + 10.minutes)

    late = Time.zone.parse('2026-11-11 16:55:00 UTC') # 23:55 in Ho Chi Minh City
    other = travel_to(late) { einvoice_of(completed_sale(store, branch)) }
    expect(issue_entries(other).sole.available_at).to be_within(1.second).of(Time.zone.parse('2026-11-11 16:58:59 UTC'))
  end
end
