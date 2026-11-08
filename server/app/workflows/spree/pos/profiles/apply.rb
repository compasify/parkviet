# frozen_string_literal: true

module Spree
  module Pos
    module Profiles
      # Moves a branch to another industry profile. Only what the caller
      # picked from the preview changes (D7): `apply_modules` sets the
      # branch's modules to exactly the profile's, and `apply_defaults` names
      # the branch defaults to take; everything else set by hand stays. The
      # caller states the profile it saw (`expected_profile_key`); another
      # one means someone changed it meanwhile (409 `profile_conflict`).
      #
      # Under the branch lock, audited as `branch_profile.change` (from, to,
      # modules switched, defaults applied), plus `branch_module.change` per
      # module switched.
      module Apply
        PERMISSION = 'write_pos_topology'
        CONFLICT = 'profile_conflict'

        module_function

        def call(store:, actor:, branch:, profile_key:, expected_profile_key:, reason:, apply_modules: false, apply_defaults: [])
          raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: actor).permission?(PERMISSION)

          profile = Branches::Create.available!(BusinessProfiles.fetch!(profile_key))
          note = BranchModules::Set.reason!(reason)
          fields = picked_defaults!(profile, apply_defaults)
          ApplicationRecord.transaction do
            branch.lock!
            if branch.profile_key != expected_profile_key.to_s
              raise Conflict.new('The branch profile was changed meanwhile.',
                                 reason: CONFLICT, details: { current_profile_key: branch.profile_key })
            end

            from = branch.profile_key
            switched = apply_modules == true ? switch_modules!(branch, profile, actor, note) : { enabled: [], disabled: [] }
            applied = fields.map do |field|
              { field: field, from: Preview.present(field, branch.public_send(field)), to: Preview.present(field, profile.branch_defaults[field]) }
            end
            branch.assign_attributes(fields.index_with { |field| profile.branch_defaults[field] })
            branch.profile_key = profile.key
            branch.profile_version = BusinessProfiles.version
            branch.save!
            existing = UnitDefinition.for_store(store).where(code: profile.sample_units).pluck(:code)
            UnitDefinition.ensure_samples!(store, profile.sample_units)
            added = profile.sample_units - existing
            AuditEntry.record!(store: store, actor: actor, action: 'branch_profile.change', subject: branch,
                               metadata: { branch_id: branch.prefixed_id, from: from, to: profile.key, profile_version: branch.profile_version,
                                           modules: switched, defaults: applied, sample_units: added, reason: note })
            { branch: branch.to_pos, modules: ModulePolicy.for_branch(branch),
              applied: { modules: switched, defaults: applied, sample_units: added } }
          end
        end

        # Fields must be defaults the profile offers.
        def picked_defaults!(profile, names)
          raise Conflict.new('Defaults to apply must be a list.', reason: 'default_invalid') unless names.nil? || names.is_a?(Array)

          fields = Array(names).map(&:to_s).uniq
          unknown = fields - profile.branch_defaults.keys
          return fields if unknown.empty?

          raise Conflict.new("Profile #{profile.key} has no default for #{unknown.join(', ')}.", reason: 'default_invalid',
                                                                                                 details: { fields: unknown })
        end

        # Exactly the profile's modules on: dependencies first when turning
        # on, dependents first when turning off.
        def switch_modules!(branch, profile, actor, note)
          on = ModulePolicy.for_branch(branch).select { |_, value| value }.keys
          metadata = { profile_key: profile.key }
          enable = Modules.available_keys.select { |key| profile.modules.include?(key) && !on.include?(key) }
          disable = Modules.available_keys.reverse.select { |key| on.include?(key) && !profile.modules.include?(key) }
          disable.each { |key| BranchModules::Set.write!(branch, key, false, actor: actor, reason: note, metadata: metadata) }
          enable.each { |key| BranchModules::Set.write!(branch, key, true, actor: actor, reason: note, metadata: metadata) }
          { enabled: enable, disabled: disable }
        end
      end
    end
  end
end
