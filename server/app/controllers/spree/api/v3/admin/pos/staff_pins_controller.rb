# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Own PIN, or a manager clearing someone else's. The PIN itself is
          # never read back.
          class StaffPinsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology],
                            destroy: %w[write_pos_orders write_pos_topology]

            # Whose PIN this person may act on at the branch: their own, and
            # everyone's for a device manager.
            def index
              branch = Spree::Pos::Devices::Guard.branch!(current_store, params[:branch_id])
              rows = Spree::Pos::StaffMembership.for_store(current_store).where(branch: branch).includes(:staff, :branch, :staff_role).order(:id)
              rows = rows.where(staff_id: current_user.id) unless Spree::Pos::Devices::Guard.manage?(current_store, current_user, branch)
              render json: { data: rows.map(&:to_pos) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::SetPin.call(
                store: current_store, staff: current_user, key: key,
                membership_id: params[:membership_id], pin: params[:pin]
              )
              render json: { data: result }
            end

            def destroy
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::ResetPin.call(
                store: current_store, staff: current_user, key: key, membership_id: params[:membership_id]
              )
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
