# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class UnitsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders read_pos_topology write_pos_topology],
                            variant_units: %w[read_pos_orders read_pos_topology],
                            update_variant_unit: %w[write_pos_topology],
                            create: %w[write_pos_topology], update: %w[write_pos_topology],
                            disable: %w[write_pos_topology], enable: %w[write_pos_topology]

            Unit = Spree::Pos::UnitDefinition

            # With `branch_id`, the units an active member of that branch sells
            # with; without one, the store's units for topology readers.
            # `include_disabled=true` adds disabled units.
            def index
              return if channel_rejected?

              if params[:branch_id].present?
                branch = branch!(params[:branch_id])
                raise ActiveRecord::RecordNotFound unless policy.membership_for(branch) && !policy.membership_for(branch).disabled?
              elsif !topology_reader?
                raise CanCan::AccessDenied
              end

              Unit.ensure_defaults!(current_store)
              scope = Unit.for_store(current_store)
              scope = scope.active unless ActiveModel::Type::Boolean.new.cast(params[:include_disabled]) == true
              render json: { data: scope.order(:code).map(&:to_pos) }
            end

            def create
              return if channel_rejected?

              Unit.ensure_defaults!(current_store)
              unit = Unit.create!(store: current_store, status: 'active', version: 1, **unit_params(Unit::STRUCTURAL + %w[name sale_precision]))
              audit!('unit.create', unit, unit.to_pos)
              render json: { data: unit.to_pos }, status: :created
            rescue ActiveRecord::RecordNotUnique
              raise Spree::Pos::Conflict, 'Another unit uses this code.'
            end

            # Only the name and the sale precision change; what a quantity
            # means (code, dimension, conversion) is fixed.
            def update
              return if channel_rejected?

              unit = store_unit!(params[:id])
              changed = Unit::STRUCTURAL.select { |key| params.key?(key) && params[key].to_s != unit.public_send(key).to_s }
              raise Spree::Pos::Conflict, 'Unit code, dimension and conversion cannot change.' if changed.any?

              unit.with_lock do
                unit.assign_attributes(unit_params(%w[name sale_precision]))
                if unit.changed?
                  unit.version += 1
                  unit.save!
                  audit!('unit.update', unit, unit.to_pos)
                end
              end
              render json: { data: unit.to_pos }
            end

            def disable
              unit = store_unit!(params[:id])
              unit.with_lock do
                unless unit.disabled?
                  blocker = unit.disable_blocker
                  raise Spree::Pos::Conflict.new(blocker, reason: 'unit_in_use') if blocker

                  unit.update!(status: 'disabled')
                  audit!('unit.disable', unit, unit.to_pos)
                end
              end
              render json: { data: unit.to_pos }
            end

            def enable
              unit = store_unit!(params[:id])
              unit.with_lock do
                if unit.disabled?
                  unit.update!(status: 'active')
                  audit!('unit.enable', unit, unit.to_pos)
                end
              end
              render json: { data: unit.to_pos }
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
              # Starting to track a SKU by serial or lot is a traceability
              # entry; stopping or keeping the current mode is not. The mode is
              # store-wide, so it needs the store default on, not one branch.
              mode = tracked_mode(params[:tracked_mode])
              Spree::Pos::FeaturePolicy.require_store!(current_store, :traceability) if mode != 'none' && mode != record.tracked_mode
              require_setup_modules!(branch, record, mode, [sale_unit, base_unit, price_unit])
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

            # Module gates (D5) for what this request newly sets up at the
            # branch, compared with the stored configuration: starting serial
            # or lot tracking (retail.traceability); a conversion other than
            # the base unit at 1:1 (retail.units); switching to a mass or
            # volume sale unit, or a new scale label code (retail.measured).
            # Keeping a value, or narrowing back to `none` or to the base unit
            # at 1:1, or clearing the label code, never needs a module.
            def require_setup_modules!(branch, record, mode, units)
              sale_unit, base_unit, price_unit = units
              stored = record.persisted? ? record : nil
              Spree::Pos::ModulePolicy.require!(branch, 'retail.traceability') if mode != 'none' && mode != (stored&.tracked_mode || 'none')

              numerator = ratio_value(params[:ratio_numerator], 1)
              denominator = ratio_value(params[:ratio_denominator], 1)
              converted = sale_unit.id != base_unit.id || numerator != denominator
              conversion_changed = stored.nil? || [stored.sale_unit_id, stored.base_unit_id, stored.price_unit_id, stored.ratio_numerator,
                                                   stored.ratio_denominator] != [sale_unit.id, base_unit.id, price_unit.id, numerator, denominator]
              Spree::Pos::ModulePolicy.require!(branch, 'retail.units') if converted && conversion_changed

              measured = Spree::Pos::UnitDefinition::DIMENSIONS.excluding('count')
              was_measured = stored && measured.include?(stored.sale_unit&.dimension)
              label = params.key?(:label_code) ? params[:label_code].to_s.strip.presence : nil
              new_label = label.present? && label != stored&.label_code
              entering = measured.include?(sale_unit.dimension) && !was_measured
              Spree::Pos::ModulePolicy.require!(branch, 'retail.measured') if entering || new_label
            end

            def configure_variant_unit!(record, variant, sale_unit, base_unit, price_unit)
              variant.lock!
              record.assign_attributes(sale_unit: sale_unit, base_unit: base_unit, price_unit: price_unit, ratio_numerator: ratio_value(params[:ratio_numerator], 1), ratio_denominator: ratio_value(params[:ratio_denominator], 1), tracked_mode: tracked_mode(params[:tracked_mode]), status: 'active')
              conversion_changed = record.new_record? || (record.changed - %w[updated_at]).any?
              record.label_code = params[:label_code].to_s.strip.presence if params.key?(:label_code)
              if conversion_changed
                raise Spree::Pos::Conflict, 'Unit configuration is locked after sale lines exist.' if Spree::Pos::SaleLine.where(variant_id: variant.id).exists?
                # Stock counted in the old base unit or tracked by serial/lot
                # would be read wrongly under a new conversion or mode.
                conversion_fields = record.changed & %w[sale_unit_id base_unit_id price_unit_id ratio_numerator ratio_denominator]
                if typed_stock?(variant) || (record.persisted? && conversion_fields.any? && converted_stock?(record, variant))
                  raise Spree::Pos::Conflict.new('Unit configuration is locked while tracked or converted stock exists.',
                                                 reason: 'trace_stock_exists')
                end

                record.version = record.persisted? ? record.version + 1 : 1
              end
              if record.label_code && Spree::Pos::VariantUnit.where(store_id: current_store.id, label_code: record.label_code).where.not(id: record.id).exists?
                raise Spree::Pos::Conflict, 'Label code is already used by another SKU.'
              end
              record.save!
            end

            def typed_stock?(variant)
              Spree::Pos::TraceEnrollment.exists?(variant_id: variant.id) || Spree::Pos::InventoryLot.exists?(variant_id: variant.id) ||
                Spree::Pos::SerialUnit.exists?(variant_id: variant.id)
            end

            # A shelf counted in a base unit other than the item itself.
            def converted_stock?(record, variant)
              was_converted = record.base_unit_id_was != record.sale_unit_id_was || record.ratio_numerator_was != record.ratio_denominator_was
              was_converted && Spree::StockLevel.where(variant_id: variant.id).where.not(count_on_hand: 0).exists?
            end

            def unit!(code)
              unit = Spree::Pos::UnitDefinition.find_by(store: current_store, code: code.to_s)
              raise ActiveRecord::RecordNotFound if unit.nil?
              raise Spree::Pos::Conflict, 'Unit is disabled.' if unit.disabled?

              unit
            end

            def store_unit!(prefixed)
              unit = Unit.locate(Unit.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if unit.nil?

              unit
            end

            def unit_params(keys)
              keys.select { |key| params.key?(key) }.to_h { |key| [key.to_sym, params[key]] }
            end

            def topology_reader?
              policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology')
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
              raise Spree::Pos::Conflict, 'Tracked mode is invalid.' unless %w[none serial lot].include?(mode)

              mode
            end
          end
        end
      end
    end
  end
end
