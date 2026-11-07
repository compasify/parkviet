# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Branch health for supervisors: approvers (`pos.approval.grant`)
          # and report readers (`pos.report.read`) at the branch. Read-only;
          # counts and ages only. The store-wide outbox section is null
          # unless the reader holds `write_pos_topology`.
          class OperationalMetricsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders read_pos_shifts write_pos_shifts read_pos_topology write_pos_topology]

            def show
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              membership = policy.membership_for(branch)
              allowed = membership&.status == 'active' &&
                (membership.allows?(Spree::Pos::Capabilities::APPROVE) || membership.allows?(Spree::Pos::Capabilities::REPORT_READ))
              raise ActiveRecord::RecordNotFound unless allowed

              response.headers['Cache-Control'] = 'no-store'
              # The outbox has no branch: its store-wide figures go to store-level readers only.
              metrics = Spree::Pos::OperationalMetrics.new(store: current_store, branch: branch,
                                                           include_outbox: policy.permission?('write_pos_topology'))
              render json: { data: metrics.call }
            end
          end
        end
      end
    end
  end
end
