# frozen_string_literal: true

module Spree
  module Pos
    # Which POS modules a branch has on. A module is on at a branch only with
    # an `enabled` row in spree_pos_branch_modules; no row means off, and a
    # planned module is never on.
    #
    # Like FeaturePolicy, off refuses only NEW setup commands of the module
    # (409, reason `module_disabled`): configuring a SKU, a label format,
    # opening tracked stock. Selling, returns and the guards that follow a
    # SKU's own configuration never ask this policy.
    module ModulePolicy
      DISABLED = 'module_disabled'

      module_function

      # { 'retail.units' => true, ... } for every available module; {}
      # without a branch. One query.
      def for_branch(branch)
        return {} if branch.nil?

        on = BranchModule.where(branch_id: branch.id, enabled: true).pluck(:module_key)
        Modules.available_keys.index_with { |key| on.include?(key) }
      end

      # Whether the store still has data a module's day-to-day screens work
      # on, whatever the branch modules say. Today only
      # `retail.traceability`: true while any live variant of the store is
      # tracked by serial or lot, so a branch with the module off can keep
      # receiving stock for those SKUs. One EXISTS query; {} without a store.
      def usage_for(store)
        return {} if store.nil?

        tracked = VariantUnit.for_store(store).joins(:variant).where(status: 'active', tracked_mode: %w[serial lot]).exists?
        { 'retail.traceability' => tracked }
      end

      def enabled?(branch, key)
        definition = Modules.fetch!(key)
        return false unless definition.available?

        BranchModule.exists?(branch_id: branch.id, module_key: definition.key, enabled: true)
      end

      # On at one or more active branches of the store: the rule for
      # store-wide configuration such as a SKU's units or tracked mode.
      def store_enabled?(store, key)
        definition = Modules.fetch!(key)
        return false unless definition.available?

        BranchModule.joins(:branch).
          where(store_id: store.id, module_key: definition.key, enabled: true, spree_pos_branches: { status: 'active' }).
          exists?
      end

      # Raised at the start of a new setup command of the module, after the
      # executor has ruled out a replay.
      def require!(branch, key)
        refuse!(key) unless enabled?(branch, key)
      end

      def require_store!(store, key)
        refuse!(key) unless store_enabled?(store, key)
      end

      def refuse!(key)
        raise Conflict.new("Module #{key} is turned off.", reason: DISABLED, details: { module: key.to_s })
      end
    end
  end
end
