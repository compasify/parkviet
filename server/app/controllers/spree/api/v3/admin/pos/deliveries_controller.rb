# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # "Đơn cần giao": delivery orders of one branch, and marking them
          # delivered. Open to staff who sell or collect at the branch.
          class DeliveriesController < BaseController
            scoped_resource :pos_orders
            pos_permissions deliverers: %w[read_pos_orders]

            STATUSES = %w[pending delivered].freeze

            def index
              return if channel_rejected?

              branch = handler_branch!
              status = params[:status].presence || 'pending'
              raise Spree::Pos::Conflict.new('Status filter is invalid.', reason: 'delivery_status_invalid') unless STATUSES.include?(status)

              records, meta = page_scope(Spree::Pos::Deliveries::List.scope(store: current_store, branch: branch, status: status))
              render json: { data: Spree::Pos::Deliveries::List.rows(records), meta: meta }
            end

            # Names typed lately at the branch, for a quick pick.
            def deliverers
              return if channel_rejected?

              branch = handler_branch!
              render json: { data: Spree::Pos::Deliveries::List.recent_deliverers(store: current_store, branch: branch) }
            end

            def deliver
              change('delivered')
            end

            def reopen
              change('pending')
            end

            private

            def change(status)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Deliveries::ChangeStatus.call(
                store: current_store, staff: current_user, key: key, delivery_id: params[:id], status: status,
                deliverer: params.key?(:deliverer) ? params[:deliverer].to_s : nil
              )
              render json: { data: result }
            end

            def handler_branch!
              branch = branch!(params[:branch_id])
              handlers = Spree::Pos::Deliveries::ChangeStatus::HANDLERS
              raise CanCan::AccessDenied if handlers.none? { |capability| policy.allows?(branch, capability) }

              branch
            end
          end
        end
      end
    end
  end
end
