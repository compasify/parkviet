# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # When a branch sends orders to the kitchen: as the sale completes
          # (`on_complete`) or when the cashier presses "send" (`manual`), and
          # the reasons a sent item may be voided for. One update changes one
          # of the two: `void_reasons` when sent, else the trigger.
          class KitchenSettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology]

            def show
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read_setup!(current_store, current_user, branch)
              render json: { data: Spree::Pos::Kitchen::Setup.settings(branch) }
            end

            def update
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              setup = Spree::Pos::Kitchen::Setup
              result = if params.key?(:void_reasons)
                         setup.set_void_reasons(store: current_store, staff: current_user, key: key, branch: branch,
                                                reasons: params[:void_reasons])
                       else
                         setup.set_trigger(store: current_store, staff: current_user, key: key, branch: branch,
                                           trigger: params[:kitchen_send_trigger])
                       end
              render json: { data: result }
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
