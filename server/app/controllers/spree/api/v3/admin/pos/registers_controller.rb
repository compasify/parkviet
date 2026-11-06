# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class RegistersController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology], show: %w[read_pos_topology write_pos_topology]

            def index
              return if channel_rejected?

              scope = Spree::Pos::Register.for_store(current_store).order(:name)
              scope = scope.where(branch_id: branch!(params[:branch_id]).id) if params[:branch_id].present?
              render_page(search_named(scope))
            end

            def show
              return if channel_rejected?

              render json: { data: register!(params[:id]).to_pos }
            end

            def create
              return if channel_rejected?

              register = Spree::Pos::Register.create!(
                store: current_store,
                branch: branch!(params[:branch_id]),
                name: params[:name],
                code: params[:code],
                status: 'active'
              )
              audit!('register.create', register)
              render json: { data: register.to_pos }, status: :created
            end

            def update
              return if channel_rejected?

              register = register!(params[:id])
              register.with_lock do
                register.update!(register_attributes)
                audit!('register.update', register)
              end
              render json: { data: register.to_pos }
            end

            def disable
              register = register!(params[:id])
              Spree::Pos::Topology::Disable.call(record: register, actor: current_user)
              render json: { data: register.to_pos }
            end

            def enable
              register = register!(params[:id])
              Spree::Pos::Topology::Enable.call(record: register, actor: current_user, policy: policy)
              render json: { data: register.to_pos }
            end

            private

            def register_attributes
              attrs = {}
              attrs[:name] = params[:name] if params.key?(:name)
              attrs[:code] = params[:code] if params.key?(:code)
              attrs[:branch] = branch!(params[:branch_id]) if params.key?(:branch_id)
              attrs
            end
          end
        end
      end
    end
  end
end
