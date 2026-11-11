# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The areas (floors, rooms) of a branch's floor plan. Reading is for
          # the people working at the branch; changing needs
          # pos.resource.manage or store administration.
          class AreasController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            archive: %w[write_pos_orders write_pos_topology]

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::Area.where(branch_id: branch.id).includes(:branch).order(:position, :id)
              scope = scope.active unless params[:status] == 'all'
              render json: { data: scope.map(&:to_pos) }
            end

            def create
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              result = Spree::Pos::Resources::UpsertArea.call(store: current_store, staff: current_user, key: key, branch: branch,
                                                              attributes: attributes)
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              area = area!
              result = Spree::Pos::Resources::UpsertArea.call(store: current_store, staff: current_user, key: key, branch: area.branch,
                                                              attributes: attributes, area_id: area.prefixed_id)
              render json: { data: result }
            end

            def archive
              key = idempotency_key
              return if key.nil?

              area = area!
              result = Spree::Pos::Resources::Archive.call(store: current_store, staff: current_user, key: key, branch: area.branch, record: area)
              render json: { data: result }
            end

            private

            def guard
              Spree::Pos::Resources::Guard
            end

            def area!
              Spree::Pos::Area.locate(Spree::Pos::Area.where(store_id: current_store.id), params[:id]) || raise(ActiveRecord::RecordNotFound)
            end

            def attributes
              params.permit(*Spree::Pos::Resources::UpsertArea::FIELDS).to_h
            end
          end
        end
      end
    end
  end
end
