# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # The checklist of a table order: its document, and with
            # `printer_id` a print job on that printer.
            class ChecklistsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::Checklist.call(workspace: workspace!(params[:workspace_id]), staff: current_user,
                                                                key: key, printer_id: params[:printer_id])
                render json: { data: result }, status: :created
              end
            end
          end
        end
      end
    end
  end
end
