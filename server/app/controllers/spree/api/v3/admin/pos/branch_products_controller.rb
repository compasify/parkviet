# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Management uses the existing topology permission, not catalog write access.
          class BranchProductsController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology]

            # Store products with whether this branch sells them, for managing the
            # assortment. `assigned=true|false` narrows the list; `q` matches name or SKU.
            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              assigned_ids = Spree::Pos::BranchProduct.where(branch_id: branch.id).select(:product_id)
              scope = Spree::Product.where(store_id: current_store.id)
              case params[:assigned].to_s
              when 'true' then scope = scope.where(id: assigned_ids)
              when 'false' then scope = scope.where.not(id: assigned_ids)
              end
              term = params[:q].to_s.strip
              if term.present?
                escaped = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
                skus = Spree::Variant.where('spree_variants.sku ILIKE ?', escaped).select(:product_id)
                scope = scope.where('spree_products.name ILIKE ?', escaped).or(scope.where(id: skus))
              end
              records, meta = page_scope(scope.order(:name, :id))
              assigned = Spree::Pos::BranchProduct.where(branch_id: branch.id, product_id: records.map(&:id)).pluck(:product_id).to_set
              variants = Spree::Variant.where(product_id: records.map(&:id)).order(:id).group_by(&:product_id)
              data = records.map do |product|
                {
                  id: product.prefixed_id, name: product.name, status: product.status,
                  skus: Array(variants[product.id]).filter_map(&:sku).first(5), assigned: assigned.include?(product.id)
                }
              end
              render json: { data: data, meta: meta }
            end

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
