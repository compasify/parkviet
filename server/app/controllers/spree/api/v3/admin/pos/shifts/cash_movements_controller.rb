# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Shifts
            # Manual drawer movements (cash in, cash out, safe drop) of one
            # shift. The owner of an open shift lists only these, not every
            # sale movement, so the closing count stays blind; report readers
            # see the whole cashbook under reports.
            class CashMovementsController < BaseController
              scoped_resource :pos_shifts
              pos_permissions index: %w[read_pos_shifts write_pos_shifts]

              def index
                return if channel_rejected?

                shift = Spree::Pos::Shifts::Guard.shift!(current_store, params[:id])
                unless shift.owner_id == current_user.id || policy.allows?(shift.branch, Spree::Pos::Capabilities::REPORT_READ)
                  raise ActiveRecord::RecordNotFound
                end

                render_page(shift.cash_movements.where(kind: Spree::Pos::CashMovement::MANUAL).includes(:actor, :shift).order(id: :desc))
              end

              def create
                return if channel_rejected? || currency_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Shifts::PostCashMovement.call(
                  store: current_store, staff: current_user, key: key, shift_id: params[:id], kind: params[:kind],
                  amount: params[:amount], reason: params[:reason], evidence_reference: params[:evidence_reference]
                )
                render json: { data: result }, status: :created
              end
            end
          end
        end
      end
    end
  end
end
