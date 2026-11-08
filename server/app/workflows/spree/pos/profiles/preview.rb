# frozen_string_literal: true

module Spree
  module Pos
    module Profiles
      # What moving a branch to another industry profile would change, without
      # changing anything (D7): modules to turn on and off (with how much of
      # an outgoing module is in use, a warning only: turning it off never
      # stops selling what is configured, D5), branch defaults that differ
      # from the branch's current values, sample units the store lacks, and
      # recommended features that are off at the branch (a hint, D6).
      module Preview
        module_function

        def call(branch:, profile_key:)
          profile = Branches::Create.available!(BusinessProfiles.fetch!(profile_key))
          on = ModulePolicy.for_branch(branch).select { |_, value| value }.keys
          disable = on - profile.modules
          features = FeaturePolicy.for_branch(branch.store, branch)
          {
            branch_id: branch.prefixed_id,
            from: branch.profile_key,
            to: profile.key,
            profile_version: BusinessProfiles.version,
            modules: { enable: profile.modules - on, disable: disable, in_use: disable.index_with { |key| in_use(branch, key) } },
            defaults: defaults(branch, profile),
            sample_units: profile.sample_units - UnitDefinition.for_store(branch.store).where(code: profile.sample_units).pluck(:code),
            recommended_features: profile.recommended_features.reject { |feature| features[feature] }
          }
        end

        # [{ field:, current:, profile: }] for every profile default that
        # differs from the branch, in the catalog's form.
        def defaults(branch, profile)
          profile.branch_defaults.filter_map do |field, value|
            current = present(field, branch.public_send(field))
            target = present(field, value)
            { field: field, current: current, profile: target } unless current == target
          end
        end

        def present(field, value)
          return nil if value.nil?

          field == 'variance_threshold' ? BigDecimal(value.to_s).to_s('F') : value
        end

        # Configuration of the branch's assortment (and its stock) that the
        # module set up. Counts only.
        def in_use(branch, key)
          units = VariantUnit.for_store(branch.store).where(status: 'active').
                  joins(:variant).where(spree_variants: { product_id: BranchProduct.where(branch_id: branch.id).select(:product_id) })
          case key
          when 'retail.traceability'
            location = branch.stock_location_id
            { tracked_variants: units.where(tracked_mode: %w[serial lot]).count,
              open_lots: InventoryLot.where(stock_location_id: location).where('on_hand > 0').count,
              serials_in_stock: SerialUnit.where(stock_location_id: location, status: 'in_stock').count }
          when 'retail.measured'
            measured = UnitDefinition.for_store(branch.store).where(dimension: %w[mass volume]).select(:id)
            { measured_variants: units.where(sale_unit_id: measured).count,
              labelled_variants: units.where.not(label_code: nil).count,
              label_formats: LabelFormat.for_store(branch.store).where(branch_id: branch.id, status: 'active').count }
          when 'retail.units'
            { converted_variants: units.where('spree_pos_variant_units.sale_unit_id <> spree_pos_variant_units.base_unit_id OR ' \
                                              'spree_pos_variant_units.ratio_numerator <> spree_pos_variant_units.ratio_denominator').count }
          else
            {}
          end
        end
      end
    end
  end
end
