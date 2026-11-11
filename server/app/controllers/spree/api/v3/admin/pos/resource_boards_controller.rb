# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The live floor of a branch: every table and its state computed
          # from the open orders (Spree::Pos::ResourceState).
          class ResourceBoardsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology]

            def show
              branch = Spree::Pos::Resources::Guard.branch!(current_store, params[:branch_id])
              Spree::Pos::Resources::Guard.read!(current_store, current_user, branch)
              render json: { data: Spree::Pos::ResourceState.for(branch) }
            end
          end
        end
      end
    end
  end
end
