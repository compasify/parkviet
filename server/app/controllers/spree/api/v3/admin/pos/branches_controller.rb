# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class BranchesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology], show: %w[read_pos_topology write_pos_topology]

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

              branch = Spree::Pos::Branch.create!(branch_attributes.merge(store: current_store, status: 'active'))
              audit!('branch.create', branch)
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
              attrs = {}
              attrs[:name] = params[:name] if params.key?(:name) || record.nil?
              attrs[:code] = params[:code] if params.key?(:code) || record.nil?
              attrs[:timezone] = params[:timezone] if params.key?(:timezone) || record.nil?
              if params.key?(:stock_location_id) || record.nil?
                attrs[:stock_location] = location!(params[:stock_location_id])
              end
              if params.key?(:receiving_stock_location_id)
                prefixed = params[:receiving_stock_location_id]
                attrs[:receiving_stock_location] = prefixed.present? ? location!(prefixed) : nil
              end
              attrs[:receiving_config] = { 'note' => params[:receiving_note] } if params.key?(:receiving_note) || record.nil?
              # Blank turns returns off at the branch; a number of days turns them on.
              attrs[:return_window_days] = params[:return_window_days].presence if params.key?(:return_window_days)
              attrs
            end
          end
        end
      end
    end
  end
end
