# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's timed promotions (`branch_id`): free minutes after a
          # time played or with a prepaid package, by kind of room and time
          # of the week.
          class TimedPromotionsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders]

            def index
              return if channel_rejected?

              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::TimedPromotion.for_store(current_store).where(branch_id: branch.id).includes(:branch).order(:status, :id)
              scope = scope.where(status: params[:status].to_s) if params[:status].present?
              records, meta = page_scope(scope)
              render json: { data: records.map(&:to_pos), meta: meta.merge(branch_id: branch.prefixed_id) }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::Timed::SavePromotion.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                      attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::Timed::SavePromotion.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                      attributes: attributes, promotion_id: params[:id])
              end
            end

            private

            def guard
              Spree::Pos::Timed::Guard
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              values = params.permit(:name, :kind, :threshold_minutes, :bonus_minutes, :status).to_h
              values['resource_kinds'] = Array(params[:resource_kinds]).map(&:to_s) if params.key?(:resource_kinds)
              if params.key?(:active_windows)
                values['active_windows'] = Array(params[:active_windows]).map do |row|
                  row.respond_to?(:permit) ? row.permit(:from, :to, days: []).to_h : row
                end
              end
              values
            end
          end
        end
      end
    end
  end
end
