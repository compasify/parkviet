# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Module switches of a branch (BranchModules::Set). Store topology
          # managers (`write_pos_topology`) everywhere, a branch's topology
          # manager (`pos.topology.manage`) at that branch only. Turning a
          # module off hides its setup screens and refuses its new setup
          # commands; selling what is configured never depends on it.
          class BranchModulesController < BaseController
            scoped_resource :pos_topology
            MANAGERS = %w[read_pos_orders read_pos_topology write_pos_topology].freeze
            pos_permissions index: MANAGERS, update: MANAGERS

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              readable = policy.permission?('read_pos_topology') || Spree::Pos::BranchModules::Set.manage?(policy, branch)
              raise CanCan::AccessDenied unless readable

              rows = Spree::Pos::BranchModule.where(branch_id: branch.id).includes(:branch, :changed_by).order(:module_key)
              render json: {
                data: {
                  branch_id: branch.prefixed_id,
                  modules: Spree::Pos::ModulePolicy.for_branch(branch),
                  settings: rows.map(&:to_pos)
                }
              }
            end

            def update
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              data = Spree::Pos::BranchModules::Set.call(store: current_store, actor: current_user, branch: branch, key: params[:id],
                                                         enabled: params.key?(:enabled) ? params[:enabled] : nil, reason: params[:reason])
              render json: { data: data }
            end
          end
        end
      end
    end
  end
end
