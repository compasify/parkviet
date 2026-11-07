# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Who sees what. A holder of `pos.report.read` at the branch sees every
      # shift there; any other active member sees only their own shifts (and,
      # for the cashbook, only once closed, so the blind count stays blind).
      # Non-members see nothing.
      class Scope
        def initialize(store:, staff:, branch:)
          @store = store
          @branch = branch
          @policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless full? || policy.membership_for(branch)&.status == 'active'
        end

        attr_reader :store, :branch, :policy

        def staff
          policy.staff
        end

        def full?
          @full = policy.allows?(branch, Capabilities::REPORT_READ) if @full.nil?
          @full
        end

        def export?
          policy.allows?(branch, Capabilities::REPORT_EXPORT)
        end

        def shifts
          scope = Shift.for_store(store).where(branch_id: branch.id)
          full? ? scope : scope.where(owner_id: staff.id)
        end

        # The reader's own open shifts whose drawer is not counted yet: their
        # cash totals stay hidden from the reader until the blind count.
        def blind_shift_ids
          return Shift.none.select(:id) if full?

          shifts.open_now.where(closing_counted: nil).select(:id)
        end
      end
    end
  end
end
