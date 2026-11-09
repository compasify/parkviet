# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Receivables of one branch from the immutable ledger. Any member of
          # the branch may read them; contact details are masked unless the
          # reader collects, approves or manages credit there.
          class ReceivablesController < BaseController
            scoped_resource :pos_orders

            STATUSES = %w[open overdue settled all].freeze
            UNMASKED = [Spree::Pos::Capabilities::PAYMENT, Spree::Pos::Capabilities::APPROVE,
                        Spree::Pos::Capabilities::CREDIT_MANAGE].freeze

            def index
              return if channel_rejected?

              branch = readable_branch!
              projection = projection_for(branch)
              oldest_due_first = Arel.sql('MAX(spree_pos_receivable_entries.due_on) ASC, spree_pos_receivable_entries.order_id ASC')
              rows_scope = projection.order_rows(status: status_param).reorder(oldest_due_first)
              records, meta = page_rows(rows_scope)
              render json: { data: serialize(projection, records, mask?(branch), branch), meta: meta }
            end

            # Per-customer balance, overdue and aging for the branch.
            def customers
              return if channel_rejected?

              branch = readable_branch!
              projection = projection_for(branch)
              rows = projection.order_rows(status: 'open').to_a
              accounts = Spree::Pos::CreditAccount.where(id: rows.map(&:credit_account_id).uniq).includes(:customer_profile).index_by(&:id)
              data = rows.group_by(&:credit_account_id).map do |account_id, account_rows|
                account = accounts.fetch(account_id)
                projection.summary(account_rows).merge(
                  'credit_account_id' => account.prefixed_id, 'currency' => account.currency,
                  'customer' => Spree::Pos::ReceivableProjection.customer(account.customer_profile, mask?(branch)),
                  'orders' => account_rows.length, 'credit_limit' => account.credit_limit.to_s('F'),
                  'account_status' => account.status
                )
              end
              data.sort_by! { |row| [-BigDecimal(row['overdue']), -BigDecimal(row['balance'])] }
              render json: { data: data, meta: { count: data.length, totals: projection.summary(rows) } }
            end

            private

            def readable_branch!
              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.membership_for(branch)&.status == 'active'

              branch
            end

            def status_param
              status = params[:status].presence || 'open'
              raise Spree::Pos::Conflict, 'Status filter is invalid.' unless STATUSES.include?(status)

              status
            end

            # The branch list holds debts sold at this branch. Looking up one
            # customer (to collect a debt here) spans every branch of the store,
            # for staff who sell, collect or approve credit at this branch.
            def projection_for(branch)
              scope = Spree::Pos::ReceivableEntry.for_store(current_store)
              if params[:customer_id].present? && action_name == 'index' && customer_lookup?(branch)
                profile = Spree::Pos::CustomerProfile.locate(Spree::Pos::CustomerProfile.for_store(current_store), params[:customer_id])
                scope = scope.where(credit_account_id: Spree::Pos::CreditAccount.where(customer_profile_id: profile&.id || 0).select(:id))
              else
                scope = scope.where(branch_id: branch.id)
                if params[:customer_id].present?
                  profile = Spree::Pos::CustomerProfile.locate(Spree::Pos::CustomerProfile.for_store(current_store), params[:customer_id])
                  scope = scope.where(credit_account_id: Spree::Pos::CreditAccount.where(customer_profile_id: profile&.id || 0).select(:id))
                end
              end
              if params[:q].present?
                accounts = Spree::Pos::CreditAccount.where(customer_profile_id: matching_profiles(branch)).select(:id)
                scope = scope.where(credit_account_id: accounts)
              end
              Spree::Pos::ReceivableProjection.new(scope, today: Time.now.in_time_zone(branch.timezone).to_date)
            end

            def customer_lookup?(branch)
              CreditAccountsController::LOOKUP_CAPABILITIES.any? { |capability| policy.allows?(branch, capability) }
            end

            # A reader who only sees masked phones may search by name or by the
            # full phone number, never by a fragment that would reveal digits.
            def matching_profiles(branch)
              query = params[:q].to_s.strip.first(120)
              profiles = Spree::Pos::CustomerProfile.for_store(current_store)
              term = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
              phone = Spree::Pos::CustomerProfile.normalize_phone(query)
              if mask?(branch)
                profiles.where('name ILIKE :term OR (normalized_phone = :phone AND :phone <> \'\')', term: term, phone: phone).select(:id)
              else
                profiles.where('name ILIKE :term OR phone ILIKE :term OR normalized_phone = :phone', term: term, phone: phone).select(:id)
              end
            end

            def page_rows(relation)
              page = [params[:page].to_i, 1].max
              limit = params[:limit].to_i
              limit = 25 if limit <= 0
              limit = PAGE_MAX if limit > PAGE_MAX
              total = Spree::Pos::ReceivableEntry.from(relation.reorder(nil), :rows).count
              records = relation.offset((page - 1) * limit).limit(limit).to_a
              pages = total.zero? ? 0 : (total.to_f / limit).ceil
              [records, { page: page, limit: limit, count: total, pages: pages }]
            end

            # Each open debt carries its pay-later QR for what is still owed,
            # for staff to send the customer (nil without VietQR at the branch).
            def serialize(projection, rows, mask, branch)
              orders = Spree::Order.where(id: rows.map(&:order_id)).index_by(&:id)
              accounts = Spree::Pos::CreditAccount.where(id: rows.map(&:credit_account_id)).includes(:customer_profile).index_by(&:id)
              workspaces = Spree::Pos::Workspace.where(id: rows.map(&:workspace_id)).index_by(&:id)
              sale_receipts = Spree::Pos::FundsAllocation.where(order_id: orders.keys, status: 'active', collection_id: nil).
                              group(:order_id).sum(:amount)
              refunds = Spree::Refund.joins(:payment).
                        where(payment_id: Spree::Pos::FundsAllocation.where(order_id: orders.keys).where.not(collection_id: nil).select(:payment_id)).
                        group('spree_payments.order_id').sum(:amount)
              lookups = { orders: orders, accounts: accounts, workspaces: workspaces, sale_receipts: sale_receipts, refunds: refunds }
              account = Spree::Pos::PayLater.receiving_account(current_store, branch)
              rows.map do |row|
                pay_later = Spree::Pos::PayLater.details(order: orders.fetch(row.order_id), amount: row.balance, account: account)
                projection.serialize(row, lookups, mask: mask).merge(pay_later: pay_later)
              end
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
