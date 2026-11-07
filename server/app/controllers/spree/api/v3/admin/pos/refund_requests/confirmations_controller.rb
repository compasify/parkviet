# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module RefundRequests
            # Confirms a refund payout with evidence (cash count or bank
            # reference). Only this creates the core Refund.
            class ConfirmationsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                data = Spree::Pos::Refunds::ConfirmPayout.call(
                  store: current_store, staff: current_user, key: key, refund_id: params[:refund_request_id],
                  evidence_kind: params[:evidence_kind], reference: params[:reference], approval_id: params[:approval_id],
                  paid_from: params[:paid_from]
                )
                render json: { data: data }
              end
            end
          end
        end
      end
    end
  end
end
