# frozen_string_literal: true

module Spree
  module Pos
    module Recipes
      # Takes what a completed sale used off the branch shelf. Runs inside
      # Workspaces::Complete, after placement, while `fnb.recipes` is on at
      # the branch, and writes nothing a second time: a workspace that has
      # consumptions is skipped, and the unique (line, ingredient, source)
      # index backs that up.
      #
      # Spree refuses a stock correction that leaves a shelf below zero, so
      # each ingredient comes off down to zero at most. Whatever the shelf
      # could not cover never stops the sale: it is kept as an open stock
      # discrepancy (`source = 'recipe'`) for the next count. Ingredients are
      # summed first and their stock rows locked in variant id order, so two
      # counters completing at once wait for each other instead of deadlocking.
      # Going below a branch's alert threshold records `stock.low`.
      module Consume
        REASON = 'POS recipe consumption'

        module_function

        def call(workspace:, actor:)
          branch = workspace.branch
          return [] unless ModulePolicy.enabled?(branch, MODULE)
          return [] if RecipeConsumption.exists?(workspace_id: workspace.id)

          rows = consumption_rows!(workspace)
          return [] if rows.empty?

          location = branch.stock_location
          needed = rows.group_by(&:ingredient_variant_id).transform_values { |list| list.sum(&:base_quantity) }
          variants = Spree::Variant.with_deleted.where(id: needed.keys).index_by(&:id)
          needed.keys.sort.each do |variant_id|
            take!(workspace, actor, location, variants.fetch(variant_id), needed[variant_id])
          end
          rows
        end

        def consumption_rows!(workspace)
          lines = SaleLine.where(workspace_id: workspace.id).order(:id).
                  includes(line_modifiers: :modifier_option, line_components: :variant).to_a
          recipes = {}
          costs = {}
          lines.flat_map do |line|
            Expand.call(line, recipes: recipes).map do |entry|
              variant_id = entry.ingredient_variant_id
              cost = costs.fetch(variant_id) { costs[variant_id] = Recipes.unit_cost(workspace.store_id, Spree::Variant.with_deleted.find(variant_id)) }
              RecipeConsumption.create!(
                store_id: workspace.store_id, branch_id: workspace.branch_id, workspace: workspace, order_id: workspace.order_id,
                sale_line: line, ingredient_variant_id: variant_id, stock_location_id: workspace.branch.stock_location_id,
                base_quantity: entry.base_quantity, base_unit_code: entry.base_unit_code, recipe: entry.recipe,
                recipe_version: entry.recipe&.version, source_key: entry.source_key, unit_cost: cost,
                business_date: workspace.business_date
              )
            end
          end
        end

        # Variants that keep no shelf of their own are recorded but not moved.
        def take!(workspace, actor, location, variant, quantity)
          return unless variant.should_track_inventory?

          level = Spree::StockLevel.where(variant_id: variant.id, stock_location_id: location.id).lock.first
          on_hand = level&.count_on_hand || 0
          taken = quantity.clamp(0, [on_hand, 0].max)
          StockIntegration.adjust!(location, variant, -taken, "#{REASON} #{workspace.order.number}") if taken.positive?
          record_shortfall!(workspace, actor, location, variant, quantity, on_hand) if taken < quantity
          alert_low!(workspace, actor, variant, on_hand, on_hand - taken)
        end

        def record_shortfall!(workspace, actor, location, variant, quantity, on_hand)
          fulfillment = workspace.order.fulfillments.order(:id).first
          StockDiscrepancy.create!(
            store_id: workspace.store_id, branch_id: workspace.branch_id, workspace: workspace, order_id: workspace.order_id,
            fulfillment: fulfillment, variant: variant, stock_location: location, actor: actor, needed: quantity,
            on_hand: on_hand, status: 'open', source: 'recipe', checked_at: Time.current
          )
        end

        def alert_low!(workspace, actor, variant, before, after)
          alert = StockAlert.find_by(branch_id: workspace.branch_id, variant_id: variant.id)
          return if alert.nil? || after >= alert.min_quantity || before < alert.min_quantity

          AuditEntry.record!(store: workspace.store, actor: actor, action: 'stock.low', subject: alert,
                             metadata: { branch_id: workspace.branch.prefixed_id, variant_id: variant.prefixed_id,
                                         on_hand: after, min_quantity: alert.min_quantity, order_id: workspace.order.prefixed_id })
        end
      end
    end
  end
end
