# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The delivery platforms of a branch: which ones the counter takes
          # orders from and the percent each keeps.
          class PlatformSettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            update: %w[write_pos_orders write_pos_topology]

            def show
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              Spree::Pos::PlatformOrders::Guard.read!(current_store, current_user, branch)
              render json: {
                data: {
                  module_enabled: Spree::Pos::ModulePolicy.enabled?(branch, Spree::Pos::PlatformOrders::Enter::MODULE),
                  platforms: Spree::Pos::PlatformSetting.for_branch(branch).map(&:to_pos)
                }
              }
            end

            def update
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              branch = branch!(params[:branch_id])
              result = Spree::Pos::PlatformOrders::Configure.call(
                store: current_store, staff: current_user, key: key, branch: branch, platform: params[:platform],
                status: params[:status], commission_rate: params[:commission_rate]
              )
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
