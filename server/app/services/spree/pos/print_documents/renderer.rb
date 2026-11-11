# frozen_string_literal: true

module Spree
  module Pos
    module PrintDocuments
      # Template x data -> a resolved document, mirroring
      # receipt-template/render.ts and variables.ts. The template decides what
      # shows and how it is labelled; it cannot remove the banners, the title
      # and number, the total or the disclaimer. Anything unknown or malformed
      # is skipped rather than failing the print. Lengths count code points,
      # where JavaScript counts UTF-16 units: the two differ only for text
      # outside the Basic Multilingual Plane past a clip limit.
      module Renderer
        MAX_BLOCKS = 8
        MAX_TEXT_LENGTH = 500
        MAX_TITLE_LENGTH = 60
        MAX_LABEL_LENGTH = 40
        MAX_URL_LENGTH = 300
        MAX_CAPTION_LENGTH = 60
        MAX_VARIABLE_LENGTH = 120
        MAX_BARCODE_LENGTH = 24
        ALIGNS = %w[left center right].freeze
        SIZES = %w[s m l].freeze
        ALL_COLUMNS = %w[index name sku unit qty price discount amount].freeze
        TABLE_COLUMNS = %w[qty price discount amount].freeze
        SIGNATURE_PARTIES = %w[buyer seller cashier].freeze
        SOCIAL_PAGES = { 'facebook' => 'https://www.facebook.com/', 'instagram' => 'https://www.instagram.com/' }.freeze
        PCHAR = "(?:[A-Za-z0-9\\-._~!$&'()*+,;=:@]|%[0-9A-Fa-f]{2})"
        WEB_URL = %r{\Ahttps?://[A-Za-z0-9\-._~]+(?::\d+)?(?:/(?:#{PCHAR}|/)*)?(?:\?(?:#{PCHAR}|[/?])*)?(?:\#(?:#{PCHAR}|[/?])*)?\z}i
        VARIABLE = /\{([a-z_]+(?:\.[a-z_]+)?)\}/

        module_function

        def call(config, data, banner: nil)
          config = {} unless config.is_a?(Hash)
          banners = [data[:banner], banner].map { |entry| entry ? Text.trim(entry) : '' }.reject(&:empty?)
          {
            'documentType' => data[:document_type], 'page' => page(config['page']), 'banners' => banners,
            'header' => blocks(config['header'], data, 'header'), 'meta' => field_rows(data[:meta], config['meta']),
            'lines' => lines(data, config['lines']), 'totals' => field_rows(data[:totals], config['totals'], locked: ['total']),
            'payments' => field_rows(data[:payments], config['payments'], fixed_labels: ['methods']),
            'payQr' => pay_qr(data, config['payments']), 'notes' => data[:notes],
            'footer' => blocks(config['footer'], data, 'footer'), 'disclaimer' => data[:disclaimer]
          }
        end

        def clip(value, max)
          value.length > max ? "#{value[0, max - 1]}…" : value
        end

        def pick(value, allowed, fallback)
          value.is_a?(String) && allowed.include?(value) ? value : fallback
        end

        def clamp(value, min, max, fallback)
          value.is_a?(Numeric) && value.to_f.finite? ? value.clamp(min, max) : fallback
        end

        def text_of(value)
          value.is_a?(String) ? Text.trim(value) : ''
        end

        def page(settings)
          settings = {} unless settings.is_a?(Hash)
          { 'margin_mm' => clamp(settings['margin_mm'], 0, 20, 3), 'font' => pick(settings['font'], %w[sans mono], 'sans'),
            'font_size' => pick(settings['font_size'], SIZES, 'm'), 'line_spacing' => clamp(settings['line_spacing'], 1, 1.6, 1.35) }
        end

        def web_url?(value)
          value != '' && value.length <= MAX_URL_LENGTH && value.match?(WEB_URL)
        end

        def store_page(field, data)
          value = Text.trim(data[:store][field.to_sym].to_s)
          return nil if value == ''
          return value if value.match?(%r{\Ahttps?://}i)
          return "https://#{value}" if field == 'url' || value.match?(%r{\A[\w-]+(\.[\w-]+)+(/|\z)})

          "#{SOCIAL_PAGES[field]}#{value.sub(/\A@/, '')}"
        end

        def qr_link(block, data)
          link = if block['source'] == 'url'
                   text_of(block['value'])
                 elsif block['source'] == 'store_social' && %w[url facebook instagram].include?(block['field'])
                   store_page(block['field'], data)
                 end
          link && web_url?(link) ? link : nil
        end

        def signature_labels(block, data)
          parties = block['parties'].is_a?(Array) ? block['parties'] : []
          labels = block['labels'].is_a?(Hash) ? block['labels'] : {}
          SIGNATURE_PARTIES.select { |party| parties.include?(party) }.map do |party|
            custom = clip(text_of(labels[party]), MAX_LABEL_LENGTH)
            { 'party' => party, 'label' => custom.empty? ? data[:signature_labels][party] : custom }
          end
        end

        def business_lines(fields, data)
          return [] unless fields.is_a?(Array)

          store = data[:store]
          values = { 'name' => store[:name], 'branch' => data[:branch][:name], 'address' => store[:address], 'phone' => store[:phone],
                     'email' => store[:email], 'url' => store[:url], 'facebook' => store[:facebook], 'instagram' => store[:instagram] }
          fields.select { |field| field.is_a?(String) && values.key?(field) }.
            map { |field| Text.trim(values[field].to_s) }.reject(&:empty?).map { |value| clip(value, MAX_TEXT_LENGTH) }
        end

        def title_block(label, data)
          custom = clip(text_of(label), MAX_TITLE_LENGTH)
          { 'kind' => 'title', 'title' => custom.empty? ? data[:title] : custom, 'number' => data[:number] }
        end

        def barcode_value?(text)
          text != '' && text.length <= MAX_BARCODE_LENGTH && text.each_char.all? { |char| char.ord.between?(32, 126) }
        end

        def resolve_block(block, data)
          align = pick(block['align'], ALIGNS, 'center')
          case block['type']
          when 'logo' then logo_block(block, data, align)
          when 'qr' then qr_block(block, data, align)
          when 'barcode' then data[:number] && barcode_value?(data[:number]) ? { 'kind' => 'barcode', 'value' => data[:number], 'align' => align } : nil
          when 'signatures'
            parties = signature_labels(block, data)
            parties.any? ? { 'kind' => 'signatures', 'parties' => parties } : nil
          when 'business'
            found = business_lines(block['fields'], data)
            found.any? ? { 'kind' => 'text', 'lines' => found, 'align' => align, 'bold' => false, 'size' => 'm' } : nil
          when 'text' then text_block(block, data, align)
          when 'title' then title_block(block['label'], data)
          when 'divider' then { 'kind' => 'divider', 'style' => pick(block['style'], %w[solid dashed], 'dashed') }
          when 'spacer' then { 'kind' => 'spacer', 'mm' => clamp(block['mm'], 1, 10, 2) }
          end
        end

        def logo_block(block, data, align)
          src = data[:store][:logo_url]
          return nil unless src&.match?(%r{\A(https?://|/)}i)

          { 'kind' => 'image', 'src' => src, 'alt' => data[:store][:name].to_s, 'widthPct' => clamp(block['width_pct'], 20, 100, 60),
            'align' => align, 'monochrome' => block['monochrome'] == true }
        end

        def qr_block(block, data, align)
          value = qr_link(block, data)
          return nil unless value

          caption = clip(text_of(block['caption']), MAX_CAPTION_LENGTH)
          { 'kind' => 'qr', 'value' => value, 'caption' => caption.empty? ? nil : caption, 'align' => align }
        end

        def text_block(block, data, align)
          found = clip(text_of(block['value']), MAX_TEXT_LENGTH).split(/\r?\n/).
                  map { |line| resolve_text(line, data) }.reject { |line| line[:blank] }.map { |line| line[:text] }
          return nil if found.empty?

          { 'kind' => 'text', 'lines' => found, 'align' => align, 'bold' => block['bold'] == true, 'size' => pick(block['size'], SIZES, 'm') }
        end

        def variable_values(data)
          store = data[:store]
          { 'store.name' => store[:name], 'store.address' => store[:address], 'store.phone' => store[:phone], 'store.email' => store[:email],
            'store.url' => store[:url], 'store.facebook' => store[:facebook], 'store.instagram' => store[:instagram],
            'branch.name' => data[:branch][:name], 'branch.code' => data[:branch][:code],
            'branch.return_window_days' => data[:branch][:return_window_days]&.to_s, 'register.name' => data[:register],
            'cashier' => data[:cashier], 'document.number' => data[:number], 'document.time' => data[:time],
            'document.business_date' => data[:business_date], 'document.taxes' => data[:taxes_text],
            'customer.name' => data[:customer_name], 'customer.phone' => data[:customer_phone], 'customer.address' => data[:customer_address],
            'einvoice.lookup_code' => data[:einvoice_lookup_code], 'einvoice.lookup_url' => data[:einvoice_lookup_url],
            'einvoice.buyer_qr' => data[:einvoice_buyer_url] }
        end

        # A line whose known variables are all empty disappears.
        def resolve_text(text, data)
          values = variable_values(data)
          named = 0
          filled = 0
          resolved = text.gsub(VARIABLE) do |whole|
            name = Regexp.last_match(1)
            next whole unless values.key?(name)

            named += 1
            value = clip(Text.trim(values[name].to_s), MAX_VARIABLE_LENGTH)
            filled += 1 unless value.empty?
            value
          end
          { text: resolved, blank: Text.trim(resolved) == '' || (named.positive? && filled.zero?) }
        end

        def blocks(list, data, place)
          result = []
          titled = false
          (list.is_a?(Array) ? list.first(MAX_BLOCKS) : []).each do |block|
            next unless block.is_a?(Hash)

            if block['type'] == 'title'
              next if place == 'footer' || titled

              titled = true
            end
            resolved = resolve_block(block, data)
            result << resolved if resolved
          end
          result << title_block(nil, data) if place == 'header' && !titled
          einvoice = place == 'footer' ? einvoice_qr(data) : nil
          result << einvoice if einvoice
          result
        end

        # While the sale's e-invoice still takes buyer details, the footer
        # always ends with the QR of the buyer's own page; no template can
        # leave it out.
        def einvoice_qr(data)
          url = data[:einvoice_buyer_url].to_s
          return nil unless web_url?(url)

          { 'kind' => 'qr', 'value' => url, 'caption' => data[:einvoice_buyer_caption], 'align' => 'center' }
        end

        def field_rows(rows, section, locked: [], fixed_labels: [])
          section = {} unless section.is_a?(Hash)
          enabled = section['fields'].is_a?(Array) ? section['fields'] : nil
          labels = section['labels'].is_a?(Hash) ? section['labels'] : {}
          rows.select { |row| row[:field].nil? || enabled.nil? || enabled.include?(row[:field]) || locked.include?(row[:field]) }.map do |row|
            custom = row[:field] && !fixed_labels.include?(row[:field]) ? clip(text_of(labels[row[:field]]), MAX_LABEL_LENGTH) : ''
            printed = { 'label' => custom.empty? ? row[:label] : custom, 'value' => row[:value] }
            row[:strong] ? printed.merge('strong' => true) : printed
          end
        end

        def line_name(line, columns)
          columns.include?('sku') && line[:sku] ? "#{line[:name]} (#{line[:sku]})" : line[:name]
        end

        def quantity_text(line, columns)
          "#{line[:quantity]}#{columns.include?('unit') && line[:unit] ? " #{line[:unit]}" : ''}"
        end

        def line_details(line, columns, section)
          details = []
          unless line[:price].nil?
            parts = [columns.include?('qty') ? quantity_text(line, columns) : '', columns.include?('price') ? line[:price] : ''].reject(&:empty?)
            details << parts.join(' × ') if parts.any?
          end
          details << line[:conversion] if section['show_conversion'] != false && line[:conversion]
          details << line[:discount_note] if columns.include?('discount') && line[:discount_note]
          details.concat(line[:trace]) if section['show_trace'] != false
          details + line[:notes]
        end

        def lines(data, section)
          section = {} unless section.is_a?(Hash)
          columns = section['columns'].is_a?(Array) ? section['columns'] & ALL_COLUMNS : ALL_COLUMNS
          index = ->(position) { columns.include?('index') ? position + 1 : nil }
          return table_lines(data, section, columns, index) if section['layout'] == 'table'

          { 'layout' => 'stacked', 'items' => data[:lines].each_with_index.map do |line, position|
            { 'index' => index[position], 'name' => line_name(line, columns), 'amount' => columns.include?('amount') ? line[:amount] : nil,
              'details' => line_details(line, columns, section) }
          end }
        end

        def table_lines(data, section, columns, index)
          keys = TABLE_COLUMNS.select { |key| columns.include?(key) }
          { 'layout' => 'table',
            'headings' => { 'index' => columns.include?('index') ? data[:line_labels][:index] : nil, 'name' => data[:line_labels][:name] },
            'columns' => keys.map { |key| { 'key' => key, 'label' => data[:line_labels][key.to_sym] } },
            'rows' => data[:lines].each_with_index.map do |line, position|
              { 'index' => index[position], 'name' => line_name(line, columns), 'cells' => keys.map { |key| table_cell(line, key, columns) },
                'details' => [*(section['show_conversion'] && line[:conversion] ? [line[:conversion]] : []),
                              *(section['show_trace'] ? line[:trace] : []), *line[:notes]] }
            end }
        end

        def table_cell(line, key, columns)
          case key
          when 'qty' then quantity_text(line, columns)
          when 'price' then line[:price_cell]
          when 'discount' then line[:discount_cell]
          else line[:amount_cell]
          end
        end

        def pay_qr(data, section)
          qr = data[:pay_qr]
          return nil unless qr

          section = {} unless section.is_a?(Hash)
          return nil if section['fields'].is_a?(Array) && !section['fields'].include?('pay_qr')

          custom = clip(text_of((section['labels'].is_a?(Hash) ? section['labels'] : {})['pay_qr']), MAX_LABEL_LENGTH)
          { 'value' => qr[:value], 'caption' => custom.empty? ? qr[:caption] : custom, 'lines' => qr[:lines] }
        end
      end
    end
  end
end
