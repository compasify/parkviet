# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Shared CRUD of the store's menu records. Reading is for anyone
          # working at a branch of the store; changing goes through
          # Menu::Save, which checks pos.menu.manage or store administration.
          class MenuResourcesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            destroy: %w[write_pos_orders write_pos_topology]

            def index
              read_store!
              render json: { data: scope.to_a.map { |record| present(record) } }
            end

            def create
              key = idempotency_key
              return if key.nil?

              render json: { data: save(key, nil) }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              render json: { data: save(key, record!) }
            end

            def destroy
              key = idempotency_key
              return if key.nil?

              render json: { data: Spree::Pos::Menu::Save.destroy(store: current_store, staff: current_user, key: key, record: record!) }
            end

            private

            def model
              raise NotImplementedError
            end

            def scope
              model.for_store(current_store).order(:position, :id)
            end

            def present(record)
              record.to_pos
            end

            def record!
              model.locate(model.for_store(current_store), params[:id]) || raise(ActiveRecord::RecordNotFound)
            end

            def read_store!
              access = policy
              return if access.permission?('read_pos_topology') || access.permission?('write_pos_topology')
              raise ActiveRecord::RecordNotFound unless access.memberships.any? { |membership| membership.status == 'active' }
            end

            def menu_save
              Spree::Pos::Menu::Save
            end
          end
        end
      end
    end
  end
end
