# frozen_string_literal: true

module Spree
  module Pos
    module VehicleVisits
      # Adds or changes a bus operator of the store, or archives it. The
      # branch named is where the person manages coach visits.
      module SaveBusOperator
        COMMAND = 'bus_operator.save'
        FIELDS = %w[name phone note status].freeze

        module_function

        def call(store:, staff:, key:, branch_id:, attributes:, operator_id: nil)
          branch = Guard.branch!(store, branch_id)
          values = attributes.to_h.transform_keys(&:to_s).slice(*FIELDS)
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'operator_id' => operator_id.to_s.presence }.
                    merge(values.transform_values(&:to_s))
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            operator = operator_id ? Guard.operator!(store, operator_id, active: false).tap(&:lock!) : BusOperator.new(store: store)
            operator.name = Guard.text!(values['name'], 120, 'name') if values.key?('name') || operator.new_record?
            operator.phone = Guard.text!(values['phone'], 32, 'phone') if values.key?('phone')
            operator.note = Guard.text!(values['note'], 500, 'note') if values.key?('note')
            operator.status = values['status'] if values.key?('status')
            unless operator.valid?
              reason = operator.errors.of_kind?(:name, :taken) ? 'bus_operator_taken' : 'bus_operator_invalid'
              raise Conflict.new('The bus operator is invalid.', reason: reason, details: { fields: operator.errors.attribute_names })
            end

            operator.save!
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: operator,
                               metadata: { name: operator.name, status: operator.status })
            operator.to_pos
          end
        end
      end
    end
  end
end
