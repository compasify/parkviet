# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The open bottles behind the bar that pours are measured from, and
          # their remaining ml. Bottles open on their own at the first pour;
          # finishing one by hand takes it off the shelf (stock -1).
          class OpenBottlesController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], finish: %w[write_pos_orders]

            def index
              return if channel_rejected?

              branch = Spree::Pos::BottleKeeps::Guard.branch!(current_store, params[:branch_id])
              Spree::Pos::BottleKeeps::Guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::OpenBottle.where(branch_id: branch.id).includes(variant: :product)
              scope = params[:status] == 'all' ? scope : scope.unfinished
              render json: { data: scope.order(opened_at: :desc, id: :desc).limit(100).map(&:to_pos) }
            end

            def finish
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Fnb::PourTracker.finish_by_hand(store: current_store, staff: current_user, key: key,
                                                                    bottle_id: params[:id])
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end