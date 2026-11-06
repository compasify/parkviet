# frozen_string_literal: true

module Spree
  module Pos
    module Shifts
      class Open
        def self.call(store:, staff:, opening_float:, register: nil, branch: nil)
          new(store:, staff:, register:, branch:, opening_float:).call
        end

        def initialize(store:, staff:, register:, branch:, opening_float:)
          @store = store
          @staff = staff
          @register = register
          @branch = branch || register&.branch
          @opening_float = opening_float
        end

        def call
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless authorized?(policy)

          amount = Record.money(opening_float)
          raise ActiveRecord::RecordInvalid, invalid_shift(amount) if amount.nil?

          (register || branch).with_lock do
            # Re-read staff and membership: either may have been revoked while waiting for the lock.
            policy = AccessPolicy.new(store: store, staff: staff)
            raise CanCan::AccessDenied unless authorized?(policy)
            scope = Shift.for_store(store).open_now.where(register_id: register&.id)
            scope = scope.where(branch_id: branch.id, owner_id: policy.staff.id) unless register
            raise Conflict, 'An open shift already exists for this selection.' if scope.exists?

            shift = Shift.create!(
              store: store,
              branch: branch,
              register: register,
              owner: policy.staff,
              opening_float: amount,
              currency: store.default_currency,
              status: 'open',
              opened_at: Time.current
            )
            AuditEntry.record!(
              store: store,
              actor: policy.staff,
              action: 'shift.open',
              subject: shift,
              metadata: { opening_float: shift.opening_float.to_s('F'), currency: shift.currency }
            )
            shift
          end
        rescue ActiveRecord::RecordNotUnique
          raise Conflict, 'An open shift already exists for this selection.'
        end

        private

        attr_reader :store, :staff, :register, :branch, :opening_float

        def authorized?(policy)
          if register
            register.store_id == store.id && register.branch_id == branch&.id && policy.can_open_shift?(register)
          else
            policy.can_open_branch_shift?(branch)
          end
        end

        def invalid_shift(amount)
          shift = Shift.new(opening_float: amount, currency: store.default_currency, status: 'open')
          shift.errors.add(:opening_float, :invalid)
          shift
        end
      end
    end
  end
end
