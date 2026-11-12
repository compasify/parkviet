# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A canteen's meal accounts: the list and one account with its
          # wallet history, adding, changing and importing accounts, finding
          # an eater at the counter (rate limited per staff member), and the
          # wallet's top-ups, refunds and corrections. Every action names the
          # branch it is done at (`branch_id`).
          class MealAccountsController < BaseController
            RESOLVE_ATTEMPTS = 120
            RESOLVE_WINDOW = 1.minute
            RESOLVE_LIMIT_STORE = Rails.cache.is_a?(ActiveSupport::Cache::NullStore) ? ActiveSupport::Cache::MemoryStore.new : Rails.cache

            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            entries: %w[read_pos_orders write_pos_orders], resolve: %w[read_pos_orders write_pos_orders],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            import: %w[write_pos_orders write_pos_topology]

            rate_limit to: RESOLVE_ATTEMPTS, within: RESOLVE_WINDOW, only: :resolve, store: RESOLVE_LIMIT_STORE,
                       by: -> { "#{current_store&.id}:#{current_user&.id || request.remote_ip}" },
                       with: lambda {
                         render_error(code: 'meal_resolve_rate_limited', message: 'Too many lookups.', status: :too_many_requests)
                       }

            def index
              branch = readable_branch!
              scope = Spree::Pos::MealAccount.for_store(current_store).
                      includes(:customer_profile, :meal_sponsor, :stored_value_account).order(:employee_code)
              scope = scope.where(status: params[:status].to_s) if params[:status].present?
              scope = scope.where(meal_sponsor_id: guard.sponsor!(current_store, params[:meal_sponsor_id]).id) if params[:meal_sponsor_id].present?
              if params[:q].present?
                term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.strip)}%"
                scope = scope.joins(:customer_profile).where('spree_pos_customers.name ILIKE :term OR employee_code ILIKE :term ' \
                                                             'OR spree_pos_meal_accounts.group_label ILIKE :term', term: term)
              end
              records, meta = page_scope(scope)
              balances = Spree::Pos::StoredValueEntry.where(stored_value_account_id: records.map(&:stored_value_account_id)).
                         group(:stored_value_account_id).sum(:amount)
              render json: { data: records.map { |row| row.to_pos(balance: BigDecimal((balances[row.stored_value_account_id] || 0).to_s)) },
                             meta: meta.merge(branch_id: branch.prefixed_id) }
            end

            def show
              readable_branch!
              render json: { data: guard.account!(current_store, params[:id]).to_pos }
            end

            # The wallet's history, newest first.
            def entries
              readable_branch!
              account = guard.account!(current_store, params[:id])
              scope = Spree::Pos::StoredValueEntry.where(stored_value_account_id: account.stored_value_account_id).
                      includes(:actor, :received_funds, :liability_payout, workspace: :order).order(id: :desc)
              render_page(scope)
            end

            # `q`: an exact employee code, or part of a name.
            def resolve
              readable_branch!
              found = Spree::Pos::MealAccounts::Resolve.call(store: current_store, input: params[:q])
              render json: { data: { match: found[:match]&.to_pos, suggestions: found[:suggestions].map(&:to_pos) } }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::MealAccounts::Save.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                    attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::MealAccounts::Save.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                    attributes: attributes, account_id: params[:id])
              end
            end

            # `csv`: the file's text.
            def import
              command do |key|
                Spree::Pos::MealAccounts::Import.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                      csv: params[:csv])
              end
            end

            def top_up
              command(status: :created) do |key|
                Spree::Pos::MealWallets::TopUp.call(
                  store: current_store, staff: current_user, key: key, branch_id: params[:branch_id], meal_account_id: params[:id],
                  kind: params[:kind], amount: params[:amount], handed_amount: params[:handed_amount], reference: params[:reference],
                  receiving_account: params[:receiving_account], confirm_duplicate: params[:confirm_duplicate]
                )
              end
            end

            def refund
              command do |key|
                Spree::Pos::MealWallets::Refund.call(
                  store: current_store, staff: current_user, key: key, branch_id: params[:branch_id], meal_account_id: params[:id],
                  amount: params[:amount], beneficiary_name: params[:beneficiary_name],
                  beneficiary_reference: params[:beneficiary_reference], reason: params[:reason], approval_id: params[:approval_id]
                )
              end
            end

            def adjust
              command do |key|
                Spree::Pos::MealWallets::Adjust.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                     meal_account_id: params[:id], amount: params[:amount], note: params[:note],
                                                     approval_id: params[:approval_id])
              end
            end

            private

            def guard
              Spree::Pos::MealAccounts::Guard
            end

            def readable_branch!
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              branch
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              permitted = params.permit(*(Spree::Pos::MealAccounts::Save::FIELDS - %w[meal_windows])).to_h
              permitted['meal_windows'] = params[:meal_windows] if params.key?(:meal_windows)
              permitted
            end
          end
        end
      end
    end
  end
end
