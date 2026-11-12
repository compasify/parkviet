# frozen_string_literal: true

module Spree
  module Pos
    # Items a guest sent from their phone, waiting for staff. The guest never
    # writes the order itself: accepting adds the items through the table's
    # ordinary add command, rejecting keeps a reason the guest sees. Prices
    # are the server's quote when the guest sent it; the order is priced
    # again when the items are added.
    class GuestOrder < Record
      self.table_name = 'spree_pos_guest_orders'
      has_prefix_id :posguestorder

      STATUSES = %w[pending accepted rejected expired].freeze
      # Pending orders a phone may have waiting at once.
      MAX_PENDING = 3

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :guest_session, class_name: 'Spree::Pos::GuestSession'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :decided_by, class_name: staff_class_name, optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :idempotency_key, presence: true, length: { maximum: 200 }
      validates :reject_reason, length: { maximum: 200 }

      scope :pending, -> { where(status: 'pending') }

      # Pending while the table's order is still open; a pending order of a
      # closed order reads as expired until someone touches it.
      def effective_status
        return status unless status == 'pending'

        Workspace::OPEN_STATUSES.include?(workspace.operational_status) ? 'pending' : 'expired'
      end

      # What staff decide on: the table, the items with the quote and options.
      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, workspace_id: workspace.prefixed_id, resource_id: resource.prefixed_id,
          table_name: [resource.name, workspace.table_label].compact.join(' '), area_id: resource.area&.prefixed_id,
          status: effective_status, automatic: automatic, items: items.map { |row| staff_item(row) },
          quoted_total: quoted_total.to_s('F'), currency: currency, item_count: item_count,
          reject_reason: reject_reason, decided_by_id: decided_by&.prefixed_id, decided_by_name: StaffName.call(decided_by),
          decided_at: decided_at&.iso8601, created_at: created_at.iso8601 }
      end

      # What the guest's phone shows: no staff names, nothing of other phones.
      def to_guest
        { id: prefixed_id, status: effective_status, reject_reason: reject_reason,
          items: items.map { |row| row.slice('name', 'size', 'quantity', 'amount', 'note', 'outcome').merge('options' => option_names(row)) },
          quoted_total: quoted_total.to_s('F'), currency: currency, created_at: created_at.iso8601 }
      end

      private

      def staff_item(row)
        row.slice('variant_id', 'menu_item_id', 'name', 'size', 'quantity', 'unit_price', 'amount', 'note', 'outcome', 'reason').
          merge('modifiers' => Array(row['modifiers']).map { |pick| pick.slice('option_id', 'name', 'quantity') })
      end

      def option_names(row)
        Array(row['modifiers']).map { |pick| pick['quantity'].to_i > 1 ? "#{pick['name']} x#{pick['quantity']}" : pick['name'] }
      end
    end
  end
end
