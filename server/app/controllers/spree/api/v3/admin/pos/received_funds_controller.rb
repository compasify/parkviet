# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class ReceivedFundsController < BaseController
            scoped_resource :pos_orders

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.membership_for(branch)

              scope = Spree::Pos::ReceivedFunds.for_store(current_store).where(branch_id: branch.id).
                      includes(:workspace, :branch, :shift, :tender_attempt).order(id: :desc)
              scope = scope.where(workspace_id: workspace!(params[:workspace_id]).id) if params[:workspace_id].present?
              render_page(scope)
            end

            def show
              return if channel_rejected?

              funds = funds!(params[:id])
              render json: { data: funds.to_pos.merge(payouts: funds.liability_payouts.order(:id).map(&:to_pos),
                                                      allocations: funds.allocations.order(:id).map(&:to_pos)) }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::RecordUnsolicitedFunds.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                shift_id: params[:shift_id], kind: params[:kind], handed_amount: params[:handed_amount],
                reference: params[:reference], receiving_account: params[:receiving_account],
                custody: params[:custody], custody_note: params[:custody_note], workspace_id: params[:workspace_id]
              )
              render json: { data: result }, status: :created
            end

            def request_payout
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              funds = funds!(params[:id])
              result = Spree::Pos::LiabilityPayouts::Request.call(
                store: current_store, staff: current_user, key: key, funds_id: funds.prefixed_id,
                amount: params[:amount], beneficiary_name: params[:beneficiary_name],
                beneficiary_reference: params[:beneficiary_reference], reason: params[:reason],
                approval_id: params[:approval_id]
              )
              render json: { data: result }, status: :created
            end

            def confirm_payout
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::LiabilityPayouts::Confirm.call(
                store: current_store, staff: current_user, key: key, payout_id: params[:payout_id],
                evidence_kind: params[:evidence_kind], reference: params[:reference]
              )
              render json: { data: result }
            end

            def resolve_payout
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::LiabilityPayouts::Resolve.call(
                store: current_store, staff: current_user, key: key, payout_id: params[:payout_id],
                outcome: params[:outcome], reference: params[:reference]
              )
              render json: { data: result }
            end

            private

            def funds!(prefixed)
              funds = Spree::Pos::ReceivedFunds.locate(Spree::Pos::ReceivedFunds.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if funds.nil?
              raise CanCan::AccessDenied unless policy.membership_for(funds.branch)

              funds
            end
          end
        end
      end
    end
  end
end
