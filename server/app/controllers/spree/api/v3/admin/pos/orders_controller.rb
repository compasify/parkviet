# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Order history of one branch: placed POS sales with server-side
          # filters, and one order's timeline (original total, receipts,
          # entitlement, credit notes, refunds, debt and stock effects). Members
          # of the branch read it; contact details are masked unless the reader
          # collects, approves or manages credit there, payment references
          # unless they resolve or approve money there. Staff who process
          # returns elsewhere may look one sale up by its exact number, masked.
          class OrdersController < BaseController
            scoped_resource :pos_orders

            UNMASKED = ReceivablesController::UNMASKED

            def index
              return if channel_rejected?

              branch = member_branch!
              history = Spree::Pos::OrderHistory.new(store: current_store, branch: branch)
              scope = history.scope(number: params[:number], from: params[:from], to: params[:to],
                                    register_id: params[:register_id], cashier_id: params[:cashier_id], status: params[:status])
              records, meta = page_scope(scope)
              render json: { data: history.rows(records, mask: mask?(branch)), meta: meta }
            end

            def show
              return if channel_rejected?

              workspace = Spree::Pos::Returns::Guard.sale!(current_store, params[:id])
              render json: { data: detail_for(workspace) }
            end

            # Exact-number lookup for a cross-branch return at `branch_id`.
            def lookup
              return if channel_rejected?

              number = params[:number].to_s.strip.upcase
              order = Spree::Order.where(store_id: current_store.id).find_by(number: number) if number.present?
              raise ActiveRecord::RecordNotFound if order.nil?

              workspace = Spree::Pos::Workspace.for_store(current_store).find_by(order_id: order.id, operational_status: 'completed')
              raise ActiveRecord::RecordNotFound if workspace.nil?

              render json: { data: detail_for(workspace) }
            end

            # Dispatches a short handover once the shelf was corrected; a
            # resolver of the sale branch, whoever owned the shift.
            def reconcile_handover
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Orders::ReconcileHandover.call(store: current_store, staff: current_user, key: key, order_id: params[:id])
              render json: { data: data }
            end

            private

            def member_branch!
              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.membership_for(branch)&.status == 'active'

              branch
            end

            # Sale-branch members see the order; return staff of the branch in
            # the request see it masked, to take a return of it there.
            def detail_for(workspace)
              sale_branch = workspace.branch
              history = Spree::Pos::OrderHistory.new(store: current_store, branch: sale_branch)
              if policy.membership_for(sale_branch)&.status == 'active'
                return history.detail(workspace, mask: mask?(sale_branch),
                                                 mask_references: !Spree::Pos::Masking.references_visible?(policy, sale_branch))
              end

              receiving = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
              raise ActiveRecord::RecordNotFound unless receiving && policy.allows?(receiving, Spree::Pos::Capabilities::RETURN)

              history.detail(workspace, mask: true, mask_references: true)
            end

            def mask?(branch)
              UNMASKED.none? { |capability| policy.allows?(branch, capability) }
            end
          end
        end
      end
    end
  end
end
