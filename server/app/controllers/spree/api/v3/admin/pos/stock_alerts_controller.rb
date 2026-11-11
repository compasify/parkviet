# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Low-stock thresholds of a branch with what its shelf shows now,
          # lowest first. Reading takes pos.inventory.manage or
          # pos.report.read at the branch; changing takes pos.inventory.manage
          # (Recipes::SetStockAlert). Both answer with the branch's list.
          class StockAlertsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology]

            def index
              branch = branch!(params[:branch_id])
              read!(branch)
              render json: { data: alerts(branch) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              branch = branch!(params[:branch_id])
              variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
              raise ActiveRecord::RecordNotFound if variant.nil? || variant.product&.store_id != current_store.id

              Spree::Pos::Recipes::SetStockAlert.call(store: current_store, staff: current_user, key: key, branch: branch,
                                                      variant: variant, min_quantity: params[:min_quantity])
              render json: { data: alerts(branch) }
            end

            private

            def read!(branch)
              return if policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology')
              if [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::REPORT_READ].any? { |capability| policy.allows?(branch, capability) }
                return
              end

              raise CanCan::AccessDenied
            end

            def alerts(branch)
              rows = Spree::Pos::StockAlert.where(branch_id: branch.id).includes(:branch, variant: %i[product option_values]).to_a
              levels = Spree::StockLevel.where(stock_location_id: branch.stock_location_id, variant_id: rows.map(&:variant_id)).
                       pluck(:variant_id, :count_on_hand).to_h
              rows.map { |row| row.to_pos(on_hand: levels[row.variant_id] || 0) }.
                sort_by { |row| [row[:low] ? 0 : 1, row[:on_hand] - row[:min_quantity], row[:name].to_s] }
            end
          end
        end
      end
    end
  end
end
