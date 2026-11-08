# frozen_string_literal: true

module Spree
  module Pos
    module BranchModules
      # Turns one module on or off at a branch. Turning a module on turns on
      # what it depends on; turning one off is refused while another module
      # on at the branch needs it (409 `module_required_by`). Off only hides
      # the module's setup screens and refuses its new setup commands (D5);
      # selling what is configured never depends on it, so a branch's own
      # topology manager may switch modules too (unlike risky features).
      #
      # Audited per module that changed (`branch_module.change`); a call
      # that changes nothing writes nothing.
      class Set
        STORE_PERMISSION = 'write_pos_topology'
        REQUIRED_BY = 'module_required_by'
        UNAVAILABLE = 'module_unavailable'

        def self.call(store:, actor:, branch:, key:, enabled:, reason:)
          authorize!(store, actor, branch)
          definition = available!(key)
          raise Conflict.new('Enabled must be true or false.', reason: 'module_value_invalid') unless [true, false].include?(enabled)

          note = reason!(reason)
          ApplicationRecord.transaction do
            branch.lock!
            also_enabled = []
            if enabled
              closure(definition.key).each do |dependency|
                also_enabled << dependency if write!(branch, dependency, true, actor: actor, reason: note,
                                                                               metadata: { required_by: definition.key })
              end
            else
              needed_by = dependents(definition.key) & on_keys(branch)
              if needed_by.any?
                raise Conflict.new("#{needed_by.join(', ')} needs #{definition.key}.",
                                   reason: REQUIRED_BY, details: { module: definition.key, required_by: needed_by })
              end
            end
            changed = write!(branch, definition.key, enabled, actor: actor, reason: note).present?
            { branch_id: branch.prefixed_id, module: definition.key, enabled: enabled, changed: changed,
              also_enabled: also_enabled, modules: ModulePolicy.for_branch(branch) }
          end
        end

        # Store topology managers everywhere; a branch's own topology manager
        # at that branch.
        def self.authorize!(store, actor, branch)
          policy = AccessPolicy.new(store: store, staff: actor)
          raise CanCan::AccessDenied unless manage?(policy, branch)
        end

        def self.manage?(policy, branch)
          policy.permission?(STORE_PERMISSION) || policy.allows?(branch, Capabilities::MANAGE)
        end

        def self.available!(key)
          definition = Modules.fetch!(key)
          unless definition.available?
            raise Conflict.new("Module #{definition.key} is not available yet.", reason: UNAVAILABLE, details: { module: definition.key })
          end

          definition
        end

        def self.reason!(reason)
          note = reason.to_s.strip
          raise Conflict.new('A reason is required.', reason: 'reason_required') if note.blank?
          raise Conflict.new('Reason is too long.', reason: 'reason_invalid') if note.length > 200

          note
        end

        # Every module `key` needs, nearest last so they turn on in order.
        def self.closure(key, seen = [])
          Modules.fetch!(key).depends_on.each do |dependency|
            next if seen.include?(dependency)

            closure(dependency, seen)
            seen << dependency
          end
          seen
        end

        # Available modules that need `key`, directly or through another.
        def self.dependents(key)
          Modules.available.select { |definition| closure(definition.key).include?(key) }.map(&:key)
        end

        def self.on_keys(branch)
          BranchModule.where(branch_id: branch.id, enabled: true).pluck(:module_key)
        end

        # Writes one switch and audits it; returns the row, or nil when it
        # already had that value. Shared with profile changes. The caller
        # holds the branch lock.
        def self.write!(branch, key, enabled, actor:, reason:, metadata: {})
          row = BranchModule.find_or_initialize_by(branch_id: branch.id, module_key: key)
          before = row.persisted? ? row.enabled : false
          return if before == enabled

          row.update!(store_id: branch.store_id, enabled: enabled, reason: reason, changed_by: actor)
          AuditEntry.record!(store: branch.store, actor: actor, action: 'branch_module.change', subject: branch,
                             metadata: { module: key, branch_id: branch.prefixed_id, from: before, to: enabled, reason: reason }.merge(metadata))
          row
        end
      end
    end
  end
end
