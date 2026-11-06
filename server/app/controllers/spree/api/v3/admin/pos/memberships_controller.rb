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

              scope = Spree::Pos::StaffMembership.for_store(current_store).includes(:staff, :branch).order(:id)
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
                status: 'active'
              )
              audit!('membership.create', membership, capabilities: membership.capabilities)
              render json: { data: membership.to_pos }, status: :created
            end

            def update
              return if channel_rejected?

              membership = membership!(params[:id])
              membership.update!(capabilities: Array(params[:capabilities])) if params.key?(:capabilities)
              audit!('membership.update', membership, capabilities: membership.capabilities)
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
