# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Debt collection: one actual receipt allocated to debtor orders.
          class CollectionsController < BaseController
            scoped_resource :pos_orders

            def show
              return if channel_rejected?

              collection = Spree::Pos::Collection.locate(Spree::Pos::Collection.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if collection.nil?
              raise CanCan::AccessDenied unless policy.membership_for(collection.branch)&.status == 'active'

              render json: { data: collection.to_pos }
            end

            def create
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Collections::Receive.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                credit_account_id: params[:credit_account_id], kind: params[:kind], amount: params[:amount],
                handed_amount: params[:handed_amount], reference: params[:reference],
                receiving_account: params[:receiving_account], note: params[:note],
                allocations: params[:allocations] || [], confirm_duplicate: params[:confirm_duplicate]
              )
              render json: { data: result }, status: :created
            end
          end
        end
      end
    end
  end
end
