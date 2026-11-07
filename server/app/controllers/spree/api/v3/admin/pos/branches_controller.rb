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

            # Blank means the default customer display freshness window.
            def display_attributes
              return {} unless params.key?(:display_freshness_ttl_seconds)

              { display_freshness_ttl_seconds: params[:display_freshness_ttl_seconds].presence }
            end

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
              # Blank means every non-zero closing variance needs an approval.
              attrs[:variance_threshold] = params[:variance_threshold].presence if params.key?(:variance_threshold)
              attrs.merge!(display_attributes)
              # FEFO only, or cashiers may name a valid lot at the counter.
              if params.key?(:lot_selection)
                raise Spree::Pos::Conflict, 'Lot selection is invalid.' unless %w[fefo cashier_pick].include?(params[:lot_selection].to_s)

                attrs[:lot_selection] = params[:lot_selection].to_s
              end
              # Blank means every positive stock count change needs an approval.
              if params.key?(:adjustment_approval_threshold)
                value = params[:adjustment_approval_threshold].to_s.strip
                raise Spree::Pos::Conflict, 'Adjustment threshold is invalid.' unless value.empty? || value.match?(/\A\d{1,10}\z/)

                attrs[:adjustment_approval_threshold] = value.empty? ? nil : Integer(value, 10)
              end
              attrs
            end
          end
        end
      end
    end
  end
end
