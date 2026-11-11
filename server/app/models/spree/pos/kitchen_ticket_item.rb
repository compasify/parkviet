# frozen_string_literal: true

module Spree
  module Pos
    # One line of a kitchen ticket: what to make, copied when it was sent, and
    # how far the kitchen has got with it. Only the status and its times move.
    class KitchenTicketItem < Record
      self.table_name = 'spree_pos_kitchen_ticket_items'
      has_prefix_id :poskitem

      STATUSES = %w[new preparing ready served voided].freeze
      OPEN = %w[new preparing].freeze
      DONE = %w[ready served voided].freeze
      CONTENT = %w[kitchen_ticket_id sale_line_id name modifiers components note quantity].freeze

      belongs_to :kitchen_ticket, class_name: 'Spree::Pos::KitchenTicket', inverse_of: :items
      # Gone once the line was voided to nothing; the ticket keeps what it said.
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine', optional: true
      belongs_to :changed_by, polymorphic: true, optional: true

      validates :name, presence: true
      validates :status, inclusion: { in: STATUSES }
      validates :quantity, numericality: { greater_than: 0 }
      validate :content_fixed, on: :update

      def to_pos
        {
          id: prefixed_id, sale_line_id: sale_line&.prefixed_id, name: name, modifiers: modifiers, components: components,
          note: note, quantity: quantity.to_s('F'), status: status, started_at: started_at&.iso8601(3),
          ready_at: ready_at&.iso8601(3), served_at: served_at&.iso8601(3), voided_at: voided_at&.iso8601(3)
        }
      end

      private

      def content_fixed
        errors.add(:base, :readonly) if (changed & CONTENT).any?
      end
    end
  end
end
