# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Customer credit terms.
          # - Credit managers list the accounts homed at a branch they manage
          #   and administer them (the account's home branch decides).
          # - Selling or collecting staff look up one customer's account by
          #   `customer_id`; they never get a store-wide list.
          class CreditAccountsController < BaseController
            scoped_resource :pos_orders

            LOOKUP_CAPABILITIES = [Spree::Pos::Capabilities::CREDIT_MANAGE, Spree::Pos::Capabilities::CREDIT_SELL,
                                   Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::PAYMENT].freeze

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              scope = Spree::Pos::CreditAccount.for_store(current_store).includes(:customer_profile, :branch).order(:id)
              if params[:customer_id].present?
                raise CanCan::AccessDenied unless LOOKUP_CAPABILITIES.any? { |capability| policy.allows?(branch, capability) }

                profile = Spree::Pos::CustomerProfile.locate(Spree::Pos::CustomerProfile.for_store(current_store), params[:customer_id])
                render_page(scope.where(customer_profile_id: profile&.id || 0))
              else
                raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::CREDIT_MANAGE)

                render_page(scope.where(branch_id: branch.id))
              end
            end

            def create
              configure(customer_id: params[:customer_id], status: :created)
            end

            def update
              configure(account_id: params[:id], status: :ok)
            end

            private

            def configure(customer_id: nil, account_id: nil, status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Credit::Configure.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                customer_id: customer_id, account_id: account_id, credit_limit: params[:credit_limit],
                due_days: params[:due_days], status: params[:status]
              )
              render json: { data: result }, status: status
            end
          end
        end
      end
    end
  end
end
