# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_credit_helpers'
require_relative '../../../../support/pos_race_helpers'

RSpec.describe 'POS print queue workflows' do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:device) { station(branch) }
  let(:printer) { station_printer(device) }
  let(:document) { { 'version' => 1, 'kind' => 'test', 'header' => [] } }

  def station(at, mode: 'print_station')
    Spree::Pos::Device.create!(store: at.store, branch: at, name: 'Máy in', mode: mode, platform: 'android',
                               token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
  end

  def station_printer(owner, name: 'Quầy')
    Spree::Pos::Printer.create!(store: owner.store, branch: owner.branch, name: name, connection: 'sunmi_builtin', paper: '58mm',
                                command_language: 'escpos', roles: [], print_station_device: owner)
  end

  def enqueue(on: printer, key: SecureRandom.uuid)
    Spree::Pos::PrintJobs::Enqueue.call(store: store, printer: on, kind: 'test', document: document, key: key)
  end

  def claim(by = device)
    Spree::Pos::PrintJobs::Claim.call(device: by)
  end

  def report(job, attempt, status, by: device, error: nil)
    Spree::Pos::PrintJobs::Report.call(device: by, job_id: job.prefixed_id, attempt: attempt, status: status, error: error)
  end

  def lapse(job)
    job.update!(claim_expires_at: 1.minute.ago)
  end

  # The retry delay has passed.
  def due(job)
    job.update!(next_attempt_at: 1.second.ago)
  end

  def conflict_reason
    yield
    nil
  rescue Spree::Pos::Conflict => e
    e.reason
  end

  describe 'ordering' do
    it 'hands out one printer\'s jobs in id order' do
      first = enqueue
      second = enqueue

      expect(claim).to eq(first)
      report(first, 1, 'printed')
      expect(claim).to eq(second)
    end

    it 'holds a later job back while an earlier one has a live lease' do
      first = enqueue
      enqueue

      expect(claim).to eq(first)
      expect(claim).to be_nil
    end

    it 'does not let a failed or canceled job block later ones' do
      failed = enqueue
      canceled = enqueue
      later = enqueue
      failed.update!(status: 'failed', attempts: 5)
      canceled.update!(status: 'canceled')

      expect(claim).to eq(later)
    end

    it 'takes an expired earlier claim back and gives it out first' do
      first = enqueue
      enqueue
      claim
      lapse(first)

      claimed = claim
      expect(claimed).to eq(first)
      expect(claimed.attempts).to eq(2)
    end

    it 'gives another printer of the station its own line' do
      other = station_printer(device, name: 'Bếp')
      first = enqueue
      elsewhere = enqueue(on: other)

      expect([claim, claim]).to contain_exactly(first, elsewhere)
    end
  end

  describe 'claim scope' do
    it 'never gives a device another station\'s job' do
      enqueue
      expect(claim(station(branch))).to be_nil
    end

    it 'skips a disabled printer' do
      enqueue
      printer.update!(status: 'disabled')
      expect(claim).to be_nil
    end
  end

  describe 'report' do
    it 'records a printed attempt' do
      job = enqueue
      claim
      expect(report(job, 1, 'printed').status).to eq('printed')
      expect(job.reload.printed_at).to be_present
    end

    it 'is idempotent for a repeated identical report and publishes once' do
      job = enqueue
      claim
      report(job, 1, 'printed')

      expect(Spree::Pos::Realtime).not_to receive(:publish)
      expect(report(job, 1, 'printed').status).to eq('printed')
    end

    it 'refuses a different answer for an attempt already reported' do
      job = enqueue
      claim
      report(job, 1, 'printed')
      expect(conflict_reason { report(job, 1, 'failed') }).to eq('print_report_mismatch')
    end

    it 'accepts a printed report after the lease lapsed if nothing claimed it again' do
      job = enqueue
      claim
      lapse(job)
      Spree::Pos::PrintJobs::Release.call(printer_id: printer.id)
      expect(job.reload.status).to eq('queued')

      report(job, 1, 'printed')
      expect(job.reload.status).to eq('printed')
      expect(claim).to be_nil
    end

    it 'refuses a late report once the job was claimed again and leaves the new attempt alone' do
      job = enqueue
      claim
      lapse(job)
      claim

      expect(conflict_reason { report(job, 1, 'printed') }).to eq('print_claim_stale')
      job.reload
      expect([job.status, job.attempts, job.printed_at]).to eq(['claimed', 2, nil])
    end

    it 'refuses a device that does not hold the claim' do
      job = enqueue
      claim
      other = station(branch)
      printer.update!(print_station_device: other)

      expect(conflict_reason { report(job, 1, 'printed', by: other) }).to eq('print_claim_stale')
    end

    it 'hides a job from a device with no tie to it' do
      job = enqueue
      claim
      expect { report(job, 1, 'printed', by: station(branch)) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'hides another branch\'s job' do
      job = enqueue
      claim
      expect { report(job, 1, 'printed', by: station(credit_branch(store))) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'requeues a failure and keeps its reason, truncated' do
      job = enqueue
      claim
      report(job, 1, 'failed', error: 'x' * 900)

      job.reload
      expect(job.status).to eq('queued')
      expect(job.last_error.length).to eq(Spree::Pos::PrintJob::MAX_ERROR_LENGTH)
    end

    it 'fails the job with an event on the fifth failed attempt' do
      job = enqueue
      4.times do |index|
        claim
        report(job, index + 1, 'failed')
        due(job)
      end
      claim

      expect(Spree::Pos::Realtime).to receive(:publish).with(branch, 'print_job.created', id: job.prefixed_id, refs: { printer_id: printer.prefixed_id })
      report(job, 5, 'failed')
      expect(job.reload.status).to eq('failed')
      expect(claim).to be_nil
    end
  end

  describe 'retry delay' do
    it 'waits before handing a failed job out again' do
      job = enqueue
      claim
      report(job, 1, 'failed', error: 'paper_out')

      expect(job.reload.next_attempt_at).to be > Time.current
      expect(claim).to be_nil
      expect(job.reload.attempts).to eq(1)
    end

    it 'keeps later jobs behind a job waiting out its delay' do
      first = enqueue
      enqueue
      claim
      report(first, 1, 'failed')

      expect(claim).to be_nil
    end

    it 'hands the job out again once the delay passed, and clears it' do
      job = enqueue
      claim
      report(job, 1, 'failed')
      due(job)

      expect(claim).to eq(job)
      expect(job.reload.next_attempt_at).to be_nil
    end

    it 'waits longer after each failure' do
      delays = (1..4).map { |attempts| Spree::Pos::PrintJob.retry_delay(attempts) }
      expect(delays).to eq(delays.sort.uniq)
      expect(delays.sum).to be >= 3.minutes
    end

    it 'sets no delay on a job that has run out of attempts' do
      job = enqueue
      claim
      job.update!(attempts: 5)
      report(job, 5, 'failed')

      expect(job.reload).to have_attributes(status: 'failed', next_attempt_at: nil)
    end
  end

  describe 'lease expiry' do
    it 'returns the job to the queue with an event' do
      job = enqueue
      claim
      lapse(job)

      expect(Spree::Pos::Realtime).to receive(:publish).with(branch, 'print_job.created', id: job.prefixed_id, refs: { printer_id: printer.prefixed_id })
      Spree::Pos::ReleasePrintClaimsJob.perform_now
      expect(job.reload).to have_attributes(status: 'queued', claim_expires_at: nil, last_error: 'lease_expired')
    end

    it 'leaves a live lease alone' do
      job = enqueue
      claim
      Spree::Pos::ReleasePrintClaimsJob.perform_now
      expect(job.reload.status).to eq('claimed')
    end

    it 'fails the job with an event when the fifth attempt expires' do
      job = enqueue
      claim
      job.update!(attempts: 5)
      lapse(job)

      expect(Spree::Pos::Realtime).to receive(:publish).with(branch, 'print_job.created', id: job.prefixed_id, refs: { printer_id: printer.prefixed_id })
      Spree::Pos::ReleasePrintClaimsJob.perform_now
      expect(job.reload.status).to eq('failed')
    end

    it 'is registered to run on a schedule' do
      schedule = YAML.safe_load_file(Rails.root.join('config/recurring.yml'), aliases: true)
      classes = schedule.values.flat_map { |env| env.is_a?(Hash) ? env.values : [] }.grep(Hash).filter_map { |task| task['class'] }
      expect(classes).to include('Spree::Pos::ReleasePrintClaimsJob')
    end
  end

  describe 'enqueue' do
    it 'returns the same job for a repeated key and publishes once' do
      key = SecureRandom.uuid
      job = enqueue(key: key)

      expect(Spree::Pos::Realtime).not_to receive(:publish)
      expect(enqueue(key: key)).to eq(job)
    end

    it 'refuses a disabled printer' do
      printer.update!(status: 'disabled')
      expect(conflict_reason { enqueue }).to eq('printer_disabled')
    end

    it 'refuses a printer the browser drives' do
      browser = Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Trình duyệt', connection: 'browser', paper: '80mm',
                                            command_language: 'escpos', roles: [])
      expect(conflict_reason { enqueue(on: browser) }).to eq('printer_not_queued')
    end

    it 'refuses a printer whose station was revoked' do
      printer
      device.update_columns(status: 'revoked')
      expect(conflict_reason { enqueue(on: printer.reload) }).to eq('printer_station_unavailable')
    end

    it 'keeps a printer with jobs from being deleted' do
      enqueue
      expect(printer.destroy).to be(false)
      expect { Spree::Pos::Printer.transaction(requires_new: true) { printer.delete } }.to raise_error(ActiveRecord::StatementInvalid, /RestrictViolation/)
    end
  end
end

RSpec.describe 'POS print queue races' do
  include PosCreditHelpers
  include_context 'with committed POS race rows'

  let(:branch) { credit_branch(store) }

  def committed_station
    device = Spree::Pos::Device.create!(store: store, branch: branch, name: 'Máy in', mode: 'print_station', platform: 'android',
                                        token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
    printer = Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Quầy', connection: 'sunmi_builtin', paper: '58mm',
                                          command_language: 'escpos', roles: [], print_station_device: device)
    [device, printer]
  end

  def queue(printer, key = SecureRandom.uuid)
    Spree::Pos::PrintJobs::Enqueue.call(store: store, printer: printer, kind: 'test', document: { 'version' => 1 }, key: key)
  end

  it 'hands a job to exactly one of two concurrent claims' do
    device, printer = committed_station
    job = queue(printer)
    results = Array.new(2)
    threads = 2.times.map do |index|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection { results[index] = Spree::Pos::PrintJobs::Claim.call(device: device) }
      end
    end
    threads.each { |thread| thread.join(20) }

    expect(results.compact).to eq([job])
    expect(job.reload.attempts).to eq(1)
  end

  it 'skips a printer another transaction holds rather than reaching past its first job' do
    device, printer = committed_station
    queue(printer)
    queue(printer)
    claimed = :unset

    printer.with_lock do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection { claimed = Spree::Pos::PrintJobs::Claim.call(device: device) }
      end.join(20)
    end

    expect(claimed).to be_nil
    expect(Spree::Pos::PrintJob.where(printer: printer, status: 'claimed')).to be_empty
  end

  it 'creates one job for two concurrent enqueues of a key and publishes once' do
    _device, printer = committed_station
    key = SecureRandom.uuid
    allow(Spree::Pos::Realtime).to receive(:publish).and_call_original

    outcomes = race(printer) { queue(Spree::Pos::Printer.find(printer.id), key).id }

    expect(outcomes.map(&:first)).to eq(%i[success success])
    expect(outcomes.map(&:last).uniq.size).to eq(1)
    expect(Spree::Pos::PrintJob.where(idempotency_key: key).count).to eq(1)
    expect(Spree::Pos::Realtime).to have_received(:publish).once
  end

  it 'answers a lost insert race with the winning job' do
    _device, printer = committed_station
    key = SecureRandom.uuid
    job = queue(printer, key)
    allow(Spree::Pos::PrintJob).to receive(:find_by).and_return(nil, job)
    allow(Spree::Pos::PrintJob).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)

    expect(queue(printer, key)).to eq(job)
  end
end
