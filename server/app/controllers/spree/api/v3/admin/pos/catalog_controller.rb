# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class CatalogController < BaseController
            scoped_resource :pos_orders

            def index
              return if channel_rejected?

              branch = Spree::Pos::Branch.locate(Spree::Pos::Branch.for_store(current_store), params[:branch_id])
              raise ActiveRecord::RecordNotFound unless branch && !branch.disabled?

              membership = policy.membership_for(branch)
              raise ActiveRecord::RecordNotFound unless membership && !membership.disabled?

              products = Spree::Pos::SalesChannel.sellable_products(current_store)
                .where(id: Spree::Pos::BranchProduct.where(branch_id: branch.id).select(:product_id))
              result = Spree::Pos::CatalogReader.new(store: current_store, products: products, stock_location: branch.stock_location).search(
                query: params.fetch(:q, ''), page: params.fetch(:page, 1), limit: params.fetch(:limit, 25),
                exact_barcode: params[:barcode] == 'true'
              )
              render json: result
            rescue ArgumentError, TypeError
              render_error(code: 'parameter_invalid', message: 'Invalid search or pagination.', status: :unprocessable_content)
            end
          end
        end
      end
    end
  end
end
