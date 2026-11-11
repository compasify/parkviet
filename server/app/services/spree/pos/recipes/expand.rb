# frozen_string_literal: true

module Spree
  module Pos
    module Recipes
      # What one sale line uses, in stock units, from three sources:
      # - the active recipe of the line's variant × the line quantity (`variant`);
      # - for each option picked, its recipe × picks × line quantity
      #   (`modifier:<option id>`);
      # - for each combo part, its variant's recipe × part quantity × line
      #   quantity (`component:<variant id>`).
      # An option or combo part without a recipe that names a stocked variant
      # uses one stock unit of that variant per pick or part (a bottled drink
      # in a combo, an egg topping). Lines read the copies taken at the time of
      # sale, so later menu edits never change what a line used.
      module Expand
        Entry = Data.define(:ingredient_variant_id, :base_quantity, :base_unit_code, :source_key, :recipe)
        # ml poured from bottles of a variant, each bottle bottle_ml big.
        Pour = Data.define(:variant_id, :ml, :bottle_ml)

        module_function

        # `recipes` memoizes active recipes by [owner_type, owner_id] across lines.
        def call(sale_line, recipes: {})
          quantity = sale_line.base_quantity
          entries = from_owner(recipes, 'Spree::Variant', sale_line.variant_id, quantity, 'variant')
          sale_line.line_modifiers.each do |pick|
            option = pick.modifier_option
            next if option.nil?

            key = "modifier:#{option.prefixed_id}"
            found = from_owner(recipes, 'Spree::Pos::ModifierOption', option.id, pick.quantity * quantity, key)
            found = direct(sale_line, option.variant_id, pick.quantity * quantity, key) if found.empty? && option.variant_id
            entries.concat(found)
          end
          sale_line.line_components.each do |part|
            key = "component:#{part.variant.prefixed_id}"
            found = from_owner(recipes, 'Spree::Variant', part.variant_id, part.quantity * quantity, key)
            found = direct(sale_line, part.variant_id, part.quantity * quantity, key) if found.empty?
            entries.concat(found)
          end
          merge(entries)
        end

        def from_owner(recipes, owner_type, owner_id, times, source_key)
          recipe = active_recipe(recipes, owner_type, owner_id)
          return [] if recipe.nil?

          recipe.recipe_ingredients.reject(&:pour?).map do |row|
            Entry.new(ingredient_variant_id: row.ingredient_variant_id, base_quantity: row.base_quantity * times,
                      base_unit_code: row.base_unit_code, source_key: source_key, recipe: recipe)
          end
        end

        def direct(sale_line, variant_id, times, source_key)
          variant = Spree::Variant.with_deleted.find(variant_id)
          # A part made to order (a menu size without a recipe) keeps no shelf.
          return [] unless variant.track_inventory?

          store = sale_line.workspace.store
          [Entry.new(ingredient_variant_id: variant_id, base_quantity: times, base_unit_code: Recipes.base_unit(store, variant).code,
                     source_key: source_key, recipe: nil)]
        end

        # The measured pours of a line, from the same three sources, summed by bottle variant.
        def pours(sale_line, recipes: {})
          quantity = sale_line.base_quantity
          owners = [['Spree::Variant', sale_line.variant_id, quantity]]
          sale_line.line_modifiers.each do |pick|
            owners << ['Spree::Pos::ModifierOption', pick.modifier_option_id, pick.quantity * quantity] if pick.modifier_option_id
          end
          sale_line.line_components.each { |part| owners << ['Spree::Variant', part.variant_id, part.quantity * quantity] }
          rows = owners.flat_map do |owner_type, owner_id, times|
            recipe = active_recipe(recipes, owner_type, owner_id)
            next [] if recipe.nil?

            recipe.recipe_ingredients.select(&:pour?).map { |row| [row.ingredient_variant_id, row.pour_ml * times, row.bottle_ml] }
          end
          rows.group_by(&:first).map { |variant_id, list| Pour.new(variant_id: variant_id, ml: list.sum { |row| row[1] }, bottle_ml: list.first[2]) }
        end

        def active_recipe(recipes, owner_type, owner_id)
          recipes.fetch([owner_type, owner_id]) do
            recipes[[owner_type, owner_id]] = Recipe.active.includes(:recipe_ingredients).find_by(owner_type: owner_type, owner_id: owner_id)
          end
        end

        # Two picks of one source naming the same ingredient are one row.
        def merge(entries)
          entries.group_by { |entry| [entry.ingredient_variant_id, entry.source_key] }.map do |_, rows|
            rows.first.with(base_quantity: rows.sum(&:base_quantity))
          end
        end
      end
    end
  end
end
