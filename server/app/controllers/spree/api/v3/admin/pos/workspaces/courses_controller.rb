# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # "Fire" a held course of a table order: its dishes go to the
            # kitchen. Answers the workspace, with the tickets in `meta`.
            class CoursesController < BaseController
              scoped_resource :pos_orders

              def fire
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Kitchen::FireCourse.call(workspace: workspace!(params[:workspace_id]), actor: current_user,
                                                              course: params[:course], key: key, approval_id: params[:approval_id])
                render json: { data: result['workspace'], meta: { tickets: result['tickets'], ticket_count: result['ticket_count'] } },
                       status: result['ticket_count'].to_i.positive? ? :created : :ok
              end
            end
          end
        end
      end
    end
  end
end
