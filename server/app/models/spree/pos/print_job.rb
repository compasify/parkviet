# frozen_string_literal: true

module Spree
  module Pos
    # One document waiting for a print station. Status changes happen in the
    # PrintJobs workflows under the printer row lock, which is what keeps jobs
    # of one printer in id order.
    class PrintJob < Record
      self.table_name = 'spree_pos_print_jobs'
      has_prefix_id :posprintjob

      KINDS = %w[receipt prebill kitchen_ticket void_ticket cup_label checklist table_qr test].freeze
      STATUSES = %w[queued claimed printed failed canceled].freeze
      MAX_ATTEMPTS = 5
      LEASE = 30.seconds
      MAX_ERROR_LENGTH = 500
      LEASE_EXPIRED = 'lease_expired'
      # Seconds to wait after the first, second, ... reported failure, long
      # enough for someone to load paper before the attempts run out.
      RETRY_DELAYS = [10, 30, 60, 120].freeze
      REPRINT_PREBILL_ACTION = 'workspace.reprint_prebill'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :printer, class_name: 'Spree::Pos::Printer'
      belongs_to :claimed_by_device, class_name: 'Spree::Pos::Device', optional: true
      belongs_to :created_by, class_name: staff_class_name, optional: true
      belongs_to :copy_of, class_name: 'Spree::Pos::PrintJob', optional: true
      belongs_to :receipt_print, class_name: 'Spree::Pos::ReceiptPrint', optional: true
      belongs_to :receipt_template, class_name: 'Spree::Pos::ReceiptTemplate', optional: true
      belongs_to :source, polymorphic: true, optional: true
      # Reprints still standing; a canceled one leaves the job reprintable.
      has_many :live_copies, -> { where.not(status: 'canceled').select(:id, :copy_of_id) }, class_name: 'Spree::Pos::PrintJob',
                                                                                            foreign_key: :copy_of_id, inverse_of: false

      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: STATUSES }
      validates :idempotency_key, presence: true, length: { maximum: 255 }
      validates :document, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      # Jobs that still hold their place in the printer's line.
      scope :pending, -> { where(status: %w[queued claimed]) }

      # A pre-bill with this content already went to a printer, or is waiting
      # to. A job that ended with no chance of paper issued nothing.
      def self.prebill_issued?(workspace, digest)
        where(kind: 'prebill', source_type: workspace.class.name, source_id: workspace.id, content_digest: digest).
          select(:id, :status, :attempts, :attempt_reports).any? { |job| !job.never_printed? }
      end

      def self.retry_delay(attempts)
        RETRY_DELAYS.fetch(attempts - 1, RETRY_DELAYS.last).seconds
      end

      def claimed?
        status == 'claimed'
      end

      def lease_expired?(now)
        claimed? && claim_expires_at <= now
      end

      def exhausted?
        attempts >= MAX_ATTEMPTS
      end

      # Back in line after a failure, but not due yet.
      def waiting?(now)
        next_attempt_at.present? && next_attempt_at > now
      end

      # Every attempt so far ended in the device saying nothing was printed. A
      # lease that ran out says nothing, so the paper may exist.
      def provably_unprinted?
        attempts == attempt_reports.size && attempt_reports.values.all? { |report| report['status'] == 'failed' }
      end

      # Finished, and certainly without paper. A job still in line may print yet.
      def never_printed?
        %w[failed canceled].include?(status) && provably_unprinted?
      end

      # The queue view: never the document, which can carry customer details.
      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, printer_id: printer.prefixed_id, printer_name: printer.name,
          kind: kind, status: status, attempts: attempts, label: label, last_error: last_error,
          copy_of_id: copy_of&.prefixed_id, created_at: created_at.iso8601, printed_at: printed_at&.iso8601,
          workspace_id: source_type == Workspace.name ? source&.prefixed_id : nil, source_revision: source_revision,
          printer_available: printer.accepting_jobs?, reprinted: live_copies.any?
        }
      end

      # What a print station prints. `attempt` must come back with the report.
      def to_claim
        { id: prefixed_id, kind: kind, attempt: attempts, claim_expires_at: claim_expires_at.iso8601,
          printer: printer.to_station, document: document }
      end

      private

      def label
        title = Array(document['header']).find { |block| block['kind'] == 'title' }
        title && (title['number'] || title['title'])
      end
    end
  end
end
