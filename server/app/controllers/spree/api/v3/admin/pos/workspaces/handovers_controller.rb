# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class HandoversController < BaseController
              scoped_resource :pos_workspaces

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::Handover.call(workspace: workspace!, staff: current_user, key: key)
                render json: { data: result }
              end
            end
          end
        end
      end
    end
  end
end
