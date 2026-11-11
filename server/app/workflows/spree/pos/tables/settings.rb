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
            tax_categories: Spree::TaxCategory.where(store_id: branch.store_id).order(:name, :id).limit(100).map do |category|
              { id: category.prefixed_id, name: category.name, tax_code: category.tax_code.presence, is_default: category.is_default == true }
            end }
        end

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::MANAGE)

          raise CanCan::AccessDenied
        end

        def update(store:, staff:, key:, branch:, attributes:)
          values = attributes.to_h.stringify_keys.slice('table_register_id', 'service_charge_rate', 'service_charge_applies_to',
                                                         'service_charge_tax_category_id')
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
            branch.save!
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
