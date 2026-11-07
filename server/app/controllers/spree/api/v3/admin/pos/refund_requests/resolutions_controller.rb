# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module RefundRequests
            # Marks a refund payout unknown, failed with no effect (with
            # evidence) or canceled before it started.
            class ResolutionsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                data = Spree::Pos::Refunds::Resolve.call(
                  store: current_store, staff: current_user, key: key, refund_id: params[:refund_request_id],
                  outcome: params[:outcome], reference: params[:reference], reason: params[:reason]
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
