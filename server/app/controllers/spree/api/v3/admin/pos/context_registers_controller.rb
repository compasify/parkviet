# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class ContextRegistersController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders read_pos_topology write_pos_topology]

            def index
              return if channel_rejected?

              branch = Spree::Pos::Branch.locate(policy.visible_branches, params[:branch_id])
              raise ActiveRecord::RecordNotFound if branch.nil?

              render_page(search_named(Spree::Pos::Register.for_store(current_store).where(branch_id: branch.id).order(:name, :id)))
            end
          end
        end
      end
    end
  end
end
