# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A rest stop's coach visits at one branch (`branch_id`): the list by
          # business date and status, opening and changing open visits,
          # closing ("the coach left"), paying the commission, corrections
          # after closing (with an approval) and voids, and the branch's
          # visit window. Drivers' phones are shown in full only to people
          # managing visits.
          class VehicleVisitsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            settings: %w[read_pos_orders write_pos_orders]

            def index
              return if channel_rejected?

              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::VehicleVisit.for_store(current_store).where(branch_id: branch.id).
                      includes(:bus_operator, :opened_by, :cash_movement_request, :branch).order(arrived_at: :desc, id: :desc)
              scope = scope.where(status: params[:status].to_s.split(',')) if params[:status].present?
              scope = scope.where(business_date: date!(params[:business_date])) if params[:business_date].present?
              if params[:q].present?
                plate = Spree::Pos::VehicleVisit.normalize_plate(params[:q])
                scope = scope.where('plate LIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(plate.to_s)}%")
              end
              records, meta = page_scope(scope)
              full = guard.full_details?(current_store, current_user, branch)
              counts = Spree::Pos::Workspace.where(vehicle_visit_id: records.map(&:id)).group(:vehicle_visit_id).count
              render json: { data: records.map { |visit| visit.to_pos(full_phone: full, workspaces_count: counts[visit.id] || 0) },
                             meta: meta.merge(branch_id: branch.prefixed_id) }
            end

            def show
              return if channel_rejected?

              visit = guard.visit!(current_store, params[:id])
              guard.read!(current_store, current_user, visit.branch)
              render json: { data: guard.to_pos(visit, current_user) }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::VehicleVisits::Open.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                     attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::VehicleVisits::Update.call(store: current_store, staff: current_user, key: key, visit_id: params[:id],
                                                       attributes: attributes, revision: params[:expected_revision])
              end
            end

            def close
              command do |key|
                Spree::Pos::VehicleVisits::Close.call(store: current_store, staff: current_user, key: key, visit_id: params[:id])
              end
            end

            def pay
              command do |key|
                Spree::Pos::VehicleVisits::Pay.call(store: current_store, staff: current_user, key: key, visit_id: params[:id],
                                                    payout_method: params[:payout_method], transfer_reference: params[:transfer_reference])
              end
            end

            def adjust
              command do |key|
                Spree::Pos::VehicleVisits::Adjust.call(
                  store: current_store, staff: current_user, key: key, visit_id: params[:id], revision: params[:expected_revision],
                  note: params[:note], guest_count: params[:guest_count], commission_amount: params[:commission_amount],
                  approval_id: params[:approval_id]
                )
              end
            end

            def void
              command do |key|
                Spree::Pos::VehicleVisits::Void.call(store: current_store, staff: current_user, key: key, visit_id: params[:id],
                                                     reason: params[:reason])
              end
            end

            def settings
              return if channel_rejected?

              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              render json: { data: Spree::Pos::VehicleVisits::Settings.to_pos(branch) }
            end

            def update_settings
              command do |key|
                Spree::Pos::VehicleVisits::Settings.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                         visit_window_minutes: params[:visit_window_minutes])
              end
            end

            private

            def guard
              Spree::Pos::VehicleVisits::Guard
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              params.permit(*Spree::Pos::VehicleVisits::Open::FIELDS).to_h
            end

            def date!(value)
              Date.iso8601(value.to_s)
            rescue Date::Error
              raise Spree::Pos::Conflict.new('Dates use YYYY-MM-DD.', reason: 'date_invalid')
            end
          end
        end
      end
    end
  end
end
