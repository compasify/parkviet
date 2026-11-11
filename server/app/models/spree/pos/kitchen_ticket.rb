# frozen_string_literal: true

module Spree
  module Pos
    # What one send told one station: written once, never changed. Editing the
    # order afterwards leaves the ticket as it was; only the status of its
    # items moves (KitchenTicketItem).
    class KitchenTicket < Record
      self.table_name = 'spree_pos_kitchen_tickets'
      has_prefix_id :poskticket

      KINDS = %w[fire void].freeze
      # A finished ticket stays on the board this long, for recall.
      DONE_WINDOW = 30.minutes

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :kitchen_station, class_name: 'Spree::Pos::KitchenStation'
      belongs_to :sent_by, polymorphic: true, optional: true
      has_many :items, -> { order(:id) }, class_name: 'Spree::Pos::KitchenTicketItem', inverse_of: :kitchen_ticket,
                                         dependent: :restrict_with_error

      validates :kind, inclusion: { in: KINDS }
      validates :send_key, presence: true, length: { maximum: 200 }
      validates :sequence, numericality: { only_integer: true, greater_than: 0 }
      validates :service_mode, inclusion: { in: Workspace::SERVICE_MODES }
      validates :business_date, :sent_at, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      def readonly?
        persisted? || super
      end

      # Every item is past the kitchen: ready, served or voided.
      def done?
        items.all? { |item| KitchenTicketItem::DONE.include?(item.status) }
      end

      # When the last item became ready or left the board; nil while open.
      def done_at
        return unless done?

        items.filter_map { |item| item.ready_at || item.served_at || item.voided_at }.max
      end

      def to_pos
        {
          id: prefixed_id, workspace_id: workspace.prefixed_id, branch_id: branch.prefixed_id,
          kitchen_station_id: kitchen_station.prefixed_id, station_name: kitchen_station.name, station_kind: kitchen_station.kind,
          sequence: sequence, kind: kind, service_mode: service_mode, business_date: business_date.iso8601,
          header: header, sent_at: sent_at.iso8601(3), done: done?, done_at: done_at&.iso8601(3),
          items: items.map(&:to_pos)
        }
      end
    end
  end
end
