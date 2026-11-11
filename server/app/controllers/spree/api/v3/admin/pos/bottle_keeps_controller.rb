# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The bottle-keeping book of a branch: find a guest's bottle by code
          # or phone, keep a new one, pour from it, correct its level, end it
          # and print its label. No money moves here.
          class BottleKeepsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            create: %w[write_pos_orders], pour: %w[write_pos_orders], adjust: %w[write_pos_orders],
                            return_bottle: %w[write_pos_orders], expire: %w[write_pos_orders], label: %w[write_pos_orders]

            LIMIT = 50

            def index
              return if channel_rejected?

              branch = Spree::Pos::BottleKeeps::Guard.branch!(current_store, params[:branch_id])
              Spree::Pos::BottleKeeps::Guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::BottleKeep.where(branch_id: branch.id).includes(:variant, :customer_profile, :branch, photo_attachment: :blob)
              status = params[:status].presence || 'kept'
              scope = scope.where(status: status) unless status == 'all'
              scope = search(scope, params[:q].to_s.strip)
              render json: { data: scope.order(expires_on: :asc, id: :desc).limit(LIMIT).map(&:to_pos) }
            end

            def show
              return if channel_rejected?

              keep = keep!
              Spree::Pos::BottleKeeps::Guard.read!(current_store, current_user, keep.branch)
              render json: { data: keep.to_pos(with_events: true) }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::BottleKeeps::Open.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id], variant_id: params[:variant_id],
                level_percent: params[:level_percent], customer_id: params[:customer_id], guest_name: params[:guest_name],
                phone: params[:phone], source_sale_line_id: params[:source_sale_line_id], note: params[:note], photo: params[:photo]
              )
              render json: { data: result }, status: :created
            end

            def pour
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              workspace = params[:workspace_id].present? ? workspace!(params[:workspace_id]) : nil
              result = Spree::Pos::BottleKeeps::Pour.call(
                store: current_store, staff: current_user, key: key, keep_id: params[:id], level_percent: params[:level_percent],
                ml: params[:ml], workspace: workspace, photo: params[:photo], note: params[:note]
              )
              render json: { data: result }
            end

            def adjust
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::BottleKeeps::Adjust.call(
                store: current_store, staff: current_user, key: key, keep_id: params[:id], level_percent: params[:level_percent],
                note: params[:note], revision: params[:expected_revision], approval_id: params[:approval_id]
              )
              render json: { data: result }
            end

            def return_bottle
              close('return')
            end

            def expire
              close('expire')
            end

            def label
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::BottleKeeps::Label.call(store: current_store, staff: current_user, key: key, keep_id: params[:id],
                                                           printer_id: params[:printer_id])
              render json: { data: result }
            end

            private

            def close(kind)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::BottleKeeps::Close.call(store: current_store, staff: current_user, key: key, keep_id: params[:id],
                                                           kind: kind, note: params[:note])
              render json: { data: result }
            end

            def keep!
              Spree::Pos::BottleKeeps::Guard.keep_record!(current_store, params[:id])
            end

            # By the label's code, the guest's phone or name.
            def search(scope, query)
              return scope if query.empty?

              code = query.upcase.delete('^A-Z0-9')
              digits = Spree::Pos::CustomerProfile.normalize_phone(query).gsub(/\D/, '')
              pattern = "%#{Spree::Pos::BottleKeep.sanitize_sql_like(query.downcase)}%"
              conditions = scope.where('LOWER(spree_pos_bottle_keeps.guest_name) LIKE ?', pattern)
              conditions = conditions.or(scope.where(code: code)) if code.present?
              conditions = conditions.or(scope.where('spree_pos_bottle_keeps.phone LIKE ?', "%#{digits}%")) if digits.length >= 3
              conditions
            end
          end
        end
      end
    end
  end
end