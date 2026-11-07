# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # One report of one branch, filtered and paginated on the server.
          # Only allowlisted query keys are accepted; the reader's scope comes
          # from branch capabilities, never from the client.
          class ReportsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders read_pos_shifts write_pos_shifts]

            ROUTING_KEYS = %w[controller action format report branch_id page limit].freeze

            rescue_from Spree::Pos::Reports::Filters::Invalid, with: :render_invalid_filter

            def show
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              scope = Spree::Pos::Reports::Scope.new(store: current_store, staff: current_user, branch: branch)
              report = Spree::Pos::Reports.build(params[:report], scope: scope, values: filter_values)
              rows, meta = report.page(params[:page], params[:limit])
              render json: { data: rows, meta: meta.merge(report.meta).merge(summary: report.summary) }
            end

            private

            def filter_values
              request.query_parameters.except(*ROUTING_KEYS).to_h { |key, value| [key, scalar!(key, value)] }
            end

            def scalar!(key, value)
              raise Spree::Pos::Reports::Filters::Invalid, "Filter #{key} takes one value." unless value.is_a?(String)

              value
            end

            def render_invalid_filter(error)
              render_error(code: 'parameter_invalid', message: error.message, status: :unprocessable_content)
            end
          end
        end
      end
    end
  end
end
