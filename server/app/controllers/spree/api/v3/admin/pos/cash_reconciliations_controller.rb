# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Late-cash custody reconciliation for managers: what is still
          # unexplained (closed shifts with an overage, held cash) and the
          # reconciliations already recorded.
          class CashReconciliationsController < BaseController
            scoped_resource :pos_shifts
            pos_permissions index: %w[read_pos_shifts write_pos_shifts], candidates: %w[read_pos_shifts write_pos_shifts]

            def index
              branch = manager_branch!
              scope = Spree::Pos::CashReconciliation.for_store(current_store).where(branch_id: branch.id).
                      includes(:actor, :received_funds, :target_shift, :cash_movement, shift_closure: :shift).order(id: :desc)
              render_page(scope)
            end

            # Closed shifts whose overage is not fully explained yet, held cash
            # not yet reconciled, and the open drawers cash can go into.
            def candidates
              branch = manager_branch!
              closures = Spree::Pos::ShiftClosure.for_store(current_store).where(branch_id: branch.id).where('variance > 0').
                         includes(:register, shift: :owner).order(closed_at: :desc).limit(PAGE_MAX).to_a
              held = Spree::Pos::ReceivedFunds.for_store(current_store).where(branch_id: branch.id, kind: 'cash', custody: 'held').
                     where.not(id: Spree::Pos::CashReconciliation.where.not(received_funds_id: nil).select(:received_funds_id)).
                     includes(:actor, shift: %i[owner closure]).order(id: :desc).limit(PAGE_MAX)
              shifts = Spree::Pos::Shift.for_store(current_store).where(branch_id: branch.id).
                       where('opened_at >= ?', 7.days.ago).includes(:owner, :register).order(opened_at: :desc).limit(PAGE_MAX)
              render json: { data: {
                closures: closures.filter_map { |closure| closure_row(closure) },
                held_funds: held.map { |funds| held_row(funds) },
                shifts: shifts.map { |shift| shift_row(shift) }
              } }
            end

            def create
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Shifts::ReconcileLateCash.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                outcome: params[:outcome], reason: params[:reason], amount: params[:amount],
                closure_id: params[:closure_id], funds_id: params[:funds_id], target_shift_id: params[:target_shift_id],
                custody_reference: params[:custody_reference]
              )
              render json: { data: result }, status: :created
            end

            private

            def manager_branch!
              branch = branch!(params[:branch_id])
              allowed = policy.allows?(branch, Spree::Pos::Capabilities::APPROVE) &&
                policy.allows?(branch, Spree::Pos::Capabilities::RESOLVE)
              raise CanCan::AccessDenied unless allowed

              branch
            end

            def closure_row(closure)
              unexplained = closure.variance - closure.reconciled_amount
              return unless unexplained.positive?

              { id: closure.prefixed_id, shift_id: closure.shift.prefixed_id, register: closure.register&.code,
                owner_name: Spree::Pos::StaffName.call(closure.shift.owner), closed_at: closure.closed_at.iso8601,
                counted: closure.counted.to_s('F'), expected: closure.expected.to_s('F'),
                variance: closure.variance.to_s('F'), unexplained: unexplained.to_s('F'), currency: closure.currency }
            end

            # Which shift took the held cash, and that shift's closing count when
            # it has one: held cash on an over shift counts against that overage.
            def held_row(funds)
              closure = funds.shift.closure
              unexplained = closure&.variance&.positive? ? closure.variance - closure.reconciled_amount : nil
              { id: funds.prefixed_id, shift_id: funds.shift.prefixed_id, amount: funds.received_net.to_s('F'),
                shift_owner_name: Spree::Pos::StaffName.call(funds.shift.owner), shift_status: funds.shift.status,
                shift_opened_at: funds.shift.opened_at.iso8601, shift_closed_at: funds.shift.closed_at&.iso8601,
                closure_id: closure&.prefixed_id, closure_counted: closure&.counted&.to_s('F'),
                closure_expected: closure&.expected&.to_s('F'), closure_unexplained: unexplained&.to_s('F'),
                overage_explained: !unexplained.nil? && unexplained < funds.received_net,
                currency: funds.currency, custody_note: funds.custody_note, received_at: funds.received_at.iso8601,
                booked_at: funds.created_at.iso8601, recorded_by: Spree::Pos::StaffName.call(funds.actor),
                recorded_by_me: funds.actor_id == current_user.id }
            end

            def shift_row(shift)
              { id: shift.prefixed_id, status: shift.status, register: shift.register&.code,
                owner_name: Spree::Pos::StaffName.call(shift.owner), opening_float: shift.opening_float.to_s('F'),
                opened_at: shift.opened_at.iso8601, closed_at: shift.closed_at&.iso8601 }
            end
          end
        end
      end
    end
  end
end
