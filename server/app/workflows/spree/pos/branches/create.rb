# frozen_string_literal: true

module Spree
  module Pos
    module Branches
      # Creates an active branch with an industry profile, shared by POST
      # /branches and the first-run setup. The profile defaults to the
      # store's main profile (`khac` without one). In one transaction:
      # the branch, with the profile's branch defaults for every field the
      # request left out; the profile's modules on; the profile's sample
      # units; and the `branch.create` audit naming the profile. A "coming
      # soon" profile cannot have a branch yet (409 `profile_unavailable`).
      class Create
        FALLBACK_PROFILE = 'khac'
        UNAVAILABLE = 'profile_unavailable'

        def self.call(store:, actor:, attributes:, profile_key: nil)
          profile = resolve_profile(store, profile_key)
          ApplicationRecord.transaction do
            defaults = profile.branch_defaults.reject { |field, _| attributes.key?(field.to_sym) }.transform_keys(&:to_sym)
            branch = Branch.create!(defaults.merge(attributes).merge(store: store, status: 'active', profile_key: profile.key,
                                                                     profile_version: BusinessProfiles.version))
            profile.modules.each do |key|
              row = BranchModule.find_or_initialize_by(branch_id: branch.id, module_key: key)
              row.update!(store: store, enabled: true, reason: "profile:#{profile.key}", changed_by: actor)
            end
            UnitDefinition.ensure_samples!(store, profile.sample_units)
            AuditEntry.record!(store: store, actor: actor, action: 'branch.create', subject: branch,
                               metadata: { profile_key: profile.key, profile_version: branch.profile_version, modules: profile.modules,
                                           defaults: defaults.keys.map(&:to_s) })
            branch
          end
        end

        # A key the request names must be in the catalog and available; the
        # store's own key falls back to `khac` once the catalog drops it.
        def self.resolve_profile(store, profile_key)
          profile = if profile_key.present?
                      BusinessProfiles.fetch!(profile_key)
                    else
                      stored = StoreProfile.for_store(store).pick(:profile_key)
                      (stored && BusinessProfiles.find(stored)) || BusinessProfiles.fetch!(FALLBACK_PROFILE)
                    end
          available!(profile)
        end

        def self.available!(profile)
          return profile if profile.available?

          raise Conflict.new("Profile #{profile.key} is not available yet.", reason: UNAVAILABLE, details: { profile: profile.key })
        end
      end
    end
  end
end
