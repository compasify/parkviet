# frozen_string_literal: true

module Spree
  module Pos
    # One "send to kitchen" that told the kitchen something: numbered per
    # order, made once per send key, split into one ticket per station.
    class KitchenSend < Record
      self.table_name = 'spree_pos_kitchen_sends'
      has_prefix_id :posksend

      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :staff, class_name: staff_class_name, optional: true
      belongs_to :device, class_name: 'Spree::Pos::Device', optional: true
      has_many :kitchen_tickets, -> { order(:sequence) }, class_name: 'Spree::Pos::KitchenTicket', inverse_of: :kitchen_send,
                                                          dependent: :restrict_with_error

      validates :sequence, numericality: { only_integer: true, greater_than: 0 }
      validates :send_key, presence: true, length: { maximum: 200 }

      def readonly?
        persisted? || super
      end

      def to_pos
        { id: prefixed_id, sequence: sequence, sent_at: created_at.iso8601(3), staff_id: staff&.prefixed_id,
          staff_name: KitchenSend.staff_name(staff), device_id: device&.prefixed_id }
      end

      def self.staff_name(staff)
        return nil if staff.nil?

        staff.try(:full_name).presence || staff.email.to_s.split('@').first
      end
    end
  end
end
