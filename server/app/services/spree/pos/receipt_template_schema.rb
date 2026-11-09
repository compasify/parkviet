# frozen_string_literal: true

module Spree
  module Pos
    # Validates a print template config (schema 1) for one document type.
    # Every key, block type, field, column and variable is whitelisted, and a
    # field is accepted only for a document type that carries its data. The
    # parts every document must print (copy and pre-bill banners, title and
    # number, total, e-invoice disclaimer) are not in the schema, so a
    # template cannot switch them off.
    #
    # Errors carry a JSON pointer into the request body
    # (`/config/footer/1/value`) so the editor can mark the offending block.
    class ReceiptTemplateSchema
      VERSION = 1
      MAX_BYTES = 16 * 1024
      MAX_BLOCKS = 8
      MAX_TEXT_LENGTH = 500
      MAX_TITLE_LENGTH = 60
      MAX_LABEL_LENGTH = 40

      DOCUMENT_TYPES = %w[sale prebill payment_ticket return refund shift_closure].freeze
      ALIGNS = %w[left center right].freeze
      SIZES = %w[s m l].freeze
      FONTS = %w[sans mono].freeze
      LAYOUTS = %w[stacked table].freeze
      DIVIDER_STYLES = %w[solid dashed].freeze
      BUSINESS_FIELDS = %w[name branch address phone email url facebook instagram].freeze
      # A QR code links to a page given here or to one of the store's own.
      QR_SOURCES = %w[url store_social].freeze
      SOCIAL_FIELDS = %w[url facebook instagram].freeze
      MAX_URL_LENGTH = 300
      MAX_CAPTION_LENGTH = 60
      SIGNATURE_PARTIES = %w[buyer seller cashier].freeze
      # Document types printed in several copies with one press; each copy is
      # recorded as its own print.
      COPIES_TYPES = %w[sale].freeze
      MAX_COPIES = 3

      # Shared with the POS client, which resolves exactly these names.
      VARIABLES = JSON.parse(Rails.root.join('config/pos/receipt_template_variables.json').read).freeze
      VARIABLE_PATTERN = /\{([a-z_]+(?:\.[a-z_]+)?)\}/

      BLOCK_KEYS = {
        'logo' => %w[type width_pct align monochrome],
        'business' => %w[type fields align],
        'text' => %w[type value align bold size],
        'title' => %w[type label],
        'divider' => %w[type style],
        'spacer' => %w[type mm],
        'qr' => %w[type source value field caption align],
        'barcode' => %w[type align],
        'signatures' => %w[type parties labels]
      }.freeze

      TOP_KEYS = %w[schema page header meta lines totals payments footer].freeze
      REQUIRED_KEYS = %w[schema page header footer].freeze
      PAGE_KEYS = %w[margin_mm font font_size line_spacing copies].freeze
      REQUIRED_PAGE_KEYS = %w[margin_mm font font_size line_spacing].freeze
      LINES_KEYS = %w[layout columns show_trace show_conversion].freeze
      FIELD_SECTION_KEYS = %w[fields labels].freeze

      META_ALL = %w[time cashier register branch order_number return_number customer].freeze
      COLUMNS_ALL = %w[index name sku unit qty price discount amount].freeze
      TOTALS_ALL = %w[item_total discount tax included_tax total].freeze
      PAYMENTS_ALL = %w[methods handed change reference paid_total debt due_on].freeze

      # Sections and fields each document type has data for; a section that
      # is absent here does not exist on that document.
      SECTIONS = {
        'sale' => { 'meta' => META_ALL, 'lines' => COLUMNS_ALL, 'totals' => TOTALS_ALL, 'payments' => PAYMENTS_ALL },
        'prebill' => {
          'meta' => %w[time register branch customer], 'lines' => %w[index name sku unit qty price amount],
          'totals' => %w[item_total discount total], 'payments' => %w[paid_total]
        },
        'payment_ticket' => {
          'meta' => %w[time cashier register branch order_number customer], 'lines' => COLUMNS_ALL,
          'totals' => %w[item_total discount tax total], 'payments' => %w[methods handed change]
        },
        'return' => { 'meta' => META_ALL, 'lines' => %w[index name sku amount], 'totals' => %w[total] },
        'refund' => { 'meta' => META_ALL, 'payments' => %w[methods reference] },
        'shift_closure' => { 'meta' => %w[time cashier register branch] }
      }.freeze

      # Payment method rows are labelled by their method.
      FIXED_LABELS = { 'payments' => %w[methods] }.freeze

      # Raised with every problem found; `errors` lists
      # `{ pointer:, code:, message: }`.
      class Invalid < StandardError
        attr_reader :errors

        def initialize(errors)
          @errors = errors
          super(errors.first&.fetch(:message) || 'Invalid receipt template.')
        end

        def self.at(pointer, code, message)
          new([{ pointer: pointer, code: code, message: message }])
        end
      end

      def self.validate(config, document_type, root: '/config')
        new(config, document_type, root).errors
      end

      def self.validate!(config, document_type, root: '/config')
        errors = validate(config, document_type, root: root)
        raise Invalid, errors if errors.any?

        config
      end

      attr_reader :errors

      def initialize(config, document_type, root)
        @errors = []
        @root = root
        @document_type = document_type
        @sections = SECTIONS.fetch(document_type) { raise ArgumentError, "Unknown document type #{document_type}" }
        check_config(config)
      end

      private

      def add(pointer, code, message)
        @errors << { pointer: pointer, code: code, message: message }
        nil
      end

      def at(*parts)
        ([@root] + parts.map { |part| part.to_s.gsub('~', '~0').gsub('/', '~1') }).join('/')
      end

      def check_config(config)
        return add(at, 'invalid_type', 'Config must be an object.') unless config.is_a?(Hash)
        return add(at, 'too_large', "Config must be at most #{MAX_BYTES / 1024} KB.") if config.to_json.bytesize > MAX_BYTES

        known_keys(config, TOP_KEYS)
        REQUIRED_KEYS.each { |key| add(at(key), 'missing', "#{key} is required.") unless config.key?(key) }
        add(at('schema'), 'unsupported', "Schema must be #{VERSION}.") if config.key?('schema') && config['schema'] != VERSION
        check_page(config['page']) if config.key?('page')
        %w[header footer].each { |place| check_blocks(config[place], place) if config.key?(place) }
        %w[meta totals payments].each { |section| check_section(config, section) { check_fields(config[section], section) } }
        check_section(config, 'lines') { check_lines(config['lines']) }
      end

      def known_keys(hash, allowed, *path)
        (hash.keys - allowed).each { |key| add(at(*path, key), 'unknown_key', "#{key} is not supported.") }
      end

      def object?(value, *path)
        return true if value.is_a?(Hash)

        add(at(*path), 'invalid_type', "#{path.last} must be an object.")
        false
      end

      def check_section(config, section)
        return unless config.key?(section)
        return add(at(section), 'section_unavailable', "This document has no #{section}.") unless @sections.key?(section)

        yield
      end

      def check_page(page)
        return unless object?(page, 'page')

        known_keys(page, PAGE_KEYS, 'page')
        REQUIRED_PAGE_KEYS.each { |key| add(at('page', key), 'missing', "#{key} is required.") unless page.key?(key) }
        check_copies(page) if page.key?('copies')
        number(page, 'margin_mm', 0, 20, 'page') if page.key?('margin_mm')
        number(page, 'line_spacing', 1, 1.6, 'page') if page.key?('line_spacing')
        choice(page, 'font', FONTS, 'page') if page.key?('font')
        choice(page, 'font_size', SIZES, 'page') if page.key?('font_size')
      end

      def check_copies(page)
        return add(at('page', 'copies'), 'field_unavailable', 'This document prints one copy at a time.') unless COPIES_TYPES.include?(@document_type)
        return if page['copies'].is_a?(Integer) && page['copies'].between?(1, MAX_COPIES)

        add(at('page', 'copies'), 'invalid_value', "copies must be a whole number from 1 to #{MAX_COPIES}.")
      end

      def check_blocks(blocks, place)
        return add(at(place), 'invalid_type', "#{place} must be a list.") unless blocks.is_a?(Array)
        return add(at(place), 'too_many', "#{place} may have at most #{MAX_BLOCKS} blocks.") if blocks.length > MAX_BLOCKS

        titles = 0
        blocks.each_with_index do |block, index|
          next unless object?(block, place, index)

          keys = BLOCK_KEYS[block['type']]
          next add(at(place, index, 'type'), 'unknown_block', "Block type #{block['type'].inspect} is not supported.") if keys.nil?

          known_keys(block, keys, place, index)
          if block['type'] == 'title'
            titles += 1
            next add(at(place, index), 'misplaced', 'The title belongs in the header.') if place == 'footer'
            next add(at(place, index), 'duplicate', 'The header has one title.') if titles > 1
          end
          check_block(block, place, index)
        end
      end

      def check_block(block, *path)
        choice(block, 'align', ALIGNS, *path) if block.key?('align')
        case block['type']
        when 'logo'
          number(block, 'width_pct', 20, 100, *path) if block.key?('width_pct')
          boolean(block, 'monochrome', *path) if block.key?('monochrome')
        when 'business'
          list(block, 'fields', BUSINESS_FIELDS, *path, required: true, present: true)
        when 'text'
          check_text(block, *path)
        when 'title'
          text?(block, 'label', MAX_TITLE_LENGTH, *path) if block.key?('label')
        when 'divider'
          choice(block, 'style', DIVIDER_STYLES, *path) if block.key?('style')
        when 'spacer'
          number(block, 'mm', 1, 10, *path) if block.key?('mm')
        when 'qr'
          check_qr(block, *path)
        when 'signatures'
          check_signatures(block, *path)
        end
      end

      # `url` prints the link given; `store_social` the store's website,
      # Facebook or Instagram page (`field`), read when printing.
      def check_qr(block, *path)
        text?(block, 'caption', MAX_CAPTION_LENGTH, *path) if block.key?('caption')
        return add(at(*path, 'source'), 'missing', 'source is required.') unless block.key?('source')
        return choice(block, 'source', QR_SOURCES, *path) unless QR_SOURCES.include?(block['source'])

        if block['source'] == 'url'
          add(at(*path, 'field'), 'unknown_key', 'field is not supported.') if block.key?('field')
          return add(at(*path, 'value'), 'missing', 'A link is required.') unless block.key?('value')
          return unless text?(block, 'value', MAX_URL_LENGTH, *path)

          add(at(*path, 'value'), 'invalid_url', 'The link must start with http:// or https://.') unless web_url?(block['value'])
        else
          add(at(*path, 'value'), 'unknown_key', 'value is not supported.') if block.key?('value')
          return add(at(*path, 'field'), 'missing', 'field is required.') unless block.key?('field')

          choice(block, 'field', SOCIAL_FIELDS, *path)
        end
      end

      def web_url?(value)
        uri = URI.parse(value)
        uri.is_a?(URI::HTTP) && uri.host.present?
      rescue URI::InvalidURIError
        false
      end

      def check_signatures(block, *path)
        list(block, 'parties', SIGNATURE_PARTIES, *path, required: true, present: true)
        return unless block.key?('labels')

        labels = block['labels']
        return unless object?(labels, *path, 'labels')

        labels.each_key do |party|
          next text?(labels, party, MAX_LABEL_LENGTH, *path, 'labels') if SIGNATURE_PARTIES.include?(party)

          add(at(*path, 'labels', party), 'unknown_key', "#{party} is not a signature.")
        end
      end

      def check_text(block, *path)
        choice(block, 'size', SIZES, *path) if block.key?('size')
        boolean(block, 'bold', *path) if block.key?('bold')
        return add(at(*path, 'value'), 'missing', 'Text is required.') unless block.key?('value')
        return unless text?(block, 'value', MAX_TEXT_LENGTH, *path)
        return add(at(*path, 'value'), 'blank', 'Text cannot be empty.') if block['value'].strip.empty?

        block['value'].scan(VARIABLE_PATTERN).flatten.uniq.each do |name|
          next if VARIABLES.include?(name)

          add(at(*path, 'value'), 'unknown_variable', "{#{name}} is not a known variable.")
        end
      end

      def check_lines(lines)
        return unless object?(lines, 'lines')

        known_keys(lines, LINES_KEYS, 'lines')
        LINES_KEYS.each { |key| add(at('lines', key), 'missing', "#{key} is required.") unless lines.key?(key) }
        choice(lines, 'layout', LAYOUTS, 'lines') if lines.key?('layout')
        list(lines, 'columns', @sections.fetch('lines'), 'lines') if lines.key?('columns')
        %w[show_trace show_conversion].each { |key| boolean(lines, key, 'lines') if lines.key?(key) }
      end

      def check_fields(section, name)
        return unless object?(section, name)

        allowed = @sections.fetch(name)
        known_keys(section, FIELD_SECTION_KEYS, name)
        list(section, 'fields', allowed, name, required: true)
        return unless section.key?('labels')

        labels = section['labels']
        return unless object?(labels, name, 'labels')

        fixed = FIXED_LABELS.fetch(name, [])
        labels.each_key do |field|
          if !allowed.include?(field) || fixed.include?(field)
            add(at(name, 'labels', field), 'field_unavailable', "#{field} has no label on this document.")
          else
            text?(labels, field, MAX_LABEL_LENGTH, name, 'labels')
          end
        end
      end

      def list(hash, key, allowed, *path, required: false, present: false)
        return add(at(*path, key), 'missing', "#{key} is required.") if required && !hash.key?(key)

        values = hash[key]
        return add(at(*path, key), 'invalid_type', "#{key} must be a list.") unless values.is_a?(Array)
        return add(at(*path, key), 'blank', "#{key} cannot be empty.") if present && values.empty?

        values.each_with_index do |value, index|
          unless allowed.include?(value)
            add(at(*path, key, index), 'field_unavailable', "#{value.inspect} is not available on this document.")
            next
          end
          add(at(*path, key, index), 'duplicate', "#{value} is listed twice.") if values.index(value) != index
        end
      end

      def text?(hash, key, max, *path)
        value = hash[key]
        unless value.is_a?(String)
          add(at(*path, key), 'invalid_type', "#{key} must be text.")
          return false
        end
        if value.length > max
          add(at(*path, key), 'too_long', "#{key} must be at most #{max} characters.")
          return false
        end
        true
      end

      def choice(hash, key, allowed, *path)
        add(at(*path, key), 'invalid_value', "#{key} must be one of #{allowed.join(', ')}.") unless allowed.include?(hash[key])
      end

      def boolean(hash, key, *path)
        add(at(*path, key), 'invalid_type', "#{key} must be true or false.") unless [true, false].include?(hash[key])
      end

      def number(hash, key, min, max, *path)
        value = hash[key]
        return if value.is_a?(Numeric) && value.finite? && value.between?(min, max)

        add(at(*path, key), 'invalid_value', "#{key} must be a number from #{min} to #{max}.")
      end
    end
  end
end
