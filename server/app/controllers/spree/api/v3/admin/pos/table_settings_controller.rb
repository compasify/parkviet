# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's table service settings: the register table orders are
          # booked on and the service charge.
          class TableSettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology]

            def show
              branch = Spree::Pos::Resources::Guard.branch!(current_store, params[:branch_id])
              Spree::Pos::Resources::Guard.read!(current_store, current_user, branch)
              render json: { data: Spree::Pos::Tables::Settings.to_pos(branch) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              branch = Spree::Pos::Resources::Guard.branch!(current_store, params[:branch_id])
              attributes = params.permit(:table_register_id, :service_charge_rate, :service_charge_tax_category_id,
                                         :reservation_grace_minutes, :reservation_duration_minutes, :reservation_fee_product_id,
                                         :bottle_keep_days, :tips_as_revenue, :qr_order_mode, :qr_order_auto_limit,
                                         :qr_order_auto_max_items, tip_split: [:mode, { role_codes: [] }],
                                         service_charge_applies_to: [], course_labels: [:name]).to_h
              result = Spree::Pos::Tables::Settings.update(store: current_store, staff: current_user, key: key, branch: branch, attributes: attributes)
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
