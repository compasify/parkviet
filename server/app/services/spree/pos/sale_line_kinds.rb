# frozen_string_literal: true

module Spree
  module Pos
    # Kinds a sale line may take. Core kinds have no owning module. A kind
    # says whether identical lines may collapse onto one row by merge key.
    # Filled once per code load from config/initializers/pos_modules.rb.
    class SaleLineKinds
      Kind = Data.define(:key, :owner, :mergeable)

      class << self
        def define!
          builder = {}
          yield Builder.new(builder)
          @kinds = builder.freeze
        end

        def fetch!(key)
          kinds.fetch(key.to_s) do
            raise Conflict.new('Unknown sale line kind.', reason: 'sale_line_kind_unknown', details: { kind: key.to_s })
          end
        end

        def known?(key)
          kinds.key?(key.to_s)
        end

        def mergeable?(key)
          fetch!(key).mergeable
        end

        def keys
          kinds.keys
        end

        private

        def kinds
          @kinds || raise(Conflict, 'Sale line kinds are not registered.')
        end
      end

      # Collects kind definitions inside `define!`.
      class Builder
        def initialize(kinds)
          @kinds = kinds
        end

        def add(key, owner: nil, mergeable: false)
          key = key.to_s
          raise Conflict, "Sale line kind #{key.inspect} is registered twice." if @kinds.key?(key)

          @kinds[key] = Kind.new(key: key, owner: owner&.to_s, mergeable: mergeable)
        end
      end
    end
  end
end
