# frozen_string_literal: true

module Spree
  module Pos
    # Registry of POS modules: a named slice of POS behaviour a branch turns
    # on or off (see ModulePolicy). Code checks modules, never industry
    # profiles. `available` modules have code; `planned` ones are names only,
    # so "coming soon" profiles can refer to them, and no branch can enable
    # them.
    #
    # Filled once per code load by `config/initializers/pos_modules.rb`
    # (`define!` validates the dependency graph and freezes the registry).
    module Modules
      Definition = Data.define(:key, :group, :depends_on, :status, :entrypoints) do
        def available?
          status == AVAILABLE
        end

        def to_pos
          { key: key, group: group, status: status, depends_on: depends_on }
        end
      end

      AVAILABLE = 'available'
      PLANNED = 'planned'
      STATUSES = [AVAILABLE, PLANNED].freeze
      KEY_FORMAT = /\A[a-z][a-z_]{0,39}(\.[a-z][a-z_]{0,39})?\z/
      UNKNOWN = 'module_unknown'

      class Invalid < StandardError; end

      # Collects definitions inside `define!`.
      class Builder
        attr_reader :definitions

        def initialize
          @definitions = {}
        end

        def register(key:, group:, depends_on: [], status: AVAILABLE, entrypoints: [])
          key = key.to_s
          raise Invalid, "Module #{key.inspect} is registered twice." if definitions.key?(key)

          definitions[key] = Definition.new(key: key, group: group.to_s, depends_on: Array(depends_on).map(&:to_s).freeze,
                                            status: status.to_s, entrypoints: Array(entrypoints).map(&:to_s).freeze)
        end

        def planned(*keys, group:)
          keys.flatten.each { |key| register(key: key, group: group, status: PLANNED) }
        end
      end

      class << self
        # Replaces the registry with the block's definitions, validated and
        # frozen. Runs at boot and after every code reload in development.
        def define!(&block)
          builder = Builder.new
          block.call(builder)
          validate!(builder.definitions)
          @definitions = builder.definitions.freeze
        end

        # Raises Invalid naming the module at fault: bad key, group or
        # status, unknown dependency, dependency on a planned module, or a
        # cycle. Public so specs can check a fixture graph.
        def validate!(definitions)
          definitions.each_value do |definition|
            raise Invalid, "Module #{definition.key.inspect}: key must match #{KEY_FORMAT.source}." unless definition.key.match?(KEY_FORMAT)
            raise Invalid, "Module #{definition.key.inspect}: group is required." if definition.group.blank?
            raise Invalid, "Module #{definition.key.inspect}: status must be one of #{STATUSES.join(', ')}." unless STATUSES.include?(definition.status)

            definition.depends_on.each do |dependency|
              target = definitions[dependency]
              raise Invalid, "Module #{definition.key.inspect} depends on unknown module #{dependency.inspect}." if target.nil?
              if definition.available? && !target.available?
                raise Invalid, "Module #{definition.key.inspect} depends on planned module #{dependency.inspect}."
              end
            end
            next unless definition.available?

            if definition.entrypoints.empty?
              raise Invalid, "Module #{definition.key.inspect} is available but declares no route or workflow."
            end

            definition.entrypoints.each do |entrypoint|
              entrypoint.constantize
            rescue NameError
              raise Invalid, "Module #{definition.key.inspect} entrypoint #{entrypoint.inspect} is not defined."
            end
          end
          definitions.each_key { |key| visit(definitions, key, []) }
          true
        end

        def all
          registry.values
        end

        def available
          all.select(&:available?)
        end

        def available_keys
          available.map(&:key)
        end

        def known?(key)
          registry.key?(key.to_s)
        end

        def available?(key)
          registry[key.to_s]&.available? || false
        end

        def find(key)
          registry[key.to_s]
        end

        def fetch!(key)
          find(key) || raise(Conflict.new('Unknown module.', reason: UNKNOWN, details: { module: key.to_s }))
        end

        private

        def registry
          @definitions || raise(Invalid, 'POS modules are not registered; config/initializers/pos_modules.rb has not run.')
        end

        def visit(definitions, key, path)
          raise Invalid, "Module dependency cycle: #{(path + [key]).join(' -> ')}." if path.include?(key)

          definitions[key].depends_on.each { |dependency| visit(definitions, dependency, path + [key]) }
        end
      end
    end
  end
end
