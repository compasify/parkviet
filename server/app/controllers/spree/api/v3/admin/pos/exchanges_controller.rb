# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Exchanges: a return linked to a replacement sale on the caller's
          # own open shift. Both legs keep their own documents.
          class ExchangesController < BaseController
            scoped_resource :pos_orders

            def show
              return if channel_rejected?

              exchange = Spree::Pos::ExchangeOperation.locate(Spree::Pos::ExchangeOperation.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if exchange.nil? || !Spree::Pos::Masking.returns_visible?(policy, exchange.branch)

              render json: { data: exchange.to_pos }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Exchanges::Execute.call(
                store: current_store, staff: current_user, key: key, return_id: params[:return_id],
                editor_id: params[:editor_id], register_id: params[:register_id], branch_id: params[:branch_id]
              )
              render json: { data: data }, status: :created
            end
          end
        end
      end
    end
  end
end
