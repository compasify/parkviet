# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The hardware checklist of a branch (HardwareStatus), read-only.
          # Store administrators, and people who manage the branch
          # (pos.topology.manage there).
          class HardwareStatusController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_topology write_pos_topology read_pos_orders write_pos_orders]

            def show
              branch = Spree::Pos::Branch.locate(Spree::Pos::Branch.for_store(current_store), params[:branch_id]) ||
                       raise(ActiveRecord::RecordNotFound)
              access = Spree::Pos::AccessPolicy.new(store: current_store, staff: current_user)
              unless access.permission?('read_pos_topology') || access.allows?(branch, Spree::Pos::Capabilities::MANAGE)
                raise CanCan::AccessDenied
              end

              response.headers['Cache-Control'] = 'no-store'
              render json: { data: Spree::Pos::HardwareStatus.call(branch: branch) }
            end
          end
        end
      end
    end
  end
end
