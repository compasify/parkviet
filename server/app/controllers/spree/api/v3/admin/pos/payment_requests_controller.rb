# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A table asking for the bill, and the cashier closing that request.
          class PaymentRequestsController < BaseController
            scoped_resource :pos_orders

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Tables::RequestPayment.call(workspace: workspace!(params[:workspace_id]), staff: current_user, key: key,
                                                               note: params[:note], device: @pos_device)
              render json: { data: result }, status: :created
            end

            def resolve
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Tables::ResolvePaymentRequest.call(workspace: workspace!(params[:workspace_id]), staff: current_user,
                                                                      key: key, status: params[:status])
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
