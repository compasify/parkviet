# frozen_string_literal: true

module Spree
  module Pos
    module Buffet
      # Creates or changes a buffet tier of a branch, with its dishes. The
      # dishes are replaced as a whole. A tier is archived, never deleted,
      # because cover lines of past orders name it. Managers of the menu or
      # of the branch.
      module SaveTier
        FIELDS = %w[name product_id duration_minutes round_item_limit round_interval_minutes status items].freeze

        module_function

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology')
          return if [Capabilities::MANAGE_MENU, Capabilities::MANAGE].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def call(store:, staff:, key:, branch:, attributes:, tier_id: nil)
          values = attributes.to_h.deep_stringify_keys.slice(*FIELDS)
          payload = { 'command' => 'buffet_tier.save', 'branch_id' => branch.prefixed_id, 'tier_id' => tier_id.to_s.presence,
                      'attributes' => values }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Tables::Guard::MODULE)
            tier = tier_id ? BuffetTier.locate(BuffetTier.where(branch_id: branch.id), tier_id) : BuffetTier.new(store: store, branch: branch)
            raise ActiveRecord::RecordNotFound if tier.nil?

            before = tier.persisted? ? tier.to_pos : nil
            tier.name = values['name'].to_s.strip if values.key?('name')
            tier.product = product!(store, values['product_id']) if values.key?('product_id')
            %w[duration_minutes round_item_limit round_interval_minutes].each do |field|
              tier[field] = values[field].presence && Integer(values[field].to_s, 10) if values.key?(field)
            end
            tier.status = values['status'].to_s if values.key?('status')
            unless tier.valid?
              raise Conflict.new('The buffet tier is invalid.', reason: 'buffet_tier_invalid',
                                                                details: { errors: tier.errors.attribute_names })
            end

            tier.save!
            items!(store, tier, values['items']) if values.key?('items')
            after = tier.reload.to_pos
            AuditEntry.record!(store: store, actor: staff, action: 'buffet_tier.save', subject: tier, metadata: { before: before, after: after })
            after
          end
        rescue ArgumentError
          raise Conflict.new('The buffet tier is invalid.', reason: 'buffet_tier_invalid')
        end

        def product!(store, product_id)
          product = Spree::Product.find_by_prefix_id(product_id.to_s)
          raise ActiveRecord::RecordNotFound if product.nil? || product.store_id != store.id

          product
        end

        def items!(store, tier, rows)
          list = Array(rows)
          raise Conflict.new('A tier has at most 200 dishes.', reason: 'buffet_tier_invalid') if list.size > 200

          tier.items.delete_all
          list.map { |row| row.to_h.stringify_keys }.uniq { |row| row['product_id'].to_s }.each do |row|
            limit = row['max_per_round'].presence && Integer(row['max_per_round'].to_s, 10)
            tier.items.create!(product: product!(store, row['product_id']), max_per_round: limit)
          end
        end
      end
    end
  end
end
