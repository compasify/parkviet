# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class UnitsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders read_pos_topology],
                            variant_units: %w[read_pos_orders read_pos_topology],
                            update_variant_unit: %w[write_pos_topology]

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise ActiveRecord::RecordNotFound unless policy.membership_for(branch) && !policy.membership_for(branch).disabled?

              Spree::Pos::UnitDefinition.ensure_defaults!(current_store)
              render json: { data: Spree::Pos::UnitDefinition.for_store(current_store).where(status: 'active').order(:code).map(&:to_pos) }
            end

            def variant_units
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise ActiveRecord::RecordNotFound unless policy.membership_for(branch) && !policy.membership_for(branch).disabled?

              Spree::Pos::UnitDefinition.ensure_defaults!(current_store)
              variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
              raise ActiveRecord::RecordNotFound if variant.nil? || variant.product.store_id != current_store.id
              raise ActiveRecord::RecordNotFound unless Spree::Pos::BranchProduct.exists?(branch: branch, product_id: variant.product_id)

              configured = Spree::Pos::VariantUnit.find_by(store: current_store, variant: variant, status: 'active')
              data = if configured
                       configured.to_pos(variant: variant)
                     else
                       unit = Spree::Pos::UnitDefinition.find_by!(store: current_store, code: 'item')
                       { variant_id: variant.prefixed_id, sale_unit: 'item', base_unit: 'item', price_unit: 'item', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1, status: 'default' }
                     end
              render json: { data: data }
            end

            def update_variant_unit
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::MANAGE)

              Spree::Pos::UnitDefinition.ensure_defaults!(current_store)
              variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
              raise ActiveRecord::RecordNotFound if variant.nil? || variant.product.store_id != current_store.id
              raise ActiveRecord::RecordNotFound unless Spree::Pos::BranchProduct.exists?(branch: branch, product_id: variant.product_id)

              sale_unit = unit!(params[:sale_unit_code] || params[:sale_unit])
              base_unit = unit!(params[:base_unit_code] || params[:base_unit] || sale_unit.code)
              price_unit = unit!(params[:price_unit_code] || params[:price_unit] || sale_unit.code)
              raise Spree::Pos::Conflict, 'Unit dimensions must match.' unless sale_unit.dimension == base_unit.dimension && (price_unit.dimension == sale_unit.dimension || price_unit.code == sale_unit.code)
              # Factors are relative to the canonical unit, so the base must be that unit.
              unless base_unit.code == base_unit.base_code && base_unit.code == sale_unit.base_code
                raise Spree::Pos::Conflict, 'Base unit must be the canonical unit of the sale unit.'
              end

              record = Spree::Pos::VariantUnit.find_or_initialize_by(store: current_store, variant: variant)
              begin
                ActiveRecord::Base.transaction do
                  configure_variant_unit!(record, variant, sale_unit, base_unit, price_unit)
                end
              rescue ActiveRecord::RecordNotUnique
                raise Spree::Pos::Conflict, 'Label code is already used by another SKU.'
              end
              audit!('variant_unit.configure', branch, variant_id: variant.prefixed_id, version: record.version, label_code: record.label_code)
              render json: { data: record.to_pos(variant: variant) }
            end

            private

            def configure_variant_unit!(record, variant, sale_unit, base_unit, price_unit)
              variant.lock!
              record.assign_attributes(sale_unit: sale_unit, base_unit: base_unit, price_unit: price_unit, ratio_numerator: ratio_value(params[:ratio_numerator], 1), ratio_denominator: ratio_value(params[:ratio_denominator], 1), tracked_mode: tracked_mode(params[:tracked_mode]), status: 'active')
              conversion_changed = record.new_record? || (record.changed - %w[updated_at]).any?
              record.label_code = params[:label_code].to_s.strip.presence if params.key?(:label_code)
              if conversion_changed
                raise Spree::Pos::Conflict, 'Unit configuration is locked after sale lines exist.' if Spree::Pos::SaleLine.where(variant_id: variant.id).exists?

                record.version = record.persisted? ? record.version + 1 : 1
              end
              if record.label_code && Spree::Pos::VariantUnit.where(store_id: current_store.id, label_code: record.label_code).where.not(id: record.id).exists?
                raise Spree::Pos::Conflict, 'Label code is already used by another SKU.'
              end
              record.save!
            end

            def unit!(code)
              unit = Spree::Pos::UnitDefinition.find_by(store: current_store, code: code.to_s)
              raise ActiveRecord::RecordNotFound if unit.nil?

              unit
            end

            def ratio_value(value, fallback)
              number = Integer(value.presence || fallback)
              raise Spree::Pos::Conflict, 'Conversion ratio is invalid.' unless number.positive? && number <= 1_000_000

              number
            rescue ArgumentError, TypeError
              raise Spree::Pos::Conflict, 'Conversion ratio is invalid.'
            end

            def tracked_mode(value)
              mode = value.to_s.presence || 'none'
              raise Spree::Pos::Conflict, 'Tracked mode is invalid.' unless %w[none serial lot serial_lot].include?(mode)

              mode
            end
          end
        end
      end
    end
  end
end
