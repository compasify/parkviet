# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class MembershipsController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology], show: %w[read_pos_topology write_pos_topology]

            def index
              return if channel_rejected?

              scope = Spree::Pos::StaffMembership.for_store(current_store).includes(:staff, :branch, :staff_role).order(:id)
              scope = scope.where(branch_id: branch!(params[:branch_id]).id) if params[:branch_id].present?
              render_page(scope)
            end

            def show
              return if channel_rejected?

              render json: { data: membership!(params[:id]).to_pos }
            end

            def create
              return if channel_rejected?

              membership = Spree::Pos::StaffMembership.create!(
                store: current_store,
                branch: branch!(params[:branch_id]),
                staff: staff!(params[:staff_id]),
                capabilities: Array(params[:capabilities]),
                staff_role: params.key?(:staff_role_id) ? staff_role(params[:staff_role_id]) : nil,
                status: 'active'
              )
              audit!('membership.create', membership, audit_metadata(membership))
              render json: { data: membership.to_pos }, status: :created
            end

            # `staff_role_id` assigns a role (null removes it, and the
            # membership's own capabilities apply again).
            def update
              return if channel_rejected?

              membership = membership!(params[:id])
              membership.capabilities = Array(params[:capabilities]) if params.key?(:capabilities)
              membership.staff_role = staff_role(params[:staff_role_id]) if params.key?(:staff_role_id)
              membership.save!
              audit!('membership.update', membership, audit_metadata(membership))
              render json: { data: membership.to_pos }
            end

            def disable
              membership = membership!(params[:id])
              Spree::Pos::Topology::Disable.call(record: membership, actor: current_user)
              render json: { data: membership.to_pos }
            end

            def enable
              membership = membership!(params[:id])
              Spree::Pos::Topology::Enable.call(record: membership, actor: current_user, policy: policy)
              render json: { data: membership.to_pos }
            end

            private

            def staff_role(prefixed)
              return nil if prefixed.blank?

              role = Spree::Pos::StaffRole.locate(Spree::Pos::StaffRole.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if role.nil?

              role
            end

            def audit_metadata(membership)
              { capabilities: membership.capabilities, staff_role_id: membership.staff_role&.prefixed_id }
            end

            def membership!(prefixed)
              membership = Spree::Pos::StaffMembership.locate(
                Spree::Pos::StaffMembership.for_store(current_store),
                prefixed
              )
              raise ActiveRecord::RecordNotFound if membership.nil?

              membership
            end
          end
        end
      end
    end
  end
end
