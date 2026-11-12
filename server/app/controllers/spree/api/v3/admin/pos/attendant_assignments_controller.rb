# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The attendants book of a branch: who serves which room, started
          # and stopped from the counter or the waiter app. No money.
          class AttendantAssignmentsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], candidates: %w[read_pos_orders write_pos_orders]

            # Open turns by default; `date` (YYYY-MM-DD, a business day) lists that day's.
            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              Spree::Pos::AttendantAssignments::Stop.authorize!(current_store, current_user, branch)
              scope = Spree::Pos::AttendantAssignment.for_store(current_store).where(branch_id: branch.id).
                      includes(:branch, :resource, :timed_session, :staff).order(:started_at, :id)
              scope = params[:date].present? ? scope.where(business_date: Date.iso8601(params[:date].to_s)) : scope.open
              if params[:resource_id].present?
                resource = Spree::Pos::Tables::Guard.table!(branch, params[:resource_id])
                scope = scope.where(resource_id: resource.id)
              end
              records, meta = page_scope(scope)
              now = Spree::Pos::Workspace.database_now
              render json: { data: records.map { |row| row.to_pos(now: now) }, meta: meta.merge(branch_id: branch.prefixed_id) }
            rescue Date::Error
              raise Spree::Pos::Conflict.new('Dates use YYYY-MM-DD.', reason: 'date_invalid')
            end

            # Who may be written in the book: the branch's active members, by name.
            def candidates
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              Spree::Pos::AttendantAssignments::Stop.authorize!(current_store, current_user, branch)
              rows = Spree::Pos::StaffMembership.for_store(current_store).people.where(branch_id: branch.id, status: 'active').
                     includes(:staff).filter_map(&:staff).uniq.
                     map { |staff| { id: staff.prefixed_id, name: Spree::Pos::StaffName.call(staff) } }.
                     sort_by { |row| row[:name].to_s.downcase }
              render json: { data: rows }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::AttendantAssignments::Start.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                             resource_id: params[:resource_id], attendant: staff!(params[:staff_id]),
                                                             note: params[:note])
              end
            end

            def stop
              command do |key|
                Spree::Pos::AttendantAssignments::Stop.call(store: current_store, staff: current_user, key: key, assignment_id: params[:id])
              end
            end

            private

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end
          end
        end
      end
    end
  end
end
