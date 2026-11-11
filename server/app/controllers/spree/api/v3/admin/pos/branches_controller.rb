# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class BranchesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology], show: %w[read_pos_topology write_pos_topology],
                            profile_preview: %w[read_pos_topology write_pos_topology]

            def index
              return if channel_rejected?

              render_page(search_named(Spree::Pos::Branch.for_store(current_store).order(:name)))
            end

            def show
              return if channel_rejected?

              render json: { data: branch!(params[:id]).to_pos }
            end

            def create
              return if channel_rejected?

              # Without profile_key the branch takes the store's main profile.
              branch = Spree::Pos::Branches::Create.call(store: current_store, actor: current_user, profile_key: params[:profile_key].presence,
                                                         attributes: branch_attributes)
              render json: { data: branch.to_pos }, status: :created
            end

            def update
              return if channel_rejected?

              branch = branch!(params[:id])
              branch.with_lock do
                branch.update!(branch_attributes(branch))
                audit!('branch.update', branch)
              end
              render json: { data: branch.to_pos }
            end

            # What moving the branch to another profile would change; changes nothing.
            def profile_preview
              return if channel_rejected?

              branch = branch!(params[:id])
              render json: { data: Spree::Pos::Profiles::Preview.call(branch: branch, profile_key: params[:profile_key]) }
            end

            # Moves the branch to another profile, applying only what was picked.
            def profile
              return if channel_rejected?

              data = Spree::Pos::Profiles::Apply.call(
                store: current_store, actor: current_user, branch: branch!(params[:id]), profile_key: params[:profile_key],
                expected_profile_key: params[:expected_profile_key], reason: params[:reason],
                apply_modules: params[:apply_modules], apply_defaults: params.key?(:apply_defaults) ? params[:apply_defaults] : [],
                has_tables: params[:has_tables], table_register_id: params[:table_register_id], apply_stations: params[:apply_stations]
              )
              render json: { data: data }
            end

            def disable
              branch = branch!(params[:id])
              Spree::Pos::Topology::Disable.call(record: branch, actor: current_user)
              render json: { data: branch.to_pos }
            end

            def enable
              branch = branch!(params[:id])
              Spree::Pos::Topology::Enable.call(record: branch, actor: current_user, policy: policy)
              render json: { data: branch.to_pos }
            end

            private

            def branch_attributes(record = nil)
              Spree::Pos::Branches::Attributes.call(store: current_store, params: params, record: record)
            end
          end
        end
      end
    end
  end
end
