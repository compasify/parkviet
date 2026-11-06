# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class PaymentMethodsController < BaseController
              scoped_resource :pos_orders

              def index
                return if channel_rejected?

                workspace = workspace!(params[:workspace_id])
                methods = Spree::Pos::PaymentMethodResolver.new(store: current_store).available(branch: workspace.branch)
                render json: {
                  data: methods.map { |row|
                    { id: row.prefixed_id || "posmethod-#{row.kind}", code: row.code, name: row.name, kind: row.kind, status: row.status || 'active', position: row.position }
                  }
                }
              end
            end
          end
        end
      end
    end
  end
end
