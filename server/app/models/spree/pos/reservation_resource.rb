# frozen_string_literal: true

module Spree
  module Pos
    # One table or room a reservation holds, for its time. Two active holds
    # of a table never overlap (database exclusion constraint); a canceled,
    # finished or no-show booking lets its holds go.
    class ReservationResource < Record
      self.table_name = 'spree_pos_reservation_resources'

      belongs_to :reservation, class_name: 'Spree::Pos::Reservation', inverse_of: :holds
      belongs_to :resource, class_name: 'Spree::Pos::Resource'

      scope :active, -> { where(active: true) }
      # Active holds overlapping [starts_at, ends_at).
      scope :overlapping, lambda { |starts_at, ends_at|
        active.where("#{table_name}.starts_at < ? AND #{table_name}.ends_at > ?", ends_at, starts_at)
      }
    end
  end
end
