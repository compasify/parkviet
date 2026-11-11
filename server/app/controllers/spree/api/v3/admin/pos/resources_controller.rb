# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The tables (rooms, billiard tables) of a branch's floor plan.
          # Marking one cleaning or back in use is for the people serving and
          # selling there; the rest needs pos.resource.manage.
          class ResourcesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            archive: %w[write_pos_orders write_pos_topology], manual_status: %w[write_pos_orders write_pos_topology]

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::Resource.where(branch_id: branch.id).includes(:branch, :area).order(:position, :id)
              scope = scope.active unless params[:status] == 'all'
              render json: { data: scope.map(&:to_pos) }
            end

            def create
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              result = Spree::Pos::Resources::UpsertResource.call(store: current_store, staff: current_user, key: key, branch: branch,
                                                                  attributes: attributes)
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              resource = resource!
              result = Spree::Pos::Resources::UpsertResource.call(store: current_store, staff: current_user, key: key, branch: resource.branch,
                                                                  attributes: attributes, resource_id: resource.prefixed_id)
              render json: { data: result }
            end

            def archive
              key = idempotency_key
              return if key.nil?

              resource = resource!
              result = Spree::Pos::Resources::Archive.call(store: current_store, staff: current_user, key: key, branch: resource.branch,
                                                           record: resource)
              render json: { data: result }
            end

            def manual_status
              key = idempotency_key
              return if key.nil?

              resource = resource!
              result = Spree::Pos::Resources::SetManualStatus.call(store: current_store, staff: current_user, key: key, branch: resource.branch,
                                                                   resource: resource, manual_status: params[:manual_status])
              render json: { data: result }
            end

            private

            def guard
              Spree::Pos::Resources::Guard
            end

            def resource!
              Spree::Pos::Resource.locate(Spree::Pos::Resource.where(store_id: current_store.id), params[:id]) ||
                raise(ActiveRecord::RecordNotFound)
            end

            def attributes
              params.permit(:area_id, *Spree::Pos::Resources::UpsertResource::FIELDS).to_h
            end
          end
        end
      end
    end
  end
end
