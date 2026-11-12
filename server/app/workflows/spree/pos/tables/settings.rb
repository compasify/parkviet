# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # A branch's table service settings: the register table orders are
      # booked on, and the service charge (rate, the service modes it applies
      # to and its tax category). Changes are audited. The store's tax
      # categories come along, so a branch manager without store permissions
      # can choose the service charge's.
      module Settings
        module_function

        def to_pos(branch)
          { branch_id: branch.prefixed_id, table_register_id: branch.table_register&.prefixed_id,
            service_charge_rate: branch.service_charge_rate&.to_s('F'),
            service_charge_applies_to: Array(branch.service_charge_applies_to),
            service_charge_tax_category_id: branch.service_charge_tax_category&.prefixed_id,
            reservation_grace_minutes: branch.reservation_grace_minutes,
            reservation_duration_minutes: branch.reservation_duration_minutes,
            reservation_fee_product_id: branch.reservation_fee_product&.prefixed_id,
            course_labels: CourseLabel.to_pos(branch),
            bottle_keep_days: branch.bottle_keep_days, tips_as_revenue: branch.tips_as_revenue,
            tip_split: TipSplitRule.for(branch).to_pos.except(:branch_id),
            qr_order_mode: branch.qr_order_mode, qr_order_auto_limit: branch.qr_order_auto_limit&.to_s('F'),
            qr_order_auto_max_items: branch.qr_order_auto_max_items,
            tax_categories: Spree::TaxCategory.where(store_id: branch.store_id).order(:name, :id).limit(100).map do |category|
              { id: category.prefixed_id, name: category.name, tax_code: category.tax_code.presence, is_default: category.is_default == true }
            end }
        end

        # How long a booking holds a table, how late it may be, and the
        # service sold when its deposit is kept.
        def reservations!(store, branch, values)
          %w[reservation_grace_minutes reservation_duration_minutes].each do |field|
            next unless values.key?(field)

            minutes = Integer(values[field].to_s, 10) rescue nil # rubocop:disable Style/RescueModifier
            raise Conflict.new('The minutes are invalid.', reason: 'reservation_settings_invalid') unless minutes&.between?(1, 1440)

            branch[field] = minutes
          end
          return unless values.key?('reservation_fee_product_id')

          id = values['reservation_fee_product_id'].presence
          product = id && Spree::Product.find_by_prefix_id(id.to_s)
          raise ActiveRecord::RecordNotFound if id && (product.nil? || product.store_id != store.id)

          branch.reservation_fee_product = product
        end

        # How long a kept bottle waits, whether tips count as revenue in the
        # reports, and how tips are split.
        def bar!(branch, values)
          if values.key?('bottle_keep_days')
            days = Integer(values['bottle_keep_days'].to_s, 10) rescue nil # rubocop:disable Style/RescueModifier
            raise Conflict.new('The days are invalid.', reason: 'bottle_keep_days_invalid') unless days&.between?(1, 3650)

            branch.bottle_keep_days = days
          end
          branch.tips_as_revenue = ActiveModel::Type::Boolean.new.cast(values['tips_as_revenue']) == true if values.key?('tips_as_revenue')
          return unless values.key?('tip_split')

          split = values['tip_split'].to_h.stringify_keys
          rule = TipSplitRule.find_or_initialize_by(branch_id: branch.id)
          rule.mode = split['mode'].to_s if split.key?('mode')
          rule.mode ||= 'equal'
          rule.role_codes = Array(split['role_codes']).map(&:to_s).uniq if split.key?('role_codes')
          unknown = Array(rule.role_codes) - StaffRole.where(store_id: branch.store_id).map(&:prefixed_id)
          raise Conflict.new('The tip split is invalid.', reason: 'tip_split_invalid') if unknown.any? || !rule.valid?

          rule.save!
        end

        # How guests' QR orders are taken. Straight to the kitchen needs an
        # amount limit: an order above it, or with more items than allowed,
        # waits for staff like any other.
        def qr_order!(branch, values)
          branch.qr_order_mode = values['qr_order_mode'].to_s if values.key?('qr_order_mode')
          if values.key?('qr_order_auto_limit')
            limit = values['qr_order_auto_limit'].to_s.strip
            branch.qr_order_auto_limit = limit.empty? ? nil : (Record.money(limit) || raise(Conflict.new('The limit is invalid.', reason: 'qr_order_settings_invalid')))
          end
          if values.key?('qr_order_auto_max_items')
            count = Integer(values['qr_order_auto_max_items'].to_s, 10) rescue nil # rubocop:disable Style/RescueModifier
            raise Conflict.new('The item count is invalid.', reason: 'qr_order_settings_invalid') unless count&.between?(1, 50)

            branch.qr_order_auto_max_items = count
          end
          valid = Branch::QR_ORDER_MODES.include?(branch.qr_order_mode) && (branch.qr_order_auto_limit.nil? || branch.qr_order_auto_limit.positive?)
          raise Conflict.new('The QR order settings are invalid.', reason: 'qr_order_settings_invalid') unless valid
          return unless branch.qr_order_mode == 'direct_to_kitchen' && branch.qr_order_auto_limit.nil?

          raise Conflict.new('Sending guest orders straight to the kitchen needs an amount limit.', reason: 'qr_order_limit_required')
        end

        # The names of the courses, numbered from 1; an empty list goes back
        # to the defaults.
        def labels!(branch, rows)
          names = Array(rows).map { |row| row.is_a?(Hash) ? row.stringify_keys['name'].to_s.strip : row.to_s.strip }
          if names.size > CourseLabel::MAX || names.any? { |name| name.empty? || name.length > 40 }
            raise Conflict.new('The course names are invalid.', reason: 'course_labels_invalid')
          end

          CourseLabel.where(branch_id: branch.id).delete_all
          names.each_with_index { |name, index| CourseLabel.create!(branch: branch, position: index + 1, name: name) }
        end

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::MANAGE)

          raise CanCan::AccessDenied
        end

        def update(store:, staff:, key:, branch:, attributes:)
          values = attributes.to_h.stringify_keys.slice('table_register_id', 'service_charge_rate', 'service_charge_applies_to',
                                                         'service_charge_tax_category_id', 'reservation_grace_minutes',
                                                         'reservation_duration_minutes', 'reservation_fee_product_id', 'course_labels',
                                                         'bottle_keep_days', 'tips_as_revenue', 'tip_split', 'qr_order_mode',
                                                         'qr_order_auto_limit', 'qr_order_auto_max_items')
          payload = { 'command' => 'table_settings.update', 'branch_id' => branch.prefixed_id, 'attributes' => values }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { manage!(store, staff, branch) }) do
            branch.lock!
            before = to_pos(branch).except(:tax_categories)
            if values.key?('table_register_id')
              branch.table_register = values['table_register_id'].presence &&
                                      (Register.locate(Register.where(branch_id: branch.id), values['table_register_id']) || raise(ActiveRecord::RecordNotFound))
            end
            if values.key?('service_charge_rate')
              rate = values['service_charge_rate'].to_s.strip
              branch.service_charge_rate = rate.empty? ? nil : (Record.money(rate) || raise(Conflict.new('The rate is invalid.', reason: 'service_charge_rate_invalid')))
            end
            branch.service_charge_applies_to = Array(values['service_charge_applies_to']).map(&:to_s) if values.key?('service_charge_applies_to')
            if values.key?('service_charge_tax_category_id')
              id = values['service_charge_tax_category_id'].presence
              category = id && Spree::TaxCategory.find_by_prefix_id(id.to_s)
              raise ActiveRecord::RecordNotFound if id && category&.store_id != store.id

              branch.service_charge_tax_category = category
            end
            reservations!(store, branch, values)
            bar!(branch, values)
            qr_order!(branch, values)
            branch.save!
            labels!(branch, values['course_labels']) if values.key?('course_labels')
            after = to_pos(branch)
            AuditEntry.record!(store: store, actor: staff, action: 'table_settings.update', subject: branch,
                               metadata: { before: before, after: after.except(:tax_categories) })
            after
          end
        end
      end
    end
  end
end
