# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The owner app's reads: the branches the person may watch, one
          # branch's day, its open tables and rooms (each with its lines), and
          # its alerts. Reading a branch needs `pos.report.read` there; the
          # figures come from the sales report (OwnerDashboard).
          class OwnerController < BaseController
            scoped_resource :pos_orders
            pos_permissions branches: %w[read_pos_orders read_pos_shifts write_pos_shifts],
                            today: %w[read_pos_orders read_pos_shifts write_pos_shifts],
                            open_units: %w[read_pos_orders read_pos_shifts write_pos_shifts],
                            open_unit: %w[read_pos_orders read_pos_shifts write_pos_shifts],
                            alerts: %w[read_pos_orders read_pos_shifts write_pos_shifts]

            WATCH = [Spree::Pos::Capabilities::REPORT_READ, Spree::Pos::Capabilities::APPROVE].freeze

            def branches
              memberships = policy.memberships.to_a.select { |membership| WATCH.any? { |key| membership.allows?(key) } }
              rows = Spree::Pos::Branch.for_store(current_store).where(id: memberships.map(&:branch_id), status: 'active').order(:name, :id)
              by_branch = memberships.index_by(&:branch_id)
              render json: { data: rows.map { |branch| branch_row(branch, by_branch.fetch(branch.id)) } }
            end

            def today
              render json: { data: Spree::Pos::OwnerDashboard.today(store: current_store, staff: current_user, branch: branch!(params[:branch_id])) }
            end

            def open_units
              data = Spree::Pos::OwnerDashboard.open_units(store: current_store, staff: current_user, branch: branch!(params[:branch_id]))
              render json: { data: data }
            end

            # One open order's lines, read only.
            def open_unit
              data = Spree::Pos::OwnerDashboard.open_unit(store: current_store, staff: current_user, branch: branch!(params[:branch_id]),
                                                          workspace_id: params[:workspace_id])
              render json: { data: data }
            end

            def alerts
              branch = branch!(params[:branch_id])
              Spree::Pos::OwnerDashboard.reader!(current_store, current_user, branch)
              render json: { data: Spree::Pos::OwnerAlerts.recent(branch).map(&:to_pos) }
            end

            private

            def branch_row(branch, membership)
              { id: branch.prefixed_id, name: branch.name, code: branch.code, timezone: branch.timezone,
                can_read_reports: membership.allows?(Spree::Pos::Capabilities::REPORT_READ),
                can_approve: membership.allows?(Spree::Pos::Capabilities::APPROVE),
                # The rule of Reservations::Guard.manage!: confirming and cancelling bookings.
                can_manage_reservations: manages_reservations?(membership) }
            end

            def manages_reservations?(membership)
              policy.permission?('write_pos_topology') || membership.allows?(Spree::Pos::Capabilities::RESERVATION_MANAGE)
            end
          end
        end
      end
    end
  end
end
