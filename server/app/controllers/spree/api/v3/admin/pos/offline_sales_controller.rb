# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Cash sales a counter made while the server was out of reach: the
          # counter replays each one (keyed `offline:<offline_id>`), reads the
          # ones waiting for review, and finishes or rejects them.
          class OfflineSalesController < BaseController
            STATUSES = Spree::Pos::OfflineSale::STATUSES

            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], create: %w[write_pos_orders],
                            resolve: %w[write_pos_orders], reject: %w[write_pos_orders]

            def create
              key = idempotency_key
              return if key.nil?

              sale = Spree::Pos::OfflineSales::Ingest.call(store: current_store, staff: current_user, key: key, params: params)
              render json: { data: sale }
            end

            # The sales of a branch in one status (waiting for review by
            # default): a manager sees everyone's, a cashier their own.
            def index
              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::OPEN_SHIFT) ||
                policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)

              status = params[:status].presence || 'needs_review'
              raise ActiveRecord::RecordNotFound unless STATUSES.include?(status)

              scope = Spree::Pos::OfflineSale.where(store_id: current_store.id, branch_id: branch.id, status: status)
              scope = scope.where(staff_id: current_user.id) unless policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)
              scope = scope.includes(:branch, :register, :shift, :staff, :resolved_by, workspace: :order).
                      order(client_sold_at: :asc, id: :asc).limit(PAGE_MAX)
              render json: { data: scope.map(&:to_pos) }
            end

            def resolve
              key = idempotency_key
              return if key.nil?

              sale = Spree::Pos::OfflineSales::Resolve.call(store: current_store, staff: current_user, key: key, sale: sale!, mode: params[:mode],
                                                            approval_id: params[:approval_id], handed_amount: params[:handed_amount],
                                                            lines: params[:lines], note: params[:note])
              render json: { data: sale }
            end

            def reject
              key = idempotency_key
              return if key.nil?

              sale = Spree::Pos::OfflineSales::Reject.call(store: current_store, staff: current_user, key: key, sale: sale!, reason: params[:reason])
              render json: { data: sale }
            end

            private

            def sale!
              sale = Spree::Pos::OfflineSale.locate(Spree::Pos::OfflineSale.where(store_id: current_store.id), params[:id].to_s)
              raise ActiveRecord::RecordNotFound if sale.nil?

              sale
            end
          end
        end
      end
    end
  end
end
