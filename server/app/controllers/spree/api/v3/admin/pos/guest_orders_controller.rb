# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Guests' orders from the table QR at a branch, and accepting or
          # rejecting them. Accepting adds the items to the table's order as
          # the person accepting and sends them to the kitchen.
          class GuestOrdersController < BaseController
            scoped_resource :pos_orders
            STATUSES = %w[pending accepted rejected expired].freeze

            def index
              branch = branch!(params[:branch_id])
              Spree::Pos::GuestOrders::Guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::GuestOrder.where(branch_id: branch.id).includes(:workspace, :decided_by, resource: :area)
              status = params[:status].presence || 'pending'
              return render_error(code: 'parameter_invalid', message: 'Unknown status.', status: :unprocessable_content) unless STATUSES.include?(status)

              scope = if status == 'pending'
                        scope.pending.joins(:workspace).where(spree_pos_workspaces: { operational_status: Spree::Pos::Workspace::OPEN_STATUSES })
                      else
                        scope.where(status: status).where(created_at: 1.day.ago..)
                      end
              scope = scope.where(workspace_id: workspace_id!(branch)) if params[:workspace_id].present?
              scope = scope.joins(:resource).where(spree_pos_resources: { area_id: area_id!(branch) }) if params[:area_id].present?
              render_page(scope.order(:created_at, :id))
            end

            def accept
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::GuestOrders::Accept.call(guest_order: guest_order!, staff: current_user, key: key, device: @pos_device)
              render json: { data: result['guest_order'], meta: result.except('guest_order') }
            end

            def reject
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::GuestOrders::Reject.call(guest_order: guest_order!, staff: current_user, key: key, reason: params[:reason])
              render json: { data: result['guest_order'] }
            end

            private

            def guest_order!
              order = Spree::Pos::GuestOrder.find_by_prefix_id(params[:id].to_s)
              raise ActiveRecord::RecordNotFound if order.nil? || order.store_id != current_store.id

              Spree::Pos::GuestOrders::Guard.read!(current_store, current_user, order.branch)
              order
            end

            def workspace_id!(branch)
              Spree::Pos::Workspace.locate(Spree::Pos::Workspace.where(branch_id: branch.id), params[:workspace_id])&.id ||
                raise(ActiveRecord::RecordNotFound)
            end

            def area_id!(branch)
              Spree::Pos::Area.locate(Spree::Pos::Area.where(branch_id: branch.id), params[:area_id])&.id || raise(ActiveRecord::RecordNotFound)
            end
          end
        end
      end
    end
  end
end
