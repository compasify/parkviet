# frozen_string_literal: true

module Spree
  module Pos
    # A cash sale a counter made while the server was out of reach, replayed
    # once it came back (OfflineSales::Ingest). `payload` keeps what the
    # counter recorded (lines, prices it showed, cash handed), never a token.
    # The server prices it again: a sale whose total, items or shift no
    # longer fit waits in `needs_review` until a cashier completes it
    # (Resolve) or a manager rejects it (Reject).
    class OfflineSale < Record
      self.table_name = 'spree_pos_offline_sales'
      has_prefix_id :posoffline

      STATUSES = %w[completed needs_review rejected].freeze
      REASONS = %w[price_changed item_unavailable item_sold_out shift_closed shift_mismatch sale_refused].freeze
      RESOLUTIONS = %w[accept_collected current_price edited rejected].freeze
      # A counter clock this far from the server's at sync is flagged.
      CLOCK_TOLERANCE = 10.minutes

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register'
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :staff, class_name: staff_class_name
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :resolved_by, class_name: staff_class_name, optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :review_reason, inclusion: { in: REASONS }, allow_nil: true
      validates :resolution, inclusion: { in: RESOLUTIONS }, allow_nil: true

      scope :needs_review, -> { where(status: 'needs_review') }

      def lines
        Array(payload['lines'])
      end

      def to_pos
        order = workspace&.order
        {
          id: prefixed_id, offline_id: offline_id, provisional_number: provisional_number, status: status,
          branch_id: branch.prefixed_id, register_id: register.prefixed_id, shift_id: shift.prefixed_id,
          staff: { id: staff.prefixed_id, name: StaffName.call(staff) },
          client_sold_at: client_sold_at.iso8601, clock_check: clock_check, clock_skew_seconds: clock_skew_seconds,
          collected_total: collected_total.to_s('F'), handed_amount: handed_amount.to_s('F'), currency: currency,
          lines: lines.map { |row| row.slice('variant_id', 'name', 'quantity', 'unit_price', 'modifiers', 'note') },
          review_reason: review_reason, review_details: review_details,
          workspace_id: workspace&.prefixed_id, order_number: order&.number,
          call_number: workspace&.order_number, current_total: order && order.total.to_s('F'),
          resolution: resolution, resolution_note: resolution_note, resolved_at: resolved_at&.iso8601,
          resolved_by: resolved_by && { id: resolved_by.prefixed_id, name: StaffName.call(resolved_by) },
          created_at: created_at.iso8601
        }
      end
    end
  end
end
