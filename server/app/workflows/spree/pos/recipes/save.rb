# frozen_string_literal: true

module Spree
  module Pos
    module Recipes
      # Saves the recipe of a menu size or a modifier option as a new version
      # and retires the previous one; an empty list retires the recipe. Each
      # ingredient is checked once here: not tracked by serial or lot, and
      # its quantity a whole number of the ingredient's stock unit.
      #
      # A size with a recipe is made from its ingredients, so it stops
      # tracking its own stock. Spree then writes off what its shelf still
      # shows, so a size with stock on hand needs `confirm_stock_write_off`
      # (409 `recipe_variant_has_stock` otherwise). Audited as `recipe.change`.
      module Save
        module_function

        def call(store:, staff:, key:, owner:, ingredients:, confirm_stock_write_off: false)
          rows = rows!(ingredients)
          confirm = confirm_stock_write_off == true
          payload = { 'command' => 'recipe.save', 'owner_type' => Recipes.owner_type(owner), 'owner_id' => owner.prefixed_id,
                      'ingredients' => rows, 'confirm_stock_write_off' => confirm }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Recipes.manage!(store, staff) }) do
            ModulePolicy.require_store!(store, MODULE)
            parsed = rows.map { |row| ingredient!(store, owner, row) }
            if parsed.map { |row| row[:variant].id }.uniq.size != parsed.size
              raise Conflict.new('An ingredient is listed twice.', reason: 'recipe_ingredient_duplicate')
            end

            owner.lock!
            current = Recipe.for_owner(owner).active.first
            written_off = parsed.any? && owner.is_a?(Spree::Variant) ? stop_tracking!(owner, confirm) : 0
            current&.update!(active: false)
            version = parsed.any? ? create_version!(store, staff, owner, parsed) : nil
            AuditEntry.record!(store: store, actor: staff, action: 'recipe.change', subject: version || current || owner,
                               metadata: { owner_type: Recipes.owner_type(owner), owner_id: owner.prefixed_id,
                                           version: version&.version, retired: current&.version,
                                           ingredients: parsed.map { |row| row[:variant].prefixed_id },
                                           stock_written_off: written_off })
            Recipes.present(store, owner.reload)
          end
        end

        def rows!(value)
          rows = Array(value)
          raise Conflict.new('Too many ingredients.', reason: 'recipe_rows_limit') if rows.size > MAX_INGREDIENTS
          raise Conflict, 'Ingredients are invalid.' unless rows.all? { |row| row.respond_to?(:to_h) }

          rows.map do |row|
            row = row.to_h.stringify_keys
            entry = { 'variant_id' => row['variant_id'].to_s, 'quantity' => row['quantity'].to_s.strip, 'unit_code' => row['unit_code'].to_s }
            entry['bottle_ml'] = row['bottle_ml'].to_s.strip if row['bottle_ml'].present?
            entry
          end
        end

        def ingredient!(store, owner, row)
          variant = Spree::Variant.find_by_prefix_id(row['variant_id'])
          raise ActiveRecord::RecordNotFound if variant.nil? || variant.product&.store_id != store.id
          raise Conflict.new('A recipe cannot use what it makes.', reason: 'recipe_ingredient_self') if variant == owner

          if StockIntegration.tracked_mode(store.id, variant) != 'none'
            raise Conflict.new("#{variant.sku.presence || variant.product.name} is tracked by serial or lot.",
                               reason: 'recipe_ingredient_tracked', details: { variant_id: variant.prefixed_id })
          end

          quantity = UnitNormalizer.parse_decimal(row['quantity'])
          raise Conflict.new('Quantity is invalid.', reason: 'recipe_quantity_invalid') if quantity.nil? || !quantity.positive? ||
            quantity >= 100_000_000 ||
            (quantity * 10_000).denominator != 1

          parsed = { variant: variant, quantity: BigDecimal(row['quantity']), unit_code: row['unit_code'].strip.downcase }
          pour = Recipes.pour_quantity(store, variant, quantity, row['unit_code'], row['bottle_ml'])
          return parsed.merge(pour) if pour

          base_quantity, base_unit_code = Recipes.base_quantity(store, variant, quantity, row['unit_code'])
          parsed.merge(base_quantity: base_quantity, base_unit_code: base_unit_code)
        end

        # Returns what Spree will write off after commit, in stock units.
        def stop_tracking!(variant, confirm)
          return 0 unless variant.track_inventory?

          on_hand = Spree::StockLevel.where(variant_id: variant.id).sum(:count_on_hand)
          if on_hand.positive? && !confirm
            raise Conflict.new('This size still has stock on hand; saving its recipe writes that stock off.',
                               reason: 'recipe_variant_has_stock', details: { on_hand: on_hand })
          end

          variant.update!(track_inventory: false)
          [on_hand, 0].max
        end

        def create_version!(store, staff, owner, parsed)
          number = Recipe.for_owner(owner).maximum(:version).to_i + 1
          recipe = Recipe.create!(store: store, owner: owner, version: number, active: true, created_by: staff)
          parsed.each do |row|
            recipe.recipe_ingredients.create!(ingredient_variant: row[:variant], quantity: row[:quantity], unit_code: row[:unit_code],
                                              base_quantity: row[:base_quantity], base_unit_code: row[:base_unit_code],
                                              pour_ml: row[:pour_ml], bottle_ml: row[:bottle_ml])
          end
          recipe
        end
      end
    end
  end
end
