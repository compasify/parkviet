# frozen_string_literal: true

module Spree
  module Pos
    module Menu
      # The price of one unit of a menu line, from server data only: the
      # variant's list price, or its price on a time-of-day menu running at
      # `now` in the branch timezone, plus quantity × price delta of every
      # picked option. Every refusal is a Conflict with a machine reason.
      #
      # `selections` are `[{ option_id:, quantity: }]`. nil (nothing sent)
      # picks the options marked default; an empty list picks none.
      # `base_price` keeps the price a line was first sold at, for a change
      # of options on a line already in the order.
      module Pricing
        MODULE = 'fnb.menu'
        MAX_SELECTIONS = 50

        Option = Data.define(:option, :group, :quantity) do
          def amount
            option.price_delta * quantity
          end
        end

        Result = Data.define(:menu_item, :base_price, :schedule, :options, :unit_price, :modifier_signature, :note, :components)

        module_function

        def resolve(branch:, variant:, selections:, now:, currency:, order: nil, note: nil, menu_item: nil, base_price: nil)
          item = menu_item || MenuItem.for_variant(branch.store, variant)
          raise Conflict.new('This item is not on the menu.', reason: 'modifier_unknown') if item.nil?

          schedule = nil
          if base_price.nil?
            base_price, schedule = scheduled_price(branch, item, variant, now)
            base_price ||= list_price!(branch, variant, currency, order)
          end
          options = picked_options(item, selections)
          clean_note = normalize_note(note)
          unit_price = base_price + options.sum(BigDecimal('0'), &:amount)
          Result.new(menu_item: item, base_price: base_price, schedule: schedule, options: options, unit_price: unit_price,
                     modifier_signature: signature(options, clean_note), note: clean_note,
                     components: item.combo? ? item.combo_components.includes(variant: :product).to_a : [])
        end

        # The schedules running at a branch now. Shared with the menu read.
        def running_schedules(branch, now)
          MenuSchedule.for_branch(branch).includes(:menu_schedule_items).order(:id).select do |schedule|
            schedule.running_at?(now, branch.timezone)
          end
        end

        # [price or nil, schedule] for the item's size from the running
        # schedules: a row for the size beats a row for every size. Raises
        # when a running schedule hides the item.
        def scheduled_price(branch, item, variant, now, schedules: nil)
          rows = (schedules || running_schedules(branch, now)).flat_map do |schedule|
            schedule.menu_schedule_items.select { |row| row.menu_item_id == item.id && (row.variant_id.nil? || row.variant_id == variant.id) }.
              map { |row| [schedule, row] }
          end
          if rows.any? { |_, row| row.hidden }
            raise Conflict.new('This item is not on the menu right now.', reason: 'menu_item_hidden',
                                                                          details: { menu_item_id: item.prefixed_id })
          end

          priced = rows.select { |_, row| row.price }.min_by { |_, row| row.variant_id ? 0 : 1 }
          priced ? [priced.last.price, priced.first] : [nil, nil]
        end

        def list_price!(branch, variant, currency, order)
          price = SalesChannel.price(variant, store: branch.store, currency: currency, order: order)&.amount
          raise Conflict, 'Variant has no price in the order currency.' if price.nil?

          price
        end

        def picked_options(item, selections)
          offered = {}
          groups = item.menu_item_modifier_groups.includes(modifier_group: :modifier_options).map(&:modifier_group)
          groups.each do |group|
            group.modifier_options.select(&:active).each { |option| offered[option.prefixed_id] = [option, group] }
          end
          picks = selections.nil? ? defaults(offered) : parse(selections, offered)
          options = picks.map { |option_id, quantity| Option.new(option: offered[option_id][0], group: offered[option_id][1], quantity: quantity) }
          groups.each { |group| check_group!(group, options.select { |row| row.group.id == group.id }) }
          options.sort_by { |row| [row.group.position, row.group.id, row.option.position, row.option.id] }
        end

        def defaults(offered)
          offered.select { |_, (option, _)| option.default_selected }.transform_values { 1 }
        end

        def parse(selections, offered)
          rows = Array(selections)
          raise Conflict.new('Too many options.', reason: 'modifier_max') if rows.size > MAX_SELECTIONS

          rows.each_with_object(Hash.new(0)) do |row, picks|
            raise Conflict.new('Option is invalid.', reason: 'modifier_unknown') unless row.is_a?(Hash)

            row = row.stringify_keys

            option_id = row['option_id'].to_s
            raise Conflict.new('This option does not belong to this item.', reason: 'modifier_unknown', details: { option_id: option_id }) unless offered.key?(option_id)

            picks[option_id] += quantity!(row['quantity'])
            group = offered[option_id][1]
            if picks[option_id] > (group.allow_quantity ? ModifierGroup::MAX_OPTION_QUANTITY : 1)
              raise Conflict.new('Option quantity is invalid.', reason: 'modifier_max', details: { group_id: group.prefixed_id })
            end
          end
        end

        def quantity!(value)
          return 1 if value.nil?

          number = case value
                   when Integer then value
                   when /\A\d{1,3}\z/ then Integer(value, 10)
                   end
          raise Conflict.new('Option quantity is invalid.', reason: 'modifier_max') unless number&.between?(1, ModifierGroup::MAX_OPTION_QUANTITY)

          number
        end

        def check_group!(group, picked)
          count = group.allow_quantity ? picked.sum(&:quantity) : picked.size
          details = { group_id: group.prefixed_id, min_select: group.min_select, max_select: group.max_select }
          raise Conflict.new("Pick at least #{group.min_select} in #{group.name}.", reason: 'modifier_min', details: details) if count < group.min_select
          raise Conflict.new("Pick at most #{group.max_select} in #{group.name}.", reason: 'modifier_max', details: details) if count > group.max_select
        end

        def normalize_note(note)
          note.to_s.squish.first(200).presence
        end

        # Two lines merge only with the same options, quantities and note.
        # nil without options or note, so a plain menu line keeps a plain key.
        def signature(options, note)
          return if options.empty? && note.nil?

          parts = options.map { |row| "#{row.option.id}:#{row.quantity}" }.sort
          Digest::SHA256.hexdigest("#{parts.join(',')}|#{note.to_s.downcase}")
        end
      end
    end
  end
end
