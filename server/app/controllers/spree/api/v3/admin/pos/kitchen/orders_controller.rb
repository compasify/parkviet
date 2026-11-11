# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Kitchen
            # The counter's pickup queue: the branch's call numbers still
            # being made and those ready to hand over, and "handed over",
            # which serves every ready item of one order.
            class OrdersController < BaseController
              scoped_resource :pos_orders
              pos_permissions index: %w[read_pos_orders write_pos_orders], serve: %w[write_pos_orders]

              def index
                return if channel_rejected?

                branch = guard.branch!(current_store, params[:branch_id])
                guard.hand_over!(current_store, current_user, branch)
                render json: { data: Spree::Pos::CallBoard.call(branch: branch, with_ids: true) }
              end

              def serve
                return if channel_rejected?

                workspace = Spree::Pos::Workspace.locate(Spree::Pos::Workspace.for_store(current_store), params[:workspace_id])
                raise ActiveRecord::RecordNotFound if workspace.nil?

                guard.hand_over!(current_store, current_user, workspace.branch)
                tickets = Spree::Pos::Kitchen::ChangeItemStatus.serve_order(workspace: workspace, actor: current_user)
                render json: { data: { workspace_id: workspace.prefixed_id, tickets: tickets.map { |ticket| ticket.reload.to_pos } } }
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
end
