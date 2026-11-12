# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's kiosk settings and kiosks, and opening and closing a
          # kiosk's shift, for the managers who set kiosks up.
          class KioskSettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology],
                            open_shift: %w[write_pos_orders write_pos_topology],
                            close_shift: %w[write_pos_orders write_pos_topology]

            def show
              branch = branch!(params[:branch_id])
              Spree::Pos::Kiosks::Policy.manage!(current_store, current_user, branch)
              render json: { data: Spree::Pos::Kiosks::Settings.to_pos(branch) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              branch = branch!(params[:branch_id])
              attributes = params.permit(:kiosk_idle_seconds, :kiosk_qr_timeout_seconds, :kiosk_kitchen_before_payment).to_h
              render json: { data: Spree::Pos::Kiosks::Settings.update(store: current_store, staff: current_user, key: key, branch: branch,
                                                                       attributes: attributes) }
            end

            def open_shift
              key = idempotency_key
              return if key.nil?

              shift = Spree::Pos::Kiosks::Shifts.open(store: current_store, staff: current_user, key: key, register_id: params[:register_id])
              render json: { data: shift }, status: :created
            end

            def close_shift
              key = idempotency_key
              return if key.nil?

              closure = Spree::Pos::Kiosks::Shifts.close(store: current_store, staff: current_user, key: key, register_id: params[:register_id])
              render json: { data: closure }
            end
          end
        end
      end
    end
  end
end
