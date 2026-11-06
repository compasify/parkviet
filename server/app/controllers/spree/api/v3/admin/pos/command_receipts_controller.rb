# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class CommandReceiptsController < BaseController
            scoped_resource :pos_workspaces

            def index
              key = params[:idempotency_key].to_s
              raise ActiveRecord::RecordNotFound if key.blank? || key.length > 200

              receipt = Spree::Pos::CommandReceipt.find_by(store: current_store, actor: current_user, idempotency_key: key)
              raise ActiveRecord::RecordNotFound unless receipt&.workspace

              workspace = workspace!(receipt.workspace.prefixed_id)
              allowed = policy.allows?(workspace.branch, Spree::Pos::Capabilities::OPEN_SHIFT) ||
                        policy.allows?(workspace.branch, Spree::Pos::Capabilities::TAKEOVER)
              raise CanCan::AccessDenied if !allowed || workspace.branch.disabled? || workspace.register&.disabled?

              render json: { data: receipt.result }
            end
          end
        end
      end
    end
  end
end
