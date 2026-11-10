# frozen_string_literal: true

require Rails.root.join('db/migrate/20261110140100_add_service_mode_and_business_date_to_pos_workspaces')
require_relative '../support/pos_credit_helpers'

# A sale created at 01:30 Vietnam time belongs to the previous business day.
RSpec.describe AddServiceModeAndBusinessDateToPosWorkspaces, type: :model do
  include PosCreditHelpers
  include ActiveSupport::Testing::TimeHelpers

  it 'backfills 01:30 Vietnam time onto the previous date' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    branch = credit_branch(store)
    sale = credit_sale(store, branch, price: 10_000)
    workspace = sale.workspace
    workspace.update_columns(created_at: Time.utc(2026, 11, 5, 18, 30), business_date: Date.new(2026, 11, 6))

    described_class.backfill!

    expect(workspace.reload.business_date).to eq(Date.new(2026, 11, 5))
  end

  it 'stamps a new draft from the server clock and does not recompute it' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    branch = credit_branch(store)
    zone = ActiveSupport::TimeZone['Asia/Ho_Chi_Minh']
    sale = travel_to(zone.local(2026, 11, 6, 1, 30)) { credit_sale(store, branch, price: 10_000) }
    expect(sale.workspace.business_date).to eq(Date.new(2026, 11, 5))

    sale.workspace.update_columns(created_at: zone.local(2026, 11, 6, 12, 0))
    sale.workspace.valid?
    expect(sale.workspace.business_date).to eq(Date.new(2026, 11, 5))
  end
end
