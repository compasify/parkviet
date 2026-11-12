# frozen_string_literal: true

module Spree
  module Pos
    module Menu
      # Every change to the store's menu: one idempotent command each, guarded
      # by Guard, refused while no branch of the store runs `fnb.menu`, and
      # audited as `<resource>.change` with the operation.
      module Save
        CATEGORY_FIELDS = %w[name position color active].freeze
        ITEM_FIELDS = %w[kind kitchen_category cup_label show_components_on_kds position active drink_credit qr_orderable].freeze
        GROUP_FIELDS = %w[name min_select max_select allow_quantity position].freeze
        OPTION_FIELDS = %w[name price_delta default_selected position active].freeze
        SCHEDULE_FIELDS = %w[name days_of_week starts_at ends_at active label].freeze
        MAX_ROWS = 100

        module_function

        def category(store:, staff:, key:, attributes:, category: nil)
          command(store, staff, key, 'menu_category', category, attributes) do
            record = category || MenuCategory.new(store: store)
            record.lock! if record.persisted?
            record.assign_attributes(attributes.slice(*CATEGORY_FIELDS))
            record.save!
            record
          end
        end

        # A new item names an existing product of the store. It is added to
        # the assortment of every branch running the menu, so it can be sold there.
        def item(store:, staff:, key:, attributes:, item: nil)
          command(store, staff, key, 'menu_item', item, attributes) do
            record = item || MenuItem.new(store: store, product: product!(store, attributes['product_id']))
            record.lock! if record.persisted?
            record.assign_attributes(attributes.slice(*ITEM_FIELDS))
            record.kitchen_category = record.kitchen_category.presence
            record.drink_credit = record.drink_credit.presence
            # The kitchen categories a door ticket's drink credit pays for.
            if attributes.key?('drink_credit_categories')
              record.drink_credit_categories = Array(attributes['drink_credit_categories']).map { |value| value.to_s.strip }.compact_blank.uniq
            end
            record.menu_category = category!(store, attributes['menu_category_id']) if attributes.key?('menu_category_id')
            if attributes.key?('tax_category_id')
              assign_tax_category!(store, record.product, attributes['tax_category_id'])
            elsif record.new_record? && record.product.tax_category_id.nil?
              default_tax_category!(store, record.product)
            end
            new_item = record.new_record?
            record.save!
            replace_groups!(store, record, attributes['modifier_group_ids']) if attributes.key?('modifier_group_ids')
            replace_components!(record, attributes['components']) if attributes.key?('components')
            raise Conflict.new('A combo needs its contents.', reason: 'combo_empty') if record.combo? && record.combo_components.reload.empty?

            assign_branches!(store, record.product) if new_item
            record.reload
          end
        end

        def modifier_group(store:, staff:, key:, attributes:, group: nil)
          command(store, staff, key, 'modifier_group', group, attributes) do
            record = group || ModifierGroup.new(store: store)
            record.lock! if record.persisted?
            record.assign_attributes(attributes.slice(*GROUP_FIELDS))
            record.save!
            replace_options!(store, record, attributes['options']) if attributes.key?('options')
            record.reload
          end
        end

        def schedule(store:, staff:, key:, attributes:, schedule: nil)
          command(store, staff, key, 'menu_schedule', schedule, attributes) do
            record = schedule || MenuSchedule.new(store: store)
            record.lock! if record.persisted?
            record.assign_attributes(attributes.slice(*SCHEDULE_FIELDS))
            record.branch = attributes['branch_id'].present? ? Guard.branch!(store, attributes['branch_id']) : nil if attributes.key?('branch_id')
            record.save!
            replace_schedule_items!(store, record, attributes['items']) if attributes.key?('items')
            record.reload
          end
        end

        def destroy(store:, staff:, key:, record:)
          resource = record.class.name.demodulize.underscore
          payload = { 'command' => "#{resource}.destroy", 'id' => record.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff) }) do
            ModulePolicy.require_store!(store, Guard::MODULE)
            record.destroy!
            AuditEntry.record!(store: store, actor: staff, action: "#{resource}.change", subject: record,
                               metadata: { op: 'destroy', id: record.prefixed_id })
            { 'id' => record.prefixed_id }
          end
        end

        # The quick-pick row of a branch, replaced as a whole, in order.
        def favorites(store:, staff:, key:, branch:, menu_item_ids:)
          ids = Array(menu_item_ids).map(&:to_s)
          payload = { 'command' => 'menu_favorites.set', 'branch_id' => branch.prefixed_id, 'menu_item_ids' => ids }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage_branch!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            raise Conflict.new('Too many favourites.', reason: 'menu_favorites_limit') if ids.size > MenuFavorite::MAX_PER_BRANCH
            raise Conflict.new('A favourite is listed twice.', reason: 'menu_favorites_duplicate') if ids.uniq.size != ids.size

            items = ids.map { |id| Guard.menu_item!(store, id) }
            MenuFavorite.where(branch_id: branch.id).delete_all
            items.each_with_index { |row, index| MenuFavorite.create!(branch: branch, menu_item: row, position: index) }
            AuditEntry.record!(store: store, actor: staff, action: 'menu_favorite.change', subject: branch,
                               metadata: { op: 'replace', menu_item_ids: ids })
            { 'branch_id' => branch.prefixed_id, 'menu_item_ids' => ids }
          end
        end

        def command(store, staff, key, resource, record, attributes)
          op = record ? 'update' : 'create'
          payload = { 'command' => "#{resource}.#{op}", 'id' => record&.prefixed_id, 'attributes' => attributes }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff) }) do
            ModulePolicy.require_store!(store, Guard::MODULE)
            saved = yield
            AuditEntry.record!(store: store, actor: staff, action: "#{resource}.change", subject: saved,
                               metadata: { op: op, id: saved.prefixed_id, changes: attributes.except('options', 'items', 'components').keys })
            saved.to_pos
          end
        end

        def product!(store, product_id)
          product = Spree::Product.find_by_prefix_id(product_id.to_s)
          raise ActiveRecord::RecordNotFound if product.nil? || product.store_id != store.id

          product
        end

        def category!(store, category_id)
          return if category_id.blank?

          MenuCategory.locate(MenuCategory.for_store(store), category_id) || raise(ActiveRecord::RecordNotFound)
        end

        def variant!(store, variant_id)
          variant = Spree::Variant.find_by_prefix_id(variant_id.to_s)
          raise ActiveRecord::RecordNotFound if variant.nil? || variant.product&.store_id != store.id

          variant
        end

        # A tax category of another store is not found.
        def assign_tax_category!(store, product, tax_category_id)
          category = tax_category_id.present? ? Spree::TaxCategory.find_by_prefix_id(tax_category_id.to_s) : nil
          if tax_category_id.present? && (category.nil? || (category.store_id && category.store_id != store.id))
            raise ActiveRecord::RecordNotFound
          end

          product.update!(tax_category: category)
        end

        # A new item whose product has no tax category takes the store's
        # food default from the F&B setup, if there is one.
        def default_tax_category!(store, product)
          category_id = StoreProfile.for_store(store).pick(:food_tax_category_id)
          product.update!(tax_category_id: category_id) if category_id
        end

        def assign_branches!(store, product)
          branch_ids = BranchModule.joins(:branch).where(store_id: store.id, module_key: Guard::MODULE, enabled: true).
                       where(spree_pos_branches: { status: 'active' }).pluck(:branch_id)
          branch_ids.each { |branch_id| BranchProduct.find_or_create_by!(branch_id: branch_id, product_id: product.id) }
        end

        def rows!(value)
          rows = Array(value)
          raise Conflict.new('Too many rows.', reason: 'menu_rows_limit') if rows.size > MAX_ROWS
          raise Conflict, 'Rows are invalid.' unless rows.all? { |row| row.is_a?(Hash) }

          rows.map(&:stringify_keys)
        end

        def replace_groups!(store, item, group_ids)
          ids = Array(group_ids).map(&:to_s)
          raise Conflict, 'A modifier group is listed twice.' if ids.uniq.size != ids.size

          groups = ids.map { |id| ModifierGroup.locate(ModifierGroup.for_store(store), id) || raise(ActiveRecord::RecordNotFound) }
          item.menu_item_modifier_groups.delete_all
          groups.each_with_index { |group, index| item.menu_item_modifier_groups.create!(modifier_group: group, position: index) }
        end

        def replace_components!(item, components)
          rows = rows!(components)
          item.combo_components.delete_all
          rows.each do |row|
            item.combo_components.create!(variant: variant!(item.store, row['variant_id']), quantity: row['quantity'].presence || 1)
          end
        end

        # Options listed with an id are changed, new ones are added, and the
        # ones left out are deleted. Lines already sold keep their copies.
        def replace_options!(store, group, options)
          rows = rows!(options)
          existing = group.modifier_options.index_by(&:prefixed_id)
          kept = rows.filter_map { |row| row['id'].presence&.to_s }
          raise ActiveRecord::RecordNotFound unless (kept - existing.keys).empty?

          existing.except(*kept).each_value(&:destroy!)
          rows.each_with_index do |row, index|
            option = row['id'].present? ? existing.fetch(row['id'].to_s) : group.modifier_options.build
            option.assign_attributes({ 'position' => index }.merge(row.slice(*OPTION_FIELDS)))
            option.variant = row['variant_id'].present? ? variant!(store, row['variant_id']) : nil if row.key?('variant_id')
            option.save!
          end
        end

        def replace_schedule_items!(store, schedule, items)
          rows = rows!(items)
          schedule.menu_schedule_items.delete_all
          rows.each do |row|
            item = Guard.menu_item!(store, row['menu_item_id'])
            variant = row['variant_id'].present? ? variant!(store, row['variant_id']) : nil
            schedule.menu_schedule_items.create!(menu_item: item, variant: variant, price: row['price'].presence,
                                                 hidden: ActiveModel::Type::Boolean.new.cast(row['hidden']) || false)
          end
        end
      end
    end
  end
end
