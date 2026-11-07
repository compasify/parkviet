# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Returns at the counter: preview, prepare, approve, receive and
          # cancel. The browser sends quantities and conditions per sale line;
          # every amount is computed on the server under locks.
          class ReturnsController < BaseController
            scoped_resource :pos_orders

            STATUSES = %w[pending_approval ready received canceled].freeze

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless Spree::Pos::Masking.returns_visible?(policy, branch)

              scope = Spree::Pos::ReturnOperation.for_store(current_store).where(branch_id: branch.id).
                      includes(:branch, :sale_branch, :order, :core_return, :requester, :approval, :refund_requests).order(id: :desc)
              statuses = Array(params[:status].presence || STATUSES).flat_map { |value| value.to_s.split(',') }
              raise Spree::Pos::Conflict, 'Status filter is invalid.' unless (statuses - STATUSES).empty?

              records, meta = page_scope(scope.where(status: statuses))
              render json: { data: records.map(&:to_row), meta: meta }
            end

            def show
              return if channel_rejected?

              operation = operation!
              render json: { data: operation.to_pos(mask: !Spree::Pos::Masking.references_visible?(policy, operation.branch)) }
            end

            def preview
              return if channel_rejected?

              data = Spree::Pos::Returns::Prepare.preview(store: current_store, staff: current_user, branch_id: params[:branch_id],
                                                          order_id: params[:order_id], lines: params[:lines])
              render json: { data: data }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Returns::Prepare.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                       order_id: params[:order_id], lines: params[:lines], reason: params[:reason])
              render json: { data: data }, status: :created
            end

            def approve
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Returns::Approve.call(store: current_store, staff: current_user, key: key, return_id: operation!.prefixed_id,
                                                       expires_at: params[:expires_at])
              render json: { data: data }
            end

            def receive
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Returns::Receive.call(store: current_store, staff: current_user, key: key, return_id: operation!.prefixed_id,
                                                       approval_id: params[:approval_id])
              render json: { data: data }
            end

            def cancel
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Returns::Cancel.call(store: current_store, staff: current_user, key: key, return_id: operation!.prefixed_id,
                                                      reason: params[:reason])
              render json: { data: data }
            end

            private

            # Visible to return, resolve or approve staff of the receiving or the
            # sale branch; branch membership alone is not enough.
            def operation!
              operation = Spree::Pos::ReturnOperation.locate(Spree::Pos::ReturnOperation.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if operation.nil?
              unless [operation.branch, operation.sale_branch].any? { |branch| Spree::Pos::Masking.returns_visible?(policy, branch) }
                raise ActiveRecord::RecordNotFound
              end

              operation
            end
          end
        end
      end
    end
  end
end
