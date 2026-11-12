# frozen_string_literal: true

module Spree
  module Pos
    # Who served a room, from when to when: a book of hours only. It moves
    # no money and is never on the bill; the attendants report sums it by
    # staff member and business day. A staff member serves one room at a
    # time (partial unique index).
    class AttendantAssignment < Record
      self.table_name = 'spree_pos_attendant_assignments'
      has_prefix_id :posattendant

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :timed_session, class_name: 'Spree::Pos::TimedSession', optional: true
      belongs_to :staff, class_name: staff_class_name
      belongs_to :started_by, class_name: staff_class_name
      belongs_to :ended_by, class_name: staff_class_name, optional: true

      validates :started_at, :business_date, presence: true
      validates :note, length: { maximum: 255 }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :open, -> { where(ended_at: nil) }

      def open?
        ended_at.nil?
      end

      # Whole minutes served up to `now` (or the end).
      def minutes(now = Workspace.database_now)
        (((ended_at || now) - started_at) / 60).floor
      end

      def to_pos(now: Workspace.database_now)
        { id: prefixed_id, branch_id: branch.prefixed_id, resource_id: resource.prefixed_id, resource_name: resource.name,
          timed_session_id: timed_session&.prefixed_id, staff: { id: staff.prefixed_id, name: StaffName.call(staff) },
          started_at: started_at.iso8601, ended_at: ended_at&.iso8601, minutes: minutes(now), business_date: business_date.iso8601,
          note: note }
      end
    end
  end
end
