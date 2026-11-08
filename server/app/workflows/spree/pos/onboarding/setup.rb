# frozen_string_literal: true

module Spree
  module Pos
    module Onboarding
      # First-run POS setup of a store, in one idempotent command: the store
      # profile, the first branch (Branches::Create, so the profile's
      # modules, defaults and sample units), optionally a register and a
      # membership with every capability for the person setting up, and the
      # risky features they ticked themselves (D6: a profile never turns one
      # on). Runs only while the store still needs the setup (neither a store
      # profile nor an active branch); afterwards 409 `already_onboarded`.
      #
      # The same key with the same payload returns the first result; with
      # another payload it is a 409 like every POS command.
      class Setup
        PERMISSION = 'write_pos_topology'
        ALREADY = 'already_onboarded'
        BRANCH_FIELDS = %w[name code timezone stock_location_id receiving_stock_location_id receiving_note return_window_days
                           variance_threshold display_freshness_ttl_seconds lot_selection adjustment_approval_threshold].freeze

        def self.call(store:, actor:, key:, profile_key:, branch:, wholesale: false, interests: [], register: nil, grant_self: false,
                      features: [])
          branch_params = slice(branch, BRANCH_FIELDS)
          register_params = register.nil? ? nil : slice(register, %w[name code])
          payload = {
            'command' => 'onboarding.setup', 'profile_key' => profile_key.to_s, 'wholesale' => wholesale == true,
            'interests' => strings(interests), 'branch' => branch_params, 'register' => register_params,
            'grant_self' => grant_self == true, 'features' => strings(features)
          }
          authorize = -> { raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: actor).permission?(PERMISSION) }
          CommandExecutor.call(store: store, actor: actor, key: key, payload: payload, authorize: authorize) do
            # Two people setting up at once: the second waits, then sees the first.
            store.lock!
            already!(store)
            profile = Branches::Create.available!(BusinessProfiles.fetch!(payload['profile_key']))
            store_profile = StoreProfile.create!(store: store, profile_key: profile.key, profile_version: BusinessProfiles.version,
                                                 wholesale: payload['wholesale'], interests: interests!(payload['interests']),
                                                 onboarded_at: Time.current, changed_by: actor)
            AuditEntry.record!(store: store, actor: actor, action: 'store_profile.change', subject: store_profile,
                               metadata: { from: nil, to: store_profile.slice(:profile_key, :wholesale, :interests), reason: 'onboarding' })
            created = Branches::Create.call(store: store, actor: actor, profile_key: profile.key,
                                            attributes: Branches::Attributes.call(store: store, params: branch_params))
            drawer = register_params && create_register!(store, actor, created, register_params)
            membership = payload['grant_self'] ? grant!(store, actor, created) : nil
            payload['features'].each do |feature|
              FeaturePolicy.set!(store: store, actor: actor, feature: feature, enabled: true, reason: "Thiết lập theo ngành: #{profile.key}")
            end
            { store_profile: store_profile.reload.to_pos, branch: created.to_pos, register: drawer&.to_pos, membership: membership&.to_pos,
              features: FeaturePolicy.for_branch(store, created), modules: ModulePolicy.for_branch(created) }
          end
        end

        def self.already!(store)
          return unless StoreProfile.for_store(store).exists? || Branch.for_store(store).where(status: 'active').exists?

          raise Conflict.new('This store is already set up; change its profile on the business model page.', reason: ALREADY)
        end

        # Only "coming soon" profiles: an owner asking for an industry POS
        # cannot serve yet.
        def self.interests!(keys)
          keys.each do |key|
            profile = BusinessProfiles.fetch!(key)
            next unless profile.available?

            raise Conflict.new("Profile #{key} is available; choose it instead of listing it as an interest.",
                               reason: 'interest_invalid', details: { profile: key })
          end
          keys
        end

        # The same record and audit as POST /registers.
        def self.create_register!(store, actor, branch, params)
          code = params['code'].presence || "#{branch.code[0, 29]}-1"
          drawer = Register.create!(store: store, branch: branch, name: params['name'], code: code, status: 'active')
          AuditEntry.record!(store: store, actor: actor, action: 'register.create', subject: drawer)
          drawer
        end

        # The same record and audit as POST /memberships, with every capability.
        def self.grant!(store, actor, branch)
          membership = StaffMembership.create!(store: store, branch: branch, staff: actor, capabilities: Capabilities::ASSIGNABLE,
                                               status: 'active')
          AuditEntry.record!(store: store, actor: actor, action: 'membership.create', subject: membership,
                             metadata: { capabilities: membership.capabilities })
          membership
        end

        # Sent fields only, as strings or nil, so the payload digest does not
        # depend on JSON number or key types.
        def self.slice(source, fields)
          hash = source.respond_to?(:to_unsafe_h) ? source.to_unsafe_h : source
          raise Conflict.new('Setup details are invalid.', reason: 'parameter_invalid') unless hash.is_a?(Hash)

          hash = hash.stringify_keys
          fields.select { |field| hash.key?(field) }.index_with { |field| hash[field]&.to_s }
        end

        def self.strings(values)
          Array(values).map(&:to_s).uniq
        end
      end
    end
  end
end
