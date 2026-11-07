# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Traceability state of one variant at a branch for the sale screen:
          # tracked mode, whether it is sellable there (opening balance done and
          # typed stock matching the shelf), sellable lots in FEFO order and
          # the number of free serial units. Reading it reserves nothing.
          class TraceabilityController < BaseController
            scoped_resource :pos_orders

            def show
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              membership = policy.membership_for(branch)
              raise ActiveRecord::RecordNotFound unless membership && !membership.disabled?

              variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
              raise ActiveRecord::RecordNotFound if variant.nil? || variant.product.store_id != current_store.id
              raise ActiveRecord::RecordNotFound unless Spree::Pos::BranchProduct.exists?(branch: branch, product: variant.product)

              render json: { data: Spree::Pos::StockIntegration.status(branch, variant) }
            end
          end
        end
      end
    end
  end
end
