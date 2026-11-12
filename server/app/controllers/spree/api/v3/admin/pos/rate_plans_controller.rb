# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's prices of play time (`branch_id`): rate plans by kind of
          # room with their time bands, a priced preview of a stay, the
          # branch's holidays, its weekend days, its operating hours and pause
          # limit.
          class RatePlansController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], preview: %w[read_pos_orders write_pos_orders],
                            special_days: %w[read_pos_orders write_pos_orders]

            def index
              return if channel_rejected?

              branch = branch!
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::RatePlan.for_store(current_store).where(branch_id: branch.id).
                      includes(:branch, :rate_rules, variant: %i[product tax_category]).order(:status, :resource_type_code, version: :desc)
              scope = scope.where(status: params[:status].to_s) if params[:status].present?
              records, meta = page_scope(scope)
              render json: { data: records.map(&:to_pos), meta: meta.merge(branch_id: branch.prefixed_id, weekend_days: branch.weekend_days,
                                                                    operating_windows: branch.operating_windows,
                                                                    max_pause_minutes: branch.max_pause_minutes) }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::Timed::SaveRatePlan.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                     attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::Timed::SaveRatePlan.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                     attributes: attributes, rate_plan_id: params[:id])
              end
            end

            # What a stay from `started_at` to `ended_at` would cost on this
            # plan at the branch, with nothing written.
            def preview
              return if channel_rejected?

              branch = branch!
              guard.read!(current_store, current_user, branch)
              plan = Spree::Pos::RatePlan.locate(Spree::Pos::RatePlan.for_store(current_store).where(branch_id: branch.id), params[:id]) ||
                     raise(ActiveRecord::RecordNotFound)
              starts = guard.time!(params[:started_at], 'started_at')
              ends = guard.time!(params[:ended_at], 'ended_at')
              if starts.nil? || ends.nil? || ends <= starts || ends - starts > 3.days
                raise Spree::Pos::Conflict.new('Give a start and an end within three days.', reason: 'time_invalid')
              end

              book = Spree::Pos::Timed::RateBook.new(branch, plan_ids: [plan.id], from: starts, to: ends)
              stretch = Spree::Pos::Timed::Quote::Stretch.new(segment: PreviewSegment.new(0, nil), starts_at: starts, ends_at: ends,
                                                              plan: book.plan(plan.id))
              quote = Spree::Pos::Timed::Quote.compute(stretches: [stretch], timezone: branch.timezone, weekend_days: branch.weekend_days,
                                                       special_days: book.special_days, currency: current_store.default_currency, as_of: ends)
              render json: { data: quote.to_pos.merge(rate_plan_id: plan.prefixed_id, currency: current_store.default_currency) }
            end

            def special_days
              return if channel_rejected?

              branch = branch!
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::SpecialDay.for_store(current_store).where(branch_id: branch.id).includes(:branch).order(:date)
              scope = scope.where(date: Date.iso8601(params[:from].to_s)..) if params[:from].present?
              records, meta = page_scope(scope)
              render json: { data: records.map(&:to_pos), meta: meta.merge(branch_id: branch.prefixed_id) }
            rescue Date::Error
              raise Spree::Pos::Conflict.new('Dates use YYYY-MM-DD.', reason: 'date_invalid')
            end

            def create_special_day
              command(status: :created) do |key|
                Spree::Pos::Timed::SaveSpecialDay.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                       attributes: special_day_attributes)
              end
            end

            def update_special_day
              command do |key|
                Spree::Pos::Timed::SaveSpecialDay.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                       attributes: special_day_attributes, special_day_id: params[:special_day_id])
              end
            end

            def destroy_special_day
              command do |key|
                Spree::Pos::Timed::SaveSpecialDay.remove(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                         special_day_id: params[:special_day_id])
              end
            end

            def update_weekend_days
              command do |key|
                Spree::Pos::Timed::SaveSpecialDay.weekend_days(store: current_store, staff: current_user, key: key,
                                                               branch_id: params[:branch_id], days: params[:weekend_days])
              end
            end

            # Operating hours and the pause limit of the branch's play time.
            def update_timed_settings
              command do |key|
                Spree::Pos::Timed::SaveSettings.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                     operating_windows: params.key?(:operating_windows) ? Array(params[:operating_windows]) : nil,
                                                     max_pause_minutes: params[:max_pause_minutes])
              end
            end

            # A preview has no stored segment.
            PreviewSegment = Struct.new(:id, :prefixed_id)

            private

            def guard
              Spree::Pos::Timed::Guard
            end

            def branch!
              guard.branch!(current_store, params[:branch_id])
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              values = params.permit(*Spree::Pos::Timed::SaveRatePlan::FIELDS).to_h
              if params.key?(:rules)
                values['rules'] = Array(params[:rules]).map do |row|
                  row.respond_to?(:permit) ? row.permit(*Spree::Pos::Timed::SaveRatePlan::RULE_FIELDS).to_h : row
                end
              end
              if params.key?(:packages)
                values['packages'] = Array(params[:packages]).map { |row| row.respond_to?(:permit) ? row.permit(:code, :name, :minutes, :price).to_h : row }
              end
              values
            end

            def special_day_attributes
              params.permit(:date, :name, :holiday_surcharge_percent).to_h
            end
          end
        end
      end
    end
  end
end
