# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Goods refunds: request (reserve against the original receipt),
          # approve, and the reads approvers and cashiers wait on. Payout
          # confirmation and resolution live in nested controllers.
          class RefundRequestsController < BaseController
            scoped_resource :pos_orders

            STATUSES = %w[reserved unknown confirmed failed canceled].freeze

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless Spree::Pos::Masking.returns_visible?(policy, branch)

              statuses = Array(params[:status].presence || %w[reserved unknown]).flat_map { |value| value.to_s.split(',') }
              raise Spree::Pos::Conflict, 'Status filter is invalid.' unless (statuses - STATUSES).empty?

              scope = Spree::Pos::RefundRequest.for_store(current_store).where(branch_id: branch.id, status: statuses).
                      includes(:order, :return_operation, :received_funds, :funds_allocation, :branch, :requester,
                               :confirmer, :shift, :refund, :approval, :payout_evidences).order(id: :desc)
              records, meta = page_scope(scope)
              mask = !Spree::Pos::Masking.references_visible?(policy, branch)
              render json: { data: records.map { |row| row.to_pos(mask: mask) }, meta: meta }
            end

            def show
              return if channel_rejected?

              row = request_row!
              render json: { data: row.to_pos(mask: !Spree::Pos::Masking.references_visible?(policy, row.branch)) }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Refunds::Request.call(
                store: current_store, staff: current_user, key: key, return_id: params[:return_id],
                allocation_id: params[:allocation_id], amount: params[:amount], method: params[:method],
                beneficiary_reference: params[:beneficiary_reference]
              )
              render json: { data: data }, status: :created
            end

            def approve
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Refunds::Approve.call(store: current_store, staff: current_user, key: key,
                                                       refund_id: request_row!.prefixed_id, expires_at: params[:expires_at])
              render json: { data: data }
            end

            private

            def request_row!
              row = Spree::Pos::RefundRequest.locate(Spree::Pos::RefundRequest.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if row.nil? || !Spree::Pos::Masking.returns_visible?(policy, row.branch)

              row
            end
          end
        end
      end
    end
  end
end
