# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Serial lookup at a branch's stock location (manage or trace
          # readers), and quarantine/release by inventory managers.
          class SerialUnitsController < BaseController
            scoped_resource :pos_orders

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              readers = [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::INVENTORY_TRACE]
              raise CanCan::AccessDenied unless readers.any? { |capability| policy.allows?(branch, capability) }

              scope = Spree::Pos::SerialUnit.for_store(current_store).where(stock_location_id: branch.stock_location_id).
                      includes(:stock_location, variant: :product)
              if params[:variant_id].present?
                variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
                raise ActiveRecord::RecordNotFound if variant.nil?

                scope = scope.where(variant_id: variant.id)
              end
              scope = scope.where('serial ILIKE ?', "#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.strip)}%") if params[:q].present?
              if params[:status].present?
                raise Spree::Pos::Conflict, 'Status filter is invalid.' unless Spree::Pos::SerialUnit::STATUSES.include?(params[:status].to_s)

                scope = scope.where(status: params[:status].to_s)
              end
              render_page(scope.order(:serial))
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

              data = Spree::Pos::Inventory::Quarantine.serial(store: current_store, staff: current_user, key: key,
                                                              serial_unit_id: params[:id], reason: params[:reason], release: release)
              render json: { data: data }
            end
          end
        end
      end
    end
  end
end
