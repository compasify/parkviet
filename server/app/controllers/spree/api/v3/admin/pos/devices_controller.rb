# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Branch devices: list, issue a pairing code, rename, revoke.
          # pos.device.manage or store administration.
          class DevicesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create_pairing: %w[write_pos_orders write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology],
                            revoke: %w[write_pos_orders write_pos_topology]

            def index
              branch = Spree::Pos::Devices::Guard.branch!(current_store, params[:branch_id])
              Spree::Pos::Devices::Guard.manage!(current_store, current_user, branch)
              devices = Spree::Pos::Device.for_store(current_store).where(branch: branch).order(:name)
              render json: { data: devices.map(&:to_pos) }
            end

            def create_pairing
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::Pairing.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                mode: params[:mode], register_id: params[:register_id], device_id: params[:device_id],
                base_url: Spree::Pos::DeviceAuthenticator.public_base_url(request)
              )
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::Rename.call(
                store: current_store, staff: current_user, key: key, device_id: params[:id], name: params[:name]
              )
              render json: { data: result }
            end

            def revoke
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::Revoke.call(
                store: current_store, staff: current_user, key: key, device_id: params[:id]
              )
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
