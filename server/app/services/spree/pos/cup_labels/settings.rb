# frozen_string_literal: true

module Spree
  module Pos
    module CupLabels
      # A branch's cup label setup, read from `branches.cup_label_settings`
      # with defaults for what is not set: the label size, which fields
      # print, and how long a ready call number stays on the call board.
      # The layout itself is fixed (Document).
      module Settings
        SIZES = { '40x30' => [40, 30], '50x30' => [50, 30], '58x40' => [58, 40] }.freeze
        DEFAULT_SIZE = '50x30'
        # The item name and the "n/N" count always print.
        FIELDS = %w[call_number options note guest_name time store_name].freeze
        PICKUP_MINUTES = (1..120)
        DEFAULT_PICKUP_MINUTES = 15
        KEYS = %w[size fields pickup_minutes].freeze

        module_function

        def for(branch)
          stored = branch.cup_label_settings.to_h
          size = SIZES.key?(stored['size']) ? stored['size'] : DEFAULT_SIZE
          fields = stored['fields'].is_a?(Array) ? FIELDS & stored['fields'] : FIELDS
          minutes = stored['pickup_minutes']
          minutes = DEFAULT_PICKUP_MINUTES unless minutes.is_a?(Integer) && PICKUP_MINUTES.cover?(minutes)
          { 'size' => size, 'fields' => fields, 'pickup_minutes' => minutes }
        end

        # The settings as stored after a change, or a Conflict naming the
        # field that is wrong. Fields left out keep their current value.
        def merge!(branch, attributes)
          values = self.for(branch).merge(attributes.to_h.slice(*KEYS))
          invalid!('size') unless SIZES.key?(values['size'])
          fields = values['fields']
          invalid!('fields') unless fields.is_a?(Array) && fields.all? { |field| FIELDS.include?(field) }
          minutes = Integer(values['pickup_minutes'].to_s, exception: false)
          invalid!('pickup_minutes') unless minutes && PICKUP_MINUTES.cover?(minutes)
          { 'size' => values['size'], 'fields' => FIELDS & fields, 'pickup_minutes' => minutes }
        end

        def label_mm(settings)
          width, height = SIZES.fetch(settings['size'])
          { 'width_mm' => width, 'height_mm' => height }
        end

        def invalid!(field)
          raise Conflict.new("The cup label #{field.tr('_', ' ')} is invalid.", reason: 'cup_label_settings_invalid',
                                                                                details: { field: field })
        end
      end
    end
  end
end
