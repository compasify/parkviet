# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Sold out at a branch for today, or back on sale.
          class MenuAvailabilitiesController < BaseController
            scoped_resource :pos_orders
            self.pos_machine_devices = true
            pos_permissions update: %w[write_pos_orders write_pos_topology]

            def update
              key = idempotency_key
              return if key.nil?

              guard = Spree::Pos::Menu::Guard
              branch = guard.branch!(current_store, params[:branch_id])
              item = guard.menu_item!(current_store, params[:menu_item_id])
              result = Spree::Pos::Menu::SetSoldOut.call(
                store: current_store, staff: current_user, key: key, branch: branch, menu_item: item,
                sold_out: ActiveModel::Type::Boolean.new.cast(params[:sold_out]) == true, device: @pos_device
              )
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
