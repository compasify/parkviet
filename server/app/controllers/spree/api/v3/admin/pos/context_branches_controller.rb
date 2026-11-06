# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class ContextBranchesController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders read_pos_topology write_pos_topology]

            def index
              return if channel_rejected?

              render_page(search_named(policy.visible_branches.order(:name, :id)))
            end
          end
        end
      end
    end
  end
end
