# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class CustomersController < BaseController
            scoped_resource :pos_orders

            def index
              return if channel_rejected?

              branch = active_branch!(params[:branch_id])
              render json: Spree::Pos::CustomerService.search(
                store: current_store, staff: current_user, branch: branch, query: params[:q], page: params.fetch(:page, 1)
              )
            end

            def create
              return if channel_rejected?

              branch = active_branch!(params[:branch_id])
              key = idempotency_key
              return if key.nil?

              authorize = lambda do
                policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: current_user)
                raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::CUSTOMER)
              end
              result = Spree::Pos::CommandExecutor.call(
                store: current_store, actor: current_user, key: key,
                payload: { 'command' => 'create_customer', 'branch_id' => branch.prefixed_id,
                           'name' => params[:name].to_s, 'phone' => params[:phone].to_s, 'email' => params[:email].to_s },
                authorize: authorize
              ) do
                profile = Spree::Pos::CustomerService.create(
                  store: current_store, staff: current_user, branch: branch,
                  name: params[:name], phone: params[:phone], email: params[:email]
                )
                audit!('customer.create', profile, phone_present: profile.phone.present?, has_account: profile.customer.present?)
                { data: profile.to_pos.merge(duplicates: Spree::Pos::CustomerService.duplicates(store: current_store, phone: profile.phone)) }
              end
              render json: result, status: :created
            end

            private

            # Customer lookup and creation belong to selling, which a disabled branch does not do.
            def active_branch!(id)
              branch = branch!(id)
              raise CanCan::AccessDenied if branch.disabled?

              branch
            end
          end
        end
      end
    end
  end
end
