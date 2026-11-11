# frozen_string_literal: true

require 'json_schemer'
require 'yaml'

# Checks a POS response against a component schema in openapi/pos-staff.yaml.
# Context is the whole body. Other responses validate `data`, and each element
# when `data` is a list.
module PosSchemaHelpers
  def expect_pos_schema!(response, name)
    body = response.parsed_body
    payload = name == 'Context' ? body : body.fetch('data')
    schema = pos_component_schema(name)
    records = payload.is_a?(Array) ? payload : [payload]
    records.each do |record|
      errors = JSONSchemer.schema(schema).validate(record).to_a
      expect(errors).to eq([]), errors.map { |error| error['error'] }.join('; ')
    end
  end

  def pos_component_schema(name)
    document = YAML.safe_load_file(Rails.root.join('openapi/pos-staff.yaml'), aliases: true)
    schema = document.dig('components', 'schemas', name)
    raise "Missing POS schema #{name}" if schema.nil?

    schema.merge('components' => document['components'])
  end
end
