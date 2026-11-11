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
      #
      # A profile with the menu (`fnb.menu`) may send `fnb_setup`: kitchen
      # stations (created through Kitchen::Setup, so with their own audit),
      # the tax categories new menu items start with (food, alcohol), and
      # when orders reach the kitchen. Audited as `onboarding.fnb_setup`.
      # Other profiles skip the step; sending it for them is refused.
      class Setup
        PERMISSION = 'write_pos_topology'
        ALREADY = 'already_onboarded'
        FNB_INVALID = 'fnb_setup_invalid'
        FNB_MODULE = 'fnb.menu'
        ANSWERS_INVALID = 'answers_invalid'
        REGISTER_MISSING = 'table_register_missing'
        MAX_STATIONS = 4
        BRANCH_FIELDS = %w[name code timezone stock_location_id receiving_stock_location_id receiving_note return_window_days
                           variance_threshold display_freshness_ttl_seconds lot_selection adjustment_approval_threshold].freeze

        def self.call(store:, actor:, key:, profile_key:, branch:, wholesale: false, interests: [], register: nil, grant_self: false,
                      features: [], fnb_setup: nil, answers: nil)
          branch_params = slice(branch, BRANCH_FIELDS)
          register_params = register.nil? ? nil : slice(register, %w[name code])
          payload = {
            'command' => 'onboarding.setup', 'profile_key' => profile_key.to_s, 'wholesale' => wholesale == true,
            'interests' => strings(interests), 'branch' => branch_params, 'register' => register_params,
            'grant_self' => grant_self == true, 'features' => strings(features)
          }
          payload['fnb_setup'] = fnb_params(fnb_setup) unless fnb_setup.nil?
          payload['answers'] = answer_params(answers) unless answers.nil?
          authorize = -> { raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: actor).permission?(PERMISSION) }
          CommandExecutor.call(store: store, actor: actor, key: key, payload: payload, authorize: authorize) do
            # Two people setting up at once: the second waits, then sees the first.
            store.lock!
            already!(store)
            profile = Branches::Create.available!(BusinessProfiles.fetch!(payload['profile_key']))
            fnb = payload['fnb_setup']
            fnb_valid!(profile, fnb) if fnb
            has_tables = tables_answer!(profile, payload.dig('answers', 'has_tables'))
            modules = profile.modules_for(has_tables: has_tables)
            tables = modules.include?(BusinessProfiles::TABLES_MODULE)
            raise Conflict.new('Table orders need a register to be booked on.', reason: REGISTER_MISSING) if tables && register_params.nil?

            store_profile = StoreProfile.create!(store: store, profile_key: profile.key, profile_version: BusinessProfiles.version,
                                                 wholesale: payload['wholesale'], interests: interests!(payload['interests']),
                                                 onboarded_at: Time.current, changed_by: actor)
            AuditEntry.record!(store: store, actor: actor, action: 'store_profile.change', subject: store_profile,
                               metadata: { from: nil, to: store_profile.slice(:profile_key, :wholesale, :interests), reason: 'onboarding' })
            attributes = Branches::Attributes.call(store: store, params: branch_params)
            attributes[:kitchen_send_trigger] = fnb['kitchen_send_trigger'] if fnb&.dig('kitchen_send_trigger')
            created = Branches::Create.call(store: store, actor: actor, profile_key: profile.key, attributes: attributes)
            enable_optional!(created, profile, modules, actor) if has_tables
            drawer = register_params && create_register!(store, actor, created, register_params)
            created.update!(table_register: drawer) if tables
            membership = payload['grant_self'] ? grant!(store, actor, created) : nil
            payload['features'].each do |feature|
              FeaturePolicy.set!(store: store, actor: actor, feature: feature, enabled: true, reason: "Thiết lập theo ngành: #{profile.key}")
            end
            fnb_result = fnb && fnb_setup!(store, actor, key, store_profile, created, fnb)
            table_result = tables ? table_service!(store, actor, created, profile, modules) : nil
            { store_profile: store_profile.reload.to_pos, branch: created.to_pos, register: drawer&.to_pos, membership: membership&.to_pos,
              features: FeaturePolicy.for_branch(store, created), modules: ModulePolicy.for_branch(created), fnb_setup: fnb_result,
              table_service: table_result }
          end
        end

        # Stations go through the kitchen setup workflow, each under a key
        # derived from the onboarding key; the onboarding receipt already
        # makes a retry return the first result instead of new stations.
        def self.fnb_setup!(store, actor, key, store_profile, branch, fnb)
          stations = fnb['stations'].each_with_index.map do |station, index|
            Kitchen::Setup.create_station(store: store, staff: actor, key: "#{key}:station:#{index}", branch: branch,
                                          attributes: station.merge('is_default' => index.zero?, 'position' => index)).with_indifferent_access
          end
          taxes = fnb['tax_categories']
          if taxes
            TaxCategories.seed!(store)
            categories = Spree::TaxCategory.where(store_id: store.id, tax_code: taxes.values).index_by(&:tax_code)
            store_profile.update!(food_tax_category: categories[taxes['food']], alcohol_tax_category: categories[taxes['alcohol']])
          end
          result = { stations: stations, tax_defaults: store_profile.tax_defaults, kitchen_send_trigger: branch.kitchen_send_trigger }
          AuditEntry.record!(store: store, actor: actor, action: 'onboarding.fnb_setup', subject: branch,
                             metadata: { stations: stations.map { |row| row[:id] }, tax_categories: taxes,
                                         kitchen_send_trigger: branch.kitchen_send_trigger })
          result
        end

        # Optional modules in the profile's order, each through the module
        # switch so it is audited.
        def self.enable_optional!(branch, profile, modules, actor)
          (modules - profile.modules).each do |key|
            BranchModules::Set.write!(branch, key, true, actor: actor, reason: "profile:#{profile.key}",
                                                         metadata: { profile_key: profile.key, answer: 'has_tables' })
          end
        end

        # The register table orders are booked on, and the profile's
        # stations and drink route unless the shop step made stations.
        def self.table_service!(store, actor, branch, profile, modules)
          kitchen = modules.include?(Kitchen::Send::MODULE)
          stations = kitchen ? Kitchen::Defaults.stations!(store: store, actor: actor, branch: branch, kinds: profile.kitchen_stations) : []
          routes = kitchen ? Kitchen::Defaults.routes!(store: store, actor: actor, branch: branch) : []
          { table_register_id: branch.table_register&.prefixed_id, modules_enabled: modules - profile.modules,
            stations: stations.map(&:to_pos), routes: routes.map(&:to_pos) }
        end

        # "Does the shop serve tables?" Only a profile with optional table
        # modules asks it; a profile that always serves tables accepts yes.
        def self.tables_answer!(profile, value)
          return false unless value
          return true if profile.tables_optional? || profile.modules.include?(BusinessProfiles::TABLES_MODULE)

          raise Conflict.new("Profile #{profile.key} does not serve tables.", reason: ANSWERS_INVALID)
        end

        def self.answer_params(source)
          hash = source.respond_to?(:to_unsafe_h) ? source.to_unsafe_h : source
          raise Conflict.new('Answers must be an object.', reason: ANSWERS_INVALID) unless hash.is_a?(Hash)

          value = hash.stringify_keys['has_tables']
          raise Conflict.new('has_tables must be true or false.', reason: ANSWERS_INVALID) unless [true, false, nil, 'true', 'false'].include?(value)

          { 'has_tables' => [true, 'true'].include?(value) }
        end

        # The step as strings, so the payload digest does not depend on JSON
        # types; shape problems are 409 `fnb_setup_invalid`.
        def self.fnb_params(source)
          hash = source.respond_to?(:to_unsafe_h) ? source.to_unsafe_h : source
          fnb_invalid!('Shop setup must be an object.') unless hash.is_a?(Hash)

          hash = hash.stringify_keys
          stations = hash.fetch('stations', [])
          fnb_invalid!('Stations must be a list.') unless stations.is_a?(Array)
          stations = stations.map do |row|
            row = row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row
            fnb_invalid!('Each station needs a name and a kind.') unless row.is_a?(Hash)

            row = row.stringify_keys
            { 'name' => row['name'].to_s.squish, 'kind' => row['kind'].to_s }
          end
          taxes = hash['tax_categories']
          taxes = taxes.to_unsafe_h if taxes.respond_to?(:to_unsafe_h)
          fnb_invalid!('Tax categories must be an object.') unless taxes.nil? || taxes.is_a?(Hash)

          { 'stations' => stations,
            'tax_categories' => taxes && %w[food alcohol].index_with { |role| taxes.stringify_keys[role]&.to_s },
            'kitchen_send_trigger' => hash['kitchen_send_trigger']&.to_s }
        end

        def self.fnb_valid!(profile, fnb)
          fnb_invalid!("Profile #{profile.key} has no menu; it has no shop setup step.") unless profile.modules.include?(FNB_MODULE)

          stations = fnb['stations']
          fnb_invalid!("At most #{MAX_STATIONS} stations.") if stations.size > MAX_STATIONS
          if stations.any? && !profile.modules.include?(Kitchen::Send::MODULE)
            fnb_invalid!("Profile #{profile.key} has no kitchen; it takes no stations.")
          end
          stations.each do |station|
            fnb_invalid!('Each station needs a name of at most 80 characters.') unless station['name'].length.between?(1, 80)
            fnb_invalid!('A station kind must be prep or bar.') unless BusinessProfiles::STATION_KINDS.include?(station['kind'])
          end
          fnb_invalid!('Station names must differ.') if stations.map { |row| row['name'].downcase }.uniq.size != stations.size
          taxes = fnb['tax_categories']
          if taxes && !taxes.values.all? { |code| TaxCategories::CODES.include?(code) }
            fnb_invalid!("Tax categories must be one of #{TaxCategories::CODES.join(', ')}.")
          end
          trigger = fnb['kitchen_send_trigger']
          fnb_invalid!('The send trigger is invalid.') unless trigger.nil? || Kitchen::Send::TRIGGERS.include?(trigger)
        end

        def self.fnb_invalid!(message)
          raise Conflict.new(message, reason: FNB_INVALID)
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
