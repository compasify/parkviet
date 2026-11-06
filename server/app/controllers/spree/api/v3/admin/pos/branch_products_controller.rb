# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Management uses the existing topology permission, not catalog write access.
          class BranchProductsController < BaseController
            scoped_resource :pos_topology

            def create
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              product = Spree::Product.find_by_prefix_id(params[:product_id].to_s)
              raise ActiveRecord::RecordNotFound unless product && product.store_id == current_store.id

              Spree::Pos::BranchProduct.transaction do
                Spree::Pos::BranchProduct.create_or_find_by!(branch: branch, product: product)
                audit!('branch_product.add', branch, { product_id: product.prefixed_id })
              end
              render json: { data: { branch_id: branch.prefixed_id, product_id: product.prefixed_id } }, status: :created
            end

            def destroy
              branch = branch!(params[:branch_id])
              product = Spree::Product.find_by_prefix_id(params[:id].to_s)
              raise ActiveRecord::RecordNotFound unless product && product.store_id == current_store.id

              Spree::Pos::BranchProduct.transaction do
                Spree::Pos::BranchProduct.find_by!(branch: branch, product: product).destroy!
                audit!('branch_product.remove', branch, { product_id: product.prefixed_id })
              end
              head :no_content
            end
          end
        end
      end
    end
  end
end
