# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's bookings: the day's list, free tables for a time, and
          # booking, changing, confirming, cancelling and seating a party. Deposits are
          # taken here and refunded or kept with an approval.
          class ReservationsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            availability: %w[read_pos_orders write_pos_orders]

            # `date` (YYYY-MM-DD, the branch's day) or `from` / `to` (ISO times).
            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              from, to = window(branch)
              scope = Spree::Pos::Reservation.for_store(current_store).where(branch_id: branch.id).
                      where('starts_at < ? AND ends_at > ?', to, from)
              scope = scope.where(status: Array(params[:status]).map(&:to_s)) if params[:status].present?
              rows = scope.includes(:branch, :customer_profile, :workspace, holds: { resource: :area },
                                                                            deposits: :received_funds).order(:starts_at, :id).limit(500)
              render json: { data: rows.map(&:to_pos), meta: { from: from.iso8601, to: to.iso8601 } }
            end

            def show
              reservation = guard.reservation!(current_store, params[:id])
              guard.read!(current_store, current_user, reservation.branch)
              render json: { data: reservation.to_pos }
            end

            # Free tables for a party at a time, smallest that fits first.
            def availability
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              starts_at = guard.parse!(params[:starts_at])
              ends_at = params[:ends_at].present? ? guard.parse!(params[:ends_at]) : starts_at + branch.reservation_duration_minutes.minutes
              raise Spree::Pos::Conflict.new('A booking ends after it starts.', reason: 'reservation_time_invalid') unless ends_at > starts_at

              except = params[:except_id].present? ? guard.reservation!(current_store, params[:except_id]) : nil
              party = params[:party_size].present? ? guard.party_size!(params[:party_size]) : 1
              render json: { data: Spree::Pos::Reservations::Availability.call(branch: branch, starts_at: starts_at, ends_at: ends_at,
                                                                               party_size: party, except: except),
                             meta: { starts_at: starts_at.iso8601, ends_at: ends_at.iso8601, party_size: party } }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::Reservations::Create.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                      resource_ids: Array(params[:resource_ids]), attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::Reservations::Update.call(store: current_store, staff: current_user, key: key, reservation_id: params[:id],
                                                      attributes: attributes,
                                                      resource_ids: params.key?(:resource_ids) ? Array(params[:resource_ids]) : nil)
              end
            end

            def confirm
              command do |key|
                Spree::Pos::Reservations::Confirm.call(store: current_store, staff: current_user, key: key, reservation_id: params[:id])
              end
            end

            # `status`: canceled (default) or no_show.
            def cancel
              command do |key|
                Spree::Pos::Reservations::Cancel.call(store: current_store, staff: current_user, key: key, reservation_id: params[:id],
                                                      status: params[:status].presence || 'canceled')
              end
            end

            def seat
              command(status: :created) do |key|
                Spree::Pos::Reservations::Seat.call(store: current_store, staff: current_user, key: key, reservation_id: params[:id],
                                                    editor_id: params[:editor_id], guest_count: params[:guest_count])
              end
            end

            def take_deposit
              command(status: :created) do |key|
                Spree::Pos::Reservations::TakeDeposit.call(
                  store: current_store, staff: current_user, key: key, reservation_id: params[:id], kind: params[:kind],
                  amount: params[:amount], handed_amount: params[:handed_amount], reference: params[:reference],
                  receiving_account: params[:receiving_account], confirm_duplicate: params[:confirm_duplicate]
                )
              end
            end

            def refund_deposit
              command do |key|
                Spree::Pos::Reservations::RefundDeposit.call(
                  store: current_store, staff: current_user, key: key, deposit_id: params[:deposit_id],
                  beneficiary_name: params[:beneficiary_name], beneficiary_reference: params[:beneficiary_reference],
                  reason: params[:reason], approval_id: params[:approval_id]
                )
              end
            end

            def forfeit_deposit
              command do |key|
                Spree::Pos::Reservations::ForfeitDeposit.call(store: current_store, staff: current_user, key: key,
                                                              deposit_id: params[:deposit_id], approval_id: params[:approval_id])
              end
            end

            private

            def guard
              Spree::Pos::Reservations::Guard
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              params.permit(*Spree::Pos::Reservations::Create::FIELDS).to_h
            end

            # The branch's business day of `date`, or `from` / `to`; today by default.
            def window(branch)
              if params[:from].present? || params[:to].present?
                from = guard.parse!(params[:from])
                to = guard.parse!(params[:to])
                raise Spree::Pos::Conflict.new('The window is invalid.', reason: 'reservation_time_invalid') unless to > from && to - from <= 31.days

                return [from, to]
              end

              zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
              day = params[:date].present? ? Date.iso8601(params[:date].to_s) : zone.today
              start = zone.local(day.year, day.month, day.day)
              [start, start + 1.day]
            rescue Date::Error
              raise Spree::Pos::Conflict.new('The date is invalid.', reason: 'reservation_time_invalid')
            end
          end
        end
      end
    end
  end
end
