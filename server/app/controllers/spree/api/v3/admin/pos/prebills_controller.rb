# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Records a pre-bill of a table before it prints (first one free,
          # a reprint or a cancel needs an approval).
          class PrebillsController < BaseController
            scoped_resource :pos_orders

            def create
              run(cancel: false)
            end

            def cancel
              run(cancel: true)
            end

            private

            def run(cancel:)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Workspaces::Prebill.call(workspace: workspace!(params[:workspace_id]), staff: current_user, key: key,
                                                            approval_id: params[:approval_id], cancel: cancel, printer_id: params[:printer_id],
                                                            template_id: params[:receipt_template_id], mask: params[:unmask] != 'true')
              render json: { data: result }, status: cancel ? :ok : :created
            end
          end
        end
      end
    end
  end
end
