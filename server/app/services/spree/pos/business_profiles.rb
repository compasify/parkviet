# frozen_string_literal: true

module Spree
  module Pos
    # Catalog of industry profiles (config/pos/business_profiles.yml). A
    # profile is a preset chosen per branch: modules to turn on, suggested
    # branch defaults, catalog display, risky features the industry usually
    # uses (a hint only, D6) and sample units. Merchants pick a profile; they
    # never edit one.
    #
    # Loaded and validated at boot (config/initializers/pos_modules.rb).
    # `errors_for` checks any hash the same way, so specs can feed it a bad
    # catalog without touching the file.
    module BusinessProfiles
      PATH = 'config/pos/business_profiles.yml'
      AVAILABLE = 'available'
      COMING_SOON = 'coming_soon'
      UNKNOWN = 'profile_unknown'
      GROUPS = %w[retail fnb].freeze
      # Groups whose profiles can be picked once their modules are available.
      # Rolling F&B back closes its group (or moves its modules back to
      # planned): branches keep their data and keep selling.
      OPEN_GROUPS = %w[retail fnb].freeze
      FIELDS = %w[group order modules branch_defaults display recommended_features sample_units kitchen_stations].freeze
      BRANCH_DEFAULT_FIELDS = %w[return_window_days lot_selection variance_threshold adjustment_approval_threshold
                                 kitchen_send_trigger].freeze
      DISPLAY_FIELDS = %w[catalog_view surface].freeze
      CATALOG_VIEWS = %w[cards list].freeze
      # The selling screen. A surface is only a hint: the client still needs
      # the module (menu_grid shows nothing without fnb.menu).
      SURFACES = { 'catalog' => nil, 'menu_grid' => 'fnb.menu' }.freeze
      # Stations the F&B setup step proposes; expo is set up by hand.
      STATION_KINDS = %w[prep bar].freeze
      KITCHEN_MODULE = 'fnb.kitchen'
      DECIMAL = /\A\d{1,15}(\.\d{1,4})?\z/

      Profile = Data.define(:key, :group, :order, :modules, :branch_defaults, :display, :recommended_features, :sample_units,
                            :kitchen_stations) do
        # Computed from the module registry, never written by hand.
        def status
          OPEN_GROUPS.include?(group) && modules.all? { |key| Modules.available?(key) } ? AVAILABLE : COMING_SOON
        end

        def available?
          status == AVAILABLE
        end

        def to_pos
          { key: key, group: group, order: order, status: status, modules: modules, branch_defaults: branch_defaults,
            display: display, recommended_features: recommended_features, sample_units: sample_units,
            kitchen_stations: kitchen_stations }
        end
      end

      Catalog = Data.define(:version, :profiles)

      # Every problem of a catalog, one message each, naming the profile key
      # and field ("nha_thuoc.modules: unknown module ...").
      class Invalid < StandardError
        attr_reader :errors

        def initialize(errors)
          @errors = errors
          super("#{PATH} is invalid:\n  #{errors.join("\n  ")}")
        end
      end

      class << self
        def catalog
          @catalog ||= load!
        end

        # Reads and validates the file again (boot, and after a code reload).
        def reload!
          @catalog = load!
        end

        def load!(path = Rails.root.join(PATH))
          build(YAML.safe_load_file(path))
        end

        def build(data)
          errors = errors_for(data)
          raise Invalid, errors if errors.any?

          profiles = data['profiles'].map do |key, attrs|
            Profile.new(key: key.to_s, group: attrs['group'], order: attrs['order'],
                        modules: Array(attrs['modules']).map(&:to_s).freeze,
                        branch_defaults: (attrs['branch_defaults'] || {}).to_h.transform_keys(&:to_s).freeze,
                        display: (attrs['display'] || {}).to_h.transform_keys(&:to_s).freeze,
                        recommended_features: Array(attrs['recommended_features']).map(&:to_s).freeze,
                        sample_units: Array(attrs['sample_units']).map(&:to_s).freeze,
                        kitchen_stations: Array(attrs['kitchen_stations']).map(&:to_s).freeze)
          end
          Catalog.new(version: data['version'], profiles: profiles.sort_by(&:order).freeze)
        end

        def errors_for(data)
          return ['catalog: must be a mapping with `version` and `profiles`.'] unless data.is_a?(Hash)

          errors = []
          errors << 'version: must be a positive integer.' unless data['version'].is_a?(Integer) && data['version'].positive?
          extra = data.keys.map(&:to_s) - %w[version profiles]
          errors << "catalog: unknown keys #{extra.join(', ')}." if extra.any?
          profiles = data['profiles']
          unless profiles.is_a?(Hash) && profiles.any?
            errors << 'profiles: must be a non-empty mapping.'
            return errors
          end

          profiles.each { |key, attrs| errors.concat(profile_errors(key.to_s, attrs)) }
          orders = profiles.values.filter_map { |attrs| attrs['order'] if attrs.is_a?(Hash) }
          orders.tally.each { |order, count| errors << "profiles: order #{order} is used #{count} times." if count > 1 }
          errors
        end

        def version
          catalog.version
        end

        def all
          catalog.profiles
        end

        def find(key)
          all.find { |profile| profile.key == key.to_s }
        end

        def fetch!(key)
          find(key) || raise(Conflict.new('Unknown business profile.', reason: UNKNOWN, details: { profile: key.to_s }))
        end

        def to_pos
          { version: version, modules: Modules.all.map(&:to_pos), profiles: all.map(&:to_pos),
            tax_categories: TaxCategories.options, menu_tax_defaults: TaxCategories::MENU_DEFAULTS }
        end

        private

        def profile_errors(key, attrs)
          return ["#{key}: key must match #{Branch::PROFILE_KEY_FORMAT.source}."] unless key.match?(Branch::PROFILE_KEY_FORMAT)
          return ["#{key}: must be a mapping."] unless attrs.is_a?(Hash)

          errors = []
          extra = attrs.keys.map(&:to_s) - FIELDS
          errors << "#{key}: unknown fields #{extra.join(', ')}." if extra.any?
          errors << "#{key}.group: must be one of #{GROUPS.join(', ')}." unless GROUPS.include?(attrs['group'])
          errors << "#{key}.order: must be a positive integer." unless attrs['order'].is_a?(Integer) && attrs['order'].positive?
          errors.concat(module_errors(key, attrs['modules']))
          errors.concat(branch_default_errors(key, attrs['branch_defaults']))
          errors.concat(display_errors(key, attrs['display'], attrs['modules']))
          errors.concat(list_errors(key, 'recommended_features', attrs['recommended_features'], FeatureFlag::FEATURES, 'feature'))
          errors.concat(list_errors(key, 'sample_units', attrs['sample_units'], UnitDefinition.known_codes, 'unit'))
          errors.concat(station_errors(key, attrs['kitchen_stations'], attrs['modules']))
          errors
        end

        def station_errors(key, kinds, modules)
          return [] if kinds.nil?
          return ["#{key}.kitchen_stations: must be a list."] unless kinds.is_a?(Array)

          errors = kinds.reject { |kind| STATION_KINDS.include?(kind.to_s) }.
                   map { |kind| "#{key}.kitchen_stations: #{kind.inspect} must be one of #{STATION_KINDS.join(', ')}." }
          errors << "#{key}.kitchen_stations: lists a kind more than once." if kinds.uniq.size != kinds.size
          errors << "#{key}.kitchen_stations: needs #{KITCHEN_MODULE}." if kinds.any? && !Array(modules).map(&:to_s).include?(KITCHEN_MODULE)
          errors
        end

        def module_errors(key, modules)
          return ["#{key}.modules: must be a list."] unless modules.is_a?(Array)

          errors = []
          errors << "#{key}.modules: lists a module more than once." if modules.uniq.size != modules.size
          modules.each do |name|
            definition = Modules.find(name.to_s)
            if definition.nil?
              errors << "#{key}.modules: unknown module #{name.inspect}."
              next
            end
            missing = definition.depends_on - modules.map(&:to_s)
            errors << "#{key}.modules: #{name} needs #{missing.join(', ')}." if missing.any?
          end
          errors
        end

        def branch_default_errors(key, defaults)
          return [] if defaults.nil?
          return ["#{key}.branch_defaults: must be a mapping."] unless defaults.is_a?(Hash)

          defaults.filter_map do |field, value|
            where = "#{key}.branch_defaults.#{field}"
            next "#{where}: unknown field; allowed: #{BRANCH_DEFAULT_FIELDS.join(', ')}." unless BRANCH_DEFAULT_FIELDS.include?(field.to_s)

            problem = branch_default_problem(field.to_s, value)
            "#{where}: #{value.inspect} #{problem}." if problem
          end
        end

        # The same rules as Spree::Pos::Branch, without touching the database.
        def branch_default_problem(field, value)
          case field
          when 'return_window_days'
            range = Branch::RETURN_WINDOW_DAYS
            "must be empty or a whole number of days from #{range.min} to #{range.max}" unless value.nil? || (value.is_a?(Integer) && range.cover?(value))
          when 'lot_selection'
            "must be one of #{Branch::LOT_SELECTIONS.join(', ')}" unless Branch::LOT_SELECTIONS.include?(value)
          when 'variance_threshold'
            'must be empty or an amount of zero or more' unless value.nil? || (value.is_a?(Integer) && value >= 0) || (value.is_a?(String) && value.match?(DECIMAL))
          when 'adjustment_approval_threshold'
            'must be empty or a whole number of zero or more' unless value.nil? || (value.is_a?(Integer) && value >= 0)
          when 'kitchen_send_trigger'
            "must be one of #{Kitchen::Send::TRIGGERS.join(', ')}" unless Kitchen::Send::TRIGGERS.include?(value)
          end
        end

        def display_errors(key, display, modules)
          return [] if display.nil?
          return ["#{key}.display: must be a mapping."] unless display.is_a?(Hash)

          display.filter_map do |field, value|
            where = "#{key}.display.#{field}"
            case field.to_s
            when 'catalog_view'
              "#{where}: #{value.inspect} must be one of #{CATALOG_VIEWS.join(', ')}." unless CATALOG_VIEWS.include?(value)
            when 'surface'
              if !SURFACES.key?(value)
                "#{where}: #{value.inspect} must be one of #{SURFACES.keys.join(', ')}."
              elsif SURFACES[value] && !Array(modules).map(&:to_s).include?(SURFACES[value])
                "#{where}: #{value} needs #{SURFACES[value]}."
              end
            else
              "#{where}: unknown field; allowed: #{DISPLAY_FIELDS.join(', ')}."
            end
          end
        end

        def list_errors(key, field, values, allowed, noun)
          return [] if values.nil?
          return ["#{key}.#{field}: must be a list."] unless values.is_a?(Array)

          errors = values.reject { |value| allowed.include?(value.to_s) }.map { |value| "#{key}.#{field}: unknown #{noun} #{value.inspect}." }
          errors << "#{key}.#{field}: lists a value more than once." if values.uniq.size != values.size
          errors
        end
      end
    end
  end
end
