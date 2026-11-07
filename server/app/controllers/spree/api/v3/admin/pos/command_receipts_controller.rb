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
              raise ActiveRecord::RecordNotFound if receipt.nil?

              # Funds and payout commands have no workspace; the receipt is already
              # limited to the caller's own commands; it still needs current branch access.
              if receipt.workspace.nil?
                branch_id = receipt.result.is_a?(Hash) ? receipt.result['branch_id'] : nil
                branch = branch_id.present? ? branch!(branch_id) : nil
                raise CanCan::AccessDenied if branch.nil? || policy.membership_for(branch).nil? || branch.disabled?

                return render(json: { data: receipt.result })
              end

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
