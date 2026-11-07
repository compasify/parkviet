# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Lots at a branch's stock location (manage or trace readers), and
          # quarantine/release by inventory managers.
          class LotsController < BaseController
            scoped_resource :pos_orders

            STATUSES = %w[active quarantined expired].freeze

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              readers = [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::INVENTORY_TRACE]
              raise CanCan::AccessDenied unless readers.any? { |capability| policy.allows?(branch, capability) }

              today = Spree::Pos::StockIntegration.today(branch)
              scope = Spree::Pos::InventoryLot.for_store(current_store).where(stock_location_id: branch.stock_location_id).
                      includes(:source_lot, :stock_location, variant: :product)
              if params[:variant_id].present?
                variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
                raise ActiveRecord::RecordNotFound if variant.nil?

                scope = scope.where(variant_id: variant.id)
              end
              scope = scope.where('lot_code ILIKE ?', "#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.strip)}%") if params[:q].present?
              scope = filter_status(scope, params[:status].to_s, today) if params[:status].present?
              records, meta = page_scope(scope.order(Arel.sql('expiry_on ASC NULLS LAST'), :id))
              render json: { data: records.map { |lot| lot.to_pos(today: today) }, meta: meta }
            end

            def quarantine
              change(release: false)
            end

            def release
              change(release: true)
            end

            private

            def change(release:)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Inventory::Quarantine.lot(store: current_store, staff: current_user, key: key, lot_id: params[:id],
                                                           reason: params[:reason], release: release)
              render json: { data: data }
            end

            def filter_status(scope, status, today)
              raise Spree::Pos::Conflict, 'Status filter is invalid.' unless STATUSES.include?(status)

              case status
              when 'quarantined' then scope.where(status: 'quarantined')
              when 'expired' then scope.where(status: 'expired').or(scope.where(status: 'active').where(expiry_on: ...today))
              else scope.where(status: 'active').where('expiry_on IS NULL OR expiry_on >= ?', today)
              end
            end
          end
        end
      end
    end
  end
end
