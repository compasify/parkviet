# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's cup label printer, size and fields, how long a ready
          # call number stays on the call board, and a test label.
          class CupLabelSettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology], test: %w[write_pos_orders write_pos_topology]

            def show
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read_setup!(current_store, current_user, branch)
              render json: { data: Spree::Pos::CupLabels::Setup.settings(branch) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              attributes = params.permit(:printer_id, :size, :pickup_minutes, fields: []).to_h
              attributes['fields'] = [] if params.key?(:fields) && params[:fields].blank?
              result = Spree::Pos::CupLabels::Setup.update(store: current_store, staff: current_user, key: key, branch: branch,
                                                           attributes: attributes)
              render json: { data: result }
            end

            def test
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              result = Spree::Pos::CupLabels::Setup.test(store: current_store, staff: current_user, key: key, branch: branch)
              render json: { data: result }, status: :created
            end

            private

            def guard
              Spree::Pos::Kitchen::Guard
            end
          end
        end
      end
    end
  end
end
