# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Shifts
            # Cash out and safe drop requests waiting for a second person.
            # Confirmers (pos.cash.move or pos.approval.grant at the branch)
            # see the branch's pending requests; others see their own.
            class CashMovementRequestsController < BaseController
              scoped_resource :pos_shifts
              pos_permissions index: %w[read_pos_shifts write_pos_shifts]

              def index
                return if channel_rejected?

                branch = branch!(params[:branch_id])
                raise CanCan::AccessDenied unless policy.membership_for(branch)&.status == 'active'

                scope = Spree::Pos::CashMovementRequest.for_store(current_store).where(branch_id: branch.id).
                        includes(:branch, :shift, :requester, :confirmer, :cash_movement).order(id: :desc)
                confirmer = Spree::Pos::Shifts::ConfirmCashMovement.confirmer?(current_store, current_user, branch)
                scope = scope.where(requester_id: current_user.id) unless confirmer
                scope = scope.where(shift_id: guard.shift!(current_store, params[:shift_id]).id) if params[:shift_id].present?
                scope = scope.pending if params[:status].to_s == 'requested'
                render_page(scope)
              end

              def confirm
                decide('confirm')
              end

              def cancel
                decide('cancel')
              end

              private

              def guard
                Spree::Pos::Shifts::Guard
              end

              def decide(decision)
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Shifts::ConfirmCashMovement.call(store: current_store, staff: current_user, key: key,
                                                                      request_id: params[:id], decision: decision,
                                                                      note: params[:note])
                render json: { data: result }
              end
            end
          end
        end
      end
    end
  end
end
