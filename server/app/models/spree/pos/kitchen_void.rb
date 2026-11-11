# frozen_string_literal: true

module Spree
  module Pos
    # A sent item taken back: how many, why, who did it and who approved it,
    # the void ticket the station got, and whether the kitchen had already
    # made it (`wasted`, for the waste report; nothing goes back to stock).
    class KitchenVoid < Record
      self.table_name = 'spree_pos_kitchen_voids'
      has_prefix_id :poskvoid

      # Always allowed besides the branch's list; it needs a note.
      OTHER = 'khac'
      # Set by the system when a delivery platform cancels the order.
      PLATFORM_CANCELED = 'platform_canceled'
      NOTE_MAX = 200

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine', optional: true
      belongs_to :staff, class_name: staff_class_name
      belongs_to :device, class_name: 'Spree::Pos::Device', optional: true
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true
      belongs_to :kitchen_ticket, class_name: 'Spree::Pos::KitchenTicket', optional: true

      validates :quantity, numericality: { greater_than: 0 }
      validates :name, presence: true
      validates :reason_code, presence: true, length: { maximum: 40 }
      validates :note, length: { maximum: NOTE_MAX }

      def readonly?
        persisted? || super
      end

      def to_pos
        { id: prefixed_id, sale_line_id: sale_line&.prefixed_id, name: name, quantity: quantity.to_s('F'),
          reason_code: reason_code, note: note, wasted: wasted, staff_id: staff.prefixed_id,
          staff_name: KitchenSend.staff_name(staff), approval_id: approval&.prefixed_id,
          approver_id: approval&.approver&.prefixed_id, kitchen_ticket_id: kitchen_ticket&.prefixed_id,
          voided_at: created_at.iso8601(3) }
      end
    end
  end
end
