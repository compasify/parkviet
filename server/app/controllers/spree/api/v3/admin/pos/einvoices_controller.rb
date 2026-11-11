# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # E-invoices of completed POS orders: the list (filter
          # `status=outstanding` for "no invoice yet", `failed`, or one
          # status), one invoice, a summary with the year's turnover against
          # the 1 billion VND mark, and the manager's actions: buyer details,
          # retry (one or many), cancel an unsent invoice and request a
          # replacement. Reading and acting take pos.einvoice.manage at the
          # invoice's branch, or POS administration of the store.
          class EinvoicesController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            summary: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update_buyer: %w[write_pos_orders write_pos_topology],
                            retry_issue: %w[write_pos_orders write_pos_topology],
                            cancel: %w[write_pos_orders write_pos_topology],
                            replace: %w[write_pos_orders write_pos_topology]

            def index
              scope = Spree::Pos::Einvoice.for_store(current_store).where(branch_id: branch_ids).
                      includes(:branch, :order, :workspace, :original_einvoice).order(id: :desc)
              scope = filter_status(scope)
              term = params[:q].to_s.strip
              scope = scope.joins(:order).where('spree_orders.number ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(term)}%") if term.present?
              render_page(scope)
            end

            def show
              render json: { data: einvoice!.to_pos }
            end

            def summary
              branches = Spree::Pos::Branch.where(id: branch_ids).to_a
              render json: { data: Spree::Pos::Einvoices::Summary.call(store: current_store, branches: branches) }
            end

            def update_buyer
              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Einvoices::UpdateBuyer.call(store: current_store, staff: current_user, key: key,
                                                             einvoice: einvoice!, buyer: params[:buyer])
              render json: { data: data }
            end

            def replace
              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Einvoices::Replace.call(store: current_store, staff: current_user, key: key, einvoice: einvoice!,
                                                         buyer: params[:buyer], reason: params[:reason])
              render json: { data: data }, status: :created
            end

            def cancel
              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Einvoices::Cancel.call(store: current_store, staff: current_user, key: key, einvoice: einvoice!,
                                                        reason: params[:reason])
              render json: { data: data }
            end

            # `ids` (up to 100), or every failed invoice of `branch_id`.
            def retry_issue
              key = idempotency_key
              return if key.nil?

              list = if params[:ids].present?
                       Array(params[:ids]).first(Spree::Pos::Einvoices::Retry::LIMIT).map { |id| einvoice!(id) }
                     else
                       branch = branch!(params[:branch_id])
                       Spree::Pos::Einvoice.for_store(current_store).where(branch_id: branch.id, status: 'failed').
                         order(:id).limit(Spree::Pos::Einvoices::Retry::LIMIT).to_a
                     end
              data = Spree::Pos::Einvoices::Retry.call(store: current_store, staff: current_user, key: key, einvoices: list)
              render json: { data: data }
            end

            private

            # Branches whose invoices this person may see; one when
            # `branch_id` is given.
            def branch_ids
              @branch_ids ||= begin
                scope = Spree::Pos::Branch.for_store(current_store)
                scope = scope.where(id: branch!(params[:branch_id]).id) if params[:branch_id].present?
                if policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology')
                  scope.pluck(:id)
                else
                  ids = scope.to_a.select { |branch| policy.allows?(branch, Spree::Pos::Capabilities::EINVOICE_MANAGE) }.map(&:id)
                  raise CanCan::AccessDenied if ids.empty?

                  ids
                end
              end
            end

            def einvoice!(prefixed = params[:id])
              found = Spree::Pos::Einvoice.locate(Spree::Pos::Einvoice.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if found.nil?
              raise ActiveRecord::RecordNotFound unless branch_visible?(found.branch_id)

              found
            end

            def branch_visible?(branch_id)
              return true if policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology')

              branch = Spree::Pos::Branch.find(branch_id)
              policy.allows?(branch, Spree::Pos::Capabilities::EINVOICE_MANAGE)
            end

            def filter_status(scope)
              case params[:status].to_s
              when '' then scope
              when 'outstanding' then scope.outstanding
              when *Spree::Pos::Einvoice::STATUSES then scope.where(status: params[:status].to_s)
              else raise Spree::Pos::Conflict.new('Unknown status filter.', reason: 'einvoice_status_invalid')
              end
            end
          end
        end
      end
    end
  end
end
