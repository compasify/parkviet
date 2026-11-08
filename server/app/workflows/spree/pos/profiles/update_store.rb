# frozen_string_literal: true

module Spree
  module Pos
    module Profiles
      # Changes the store's main industry profile: the default for branches
      # created from now on. Branches that exist keep their own profile,
      # modules and settings. A store that still needs the first-run setup
      # goes through onboarding instead (409 `onboarding_required`); a store
      # that runs branches but has no store profile yet gets one here.
      # Audited (`store_profile.change`) only when something changes.
      module UpdateStore
        PERMISSION = 'write_pos_topology'

        module_function

        def call(store:, actor:, profile_key:, reason:, wholesale: nil, interests: nil)
          raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: actor).permission?(PERMISSION)

          profile = Branches::Create.available!(BusinessProfiles.fetch!(profile_key))
          note = BranchModules::Set.reason!(reason)
          unless wholesale.nil? || [true, false].include?(wholesale)
            raise Conflict.new('Wholesale must be true or false.', reason: 'parameter_invalid')
          end

          ApplicationRecord.transaction do
            store.lock!
            record = StoreProfile.for_store(store).first
            if record.nil? && !Branch.for_store(store).where(status: 'active').exists?
              raise Conflict.new('Set the store up first.', reason: 'onboarding_required')
            end

            record ||= StoreProfile.new(store: store, onboarded_at: Time.current)
            before = record.persisted? ? snapshot(record) : nil
            record.profile_key = profile.key
            record.profile_version = BusinessProfiles.version
            record.wholesale = wholesale unless wholesale.nil?
            record.interests = Onboarding::Setup.interests!(Onboarding::Setup.strings(interests)) unless interests.nil?
            if record.new_record? || record.changed?
              record.changed_by = actor
              record.save!
              AuditEntry.record!(store: store, actor: actor, action: 'store_profile.change', subject: record,
                                 metadata: { from: before, to: snapshot(record), reason: note })
            end
            record.reload.to_pos
          end
        end

        def snapshot(record)
          { profile_key: record.profile_key, profile_version: record.profile_version, wholesale: record.wholesale,
            interests: Array(record.interests) }
        end
      end
    end
  end
end
