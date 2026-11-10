# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Named capability sets for memberships. A change to a role's
          # capabilities reaches its members at once. A role in use cannot be
          # disabled or deleted.
          class StaffRolesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology], show: %w[read_pos_topology write_pos_topology]

            Role = Spree::Pos::StaffRole

            # `include_disabled=true` adds disabled roles.
            def index
              return if channel_rejected?

              scope = Role.for_store(current_store).order(:name, :id)
              scope = scope.where(status: 'active') unless ActiveModel::Type::Boolean.new.cast(params[:include_disabled]) == true
              render_page(scope)
            end

            def show
              return if channel_rejected?

              render json: { data: role!.to_pos }
            end

            def create
              return if channel_rejected?

              role = Role.create!(store: current_store, name: params[:name], capabilities: Array(params[:capabilities]),
                                  status: 'active')
              audit!('staff_role.create', role, role.to_pos.slice(:name, :capabilities))
              render json: { data: role.to_pos }, status: :created
            rescue ActiveRecord::RecordNotUnique
              raise Spree::Pos::Conflict, 'Another role uses this name.'
            end

            # Name, capabilities and status (`active` / `disabled`).
            def update
              return if channel_rejected?

              role = role!
              role.with_lock do
                role.name = params[:name] if params.key?(:name)
                role.capabilities = Array(params[:capabilities]) if params.key?(:capabilities)
                role.status = params[:status].to_s if params.key?(:status)
                if role.status_changed? && role.disabled? && role.in_use?
                  raise Spree::Pos::Conflict.new('This role is assigned to memberships.', reason: 'staff_role_in_use')
                end

                if role.changed?
                  role.save!
                  audit!('staff_role.update', role, role.to_pos.slice(:name, :capabilities, :status))
                end
              end
              render json: { data: role.to_pos }
            rescue ActiveRecord::RecordNotUnique
              raise Spree::Pos::Conflict, 'Another role uses this name.'
            end

            def destroy
              role = role!
              role.with_lock do
                raise Spree::Pos::Conflict.new('This role is assigned to memberships.', reason: 'staff_role_in_use') if role.in_use?

                audit!('staff_role.delete', role, role.to_pos.slice(:name, :capabilities))
                role.destroy!
              end
              head :no_content
            end

            private

            def role!
              role = Role.locate(Role.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if role.nil?

              role
            end
          end
        end
      end
    end
  end
end
