# frozen_string_literal: true

module Spree
  module Pos
    # The ml one sale line poured from one open bottle. Unique per line and
    # bottle, so a completion that runs again never pours twice.
    class PourEvent < Record
      self.table_name = 'spree_pos_pour_events'
      has_prefix_id :pospour

      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :open_bottle, class_name: 'Spree::Pos::OpenBottle', inverse_of: :pour_events
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'

      validates :ml, numericality: { only_integer: true, greater_than: 0 }
      validates :business_date, presence: true
    end
  end
end
