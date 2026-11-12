# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Kiosk orders left for the counter at a branch: the cashier takes
          # one to collect it on their own shift, or cancels one the guest
          # abandoned.
          class KioskOrdersController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], take: %w[write_pos_orders], cancel: %w[write_pos_orders]

            def index
              branch = branch!(params[:branch_id])
              policy_member = policy.membership_for(branch)
              unless policy_member && !policy_member.service_account && policy_member.allows?(Spree::Pos::Capabilities::OPEN_SHIFT) &&
                     policy_member.allows?(Spree::Pos::Capabilities::PAYMENT)
                raise CanCan::AccessDenied
              end

              render json: { data: Spree::Pos::Kiosks::Handoff.list(branch) }
            end

            def take
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Kiosks::Handoff.take(store: current_store, staff: current_user, key: key, workspace: kiosk_order!,
                                                        editor_id: params[:editor_id])
              render json: { data: result }
            end

            def cancel
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Kiosks::Handoff.cancel(store: current_store, staff: current_user, key: key, workspace: kiosk_order!,
                                                          reason: params[:reason])
              render json: { data: result }
            end

            private

            def kiosk_order!
              workspace = Spree::Pos::Workspace.locate(Spree::Pos::Workspace.for_store(current_store).where(order_source: 'kiosk'), params[:id].to_s)
              raise ActiveRecord::RecordNotFound if workspace.nil?

              workspace
            end
          end
        end
      end
    end
  end
end
