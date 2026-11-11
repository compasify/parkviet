# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Delivery platform orders typed in at the counter: entering one,
          # marking it ready, handing it to the driver (which completes the
          # sale), canceling it, and settling what the platforms paid.
          class PlatformOrdersController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], settle: %w[write_pos_orders write_pos_topology]

            FILTERS = {
              'open' => { status: Spree::Pos::PlatformOrder::OPEN },
              'completed' => { status: 'completed' },
              'canceled' => { status: 'canceled' },
              'unsettled' => { status: 'completed', settled_at: nil }
            }.freeze

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              guard.read!(current_store, current_user, branch)
              filter = params[:status].presence || 'open'
              return invalid!('Unknown status filter.') unless FILTERS.key?(filter)

              platform = params[:platform].presence
              return invalid!('Unknown platform.') if platform && Spree::Pos::PlatformSetting::PLATFORMS.exclude?(platform)

              from = date(params[:from])
              to = date(params[:to])
              return invalid!('Dates use YYYY-MM-DD.') if from == false || to == false

              scope = Spree::Pos::PlatformOrder.where(branch_id: branch.id).where(FILTERS[filter])
              scope = scope.where(platform: platform) if platform
              # Business dates of the sale, both ends included.
              scope = scope.joins(:workspace).where(spree_pos_workspaces: { business_date: from.. }) if from
              scope = scope.joins(:workspace).where(spree_pos_workspaces: { business_date: ..to }) if to
              records, meta = page_scope(scope.includes(workspace: :order).order(id: filter == 'open' ? :asc : :desc))
              render json: { data: records.map(&:to_pos), meta: meta }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::PlatformOrders::Enter.call(
                store: current_store, staff: current_user, key: key, editor_id: params[:editor_id],
                register_id: params[:register_id], branch_id: params[:branch_id], platform: params[:platform],
                platform_order_ref: params[:platform_order_ref], pickup_code: params[:pickup_code], note: params[:note],
                lines: params[:lines].is_a?(Array) ? params[:lines] : []
              )
              render json: { data: result }, status: :created
            end

            def ready
              command { |order, key| Spree::Pos::PlatformOrders::MarkReady.call(platform_order: order, staff: current_user, key: key) }
            end

            def complete
              command do |order, key|
                Spree::Pos::PlatformOrders::Complete.call(platform_order: order, staff: current_user, key: key,
                                                          editor_id: params[:editor_id])
              end
            end

            def cancel
              command do |order, key|
                Spree::Pos::PlatformOrders::Cancel.call(platform_order: order, staff: current_user, key: key,
                                                        editor_id: params[:editor_id], reason: params[:reason],
                                                        approval_id: params[:approval_id])
              end
            end

            def settle
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              branch = branch!(params[:branch_id])
              result = Spree::Pos::PlatformOrders::Settle.call(
                store: current_store, staff: current_user, key: key, branch: branch,
                orders: params[:orders].is_a?(Array) ? params[:orders] : [], reference: params[:reference]
              )
              render json: { data: result['orders'] }
            end

            private

            def guard
              Spree::Pos::PlatformOrders::Guard
            end

            # A counter command on one order the staff member can see.
            def command
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              order = Spree::Pos::PlatformOrder.locate(Spree::Pos::PlatformOrder.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if order.nil? || !visible_workspaces.exists?(id: order.workspace_id)

              render json: { data: yield(order, key) }
            end

            # nil when absent, false when not a YYYY-MM-DD date.
            def date(value)
              return nil if value.blank?

              Date.iso8601(value.to_s)
            rescue Date::Error
              false
            end

            def invalid!(message)
              render_error(code: 'parameter_invalid', message: message, status: :unprocessable_content)
            end
          end
        end
      end
    end
  end
end
