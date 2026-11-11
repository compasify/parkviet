# frozen_string_literal: true

module Spree
  module Pos
    module Fnb
      # Measured pours (module `fnb.pour_tracking`). A recipe row may take ml
      # from a bottle counted by the bottle (Recipes.pour_quantity). When a
      # sale completes, after its recipe ingredients left the shelf, each line
      # pours its ml into the branch's open bottle of that variant, oldest
      # open bottle first; with none open, the next bottle is opened for it.
      # A bottle that runs dry is finished and one bottle leaves the shelf
      # through the same stock path as recipe ingredients (a short shelf is
      # recorded, never a reason to refuse the sale). The rest of the pour
      # moves on to the next bottle.
      #
      # Runs once per sale: a workspace that has pours is skipped, and the
      # unique (line, bottle) index backs that up.
      module PourTracker
        MODULE = 'fnb.pour_tracking'

        module_function

        def call(workspace:, actor:)
          branch = workspace.branch
          return [] unless ModulePolicy.enabled?(branch, MODULE)
          return [] if PourEvent.exists?(workspace_id: workspace.id)

          recipes = {}
          lines = SaleLine.where(workspace_id: workspace.id).order(:id).includes(:line_modifiers, :line_components).to_a
          # One pour per line and bottle: a line's rows of the same bottle add up.
          pours = lines.flat_map do |line|
            Recipes::Expand.pours(line, recipes: recipes).group_by(&:variant_id).map do |_, rows|
              [line, Recipes::Expand::Pour.new(variant_id: rows.first.variant_id, ml: rows.sum(&:ml), bottle_ml: rows.first.bottle_ml)]
            end
          end
          # Bottles of one variant are locked in variant order, like stock rows.
          pours.sort_by { |line, pour| [pour.variant_id, line.id] }.flat_map do |line, pour|
            pour!(workspace, actor, line, pour)
          end
        end

        def pour!(workspace, actor, line, pour)
          left = pour.ml
          events = []
          while left.positive?
            bottle = open_bottle!(workspace, actor, pour)
            taken = [left, bottle.remaining_ml].min
            events << PourEvent.create!(branch_id: workspace.branch_id, open_bottle: bottle, sale_line: line, workspace: workspace,
                                        ml: taken, business_date: workspace.business_date, created_at: Time.current)
            bottle.update!(remaining_ml: bottle.remaining_ml - taken)
            left -= taken
            finish!(workspace, actor, bottle) if bottle.remaining_ml.zero?
          end
          events
        end

        # The oldest open bottle of the variant, locked; or a new full one.
        def open_bottle!(workspace, actor, pour)
          OpenBottle.unfinished.where(branch_id: workspace.branch_id, variant_id: pour.variant_id).order(:opened_at, :id).lock.first ||
            OpenBottle.create!(store_id: workspace.store_id, branch_id: workspace.branch_id, variant_id: pour.variant_id,
                               capacity_ml: pour.bottle_ml, remaining_ml: pour.bottle_ml, opened_at: Time.current, opened_by: actor)
        end

        # Finishing an open bottle by hand (spilt, gone off, the rest given
        # away): it leaves the shelf like a poured-out one, and what was left
        # in it is in the audit.
        def finish_by_hand(store:, staff:, key:, bottle_id:)
          bottle = OpenBottle.locate(OpenBottle.where(store_id: store.id), bottle_id) || raise(ActiveRecord::RecordNotFound)
          payload = { 'command' => 'open_bottle.finish', 'bottle_id' => bottle.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { BottleKeeps::Guard.keep!(store, staff, bottle.branch) }) do
            ModulePolicy.require!(bottle.branch, MODULE)
            bottle.lock!
            raise Conflict.new('This bottle is already finished.', reason: 'bottle_finished') if bottle.status == 'finished'

            left = bottle.remaining_ml
            bottle.update!(status: 'finished', finished_at: Time.current)
            variant = Spree::Variant.with_deleted.find(bottle.variant_id)
            location = bottle.branch.stock_location
            level = Spree::StockLevel.where(variant_id: variant.id, stock_location_id: location.id).lock.first
            if variant.should_track_inventory? && level&.count_on_hand.to_i.positive?
              StockIntegration.adjust!(location, variant, -1, "#{Recipes::Consume::REASON} #{bottle.prefixed_id}")
            end
            AuditEntry.record!(store: store, actor: staff, action: 'open_bottle.finish', subject: bottle,
                               metadata: { variant_id: variant.prefixed_id, remaining_ml: left })
            bottle.to_pos
          end
        end

        def finish!(workspace, actor, bottle)
          bottle.update!(status: 'finished', finished_at: Time.current)
          location = workspace.branch.stock_location
          Recipes::Consume.take!(workspace, actor, location, Spree::Variant.with_deleted.find(bottle.variant_id), 1)
        end
      end
    end
  end
end
