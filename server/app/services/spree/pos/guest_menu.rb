# frozen_string_literal: true

module Spree
  module Pos
    # What a guest's phone reads from the table QR: the branch menu as the
    # counter sells it now (time-of-day prices, hidden items left out,
    # today's sold-out marks), restricted to items open to guests, without
    # anything the guest has no business seeing: SKUs, barcodes, list
    # prices, kitchen routing, tax or cost. Door tickets stay at the counter.
    # A self-ordering kiosk (channel: :kiosk) reads the same menu with
    # every item the counter sells, not only those open to the table QR.
    module GuestMenu
      module_function

      CHANNELS = %i[qr kiosk].freeze

      def call(branch, channel: :qr)
        menu = Menu::Reader.call(branch: branch)
        items = orderable(branch, menu[:items], channel).map { |row| item_row(row) }
        group_ids = items.flat_map { |row| row[:modifier_group_ids] }.to_set
        category_ids = items.filter_map { |row| row[:menu_category_id] }.to_set
        body = {
          currency: menu[:currency],
          categories: menu[:categories].select { |row| category_ids.include?(row[:id]) }.map { |row| row.slice(:id, :name, :position, :color) },
          items: items,
          modifier_groups: menu[:modifier_groups].select { |row| group_ids.include?(row[:id]) }.map { |row| group_row(row) }
        }
        body.merge(etag: Digest::SHA256.hexdigest(body.to_json)[0, 32])
      end

      # Menu rows of items guests may order, by variant id.
      def variants(branch, channel: :qr)
        orderable(branch, Menu::Reader.call(branch: branch)[:items], channel).each_with_object({}) do |row, index|
          row[:variants].each { |variant| index[variant[:id]] = row }
        end
      end

      def orderable(branch, rows, channel = :qr)
        raise ArgumentError, "Unknown menu channel: #{channel}" unless CHANNELS.include?(channel)

        scope = MenuItem.for_store(branch.store).where(drink_credit: nil)
        scope = scope.where(qr_orderable: true) if channel == :qr
        allowed = scope.pluck(:id).
                  to_set { |id| MenuItem.prefixed_for(id) }
        rows.select { |row| allowed.include?(row[:id]) }
      end

      def item_row(row)
        {
          id: row[:id], name: row[:name], kind: row[:kind], menu_category_id: row[:menu_category_id], position: row[:position],
          image_url: row[:image_url], sold_out: row[:sold_out], modifier_group_ids: row[:modifier_group_ids],
          components: row[:components].map { |component| component.slice(:name, :quantity) },
          variants: row[:variants].map { |variant| variant.slice(:id, :name, :price, :price_label) }
        }
      end

      def group_row(row)
        {
          id: row[:id], name: row[:name], min_select: row[:min_select], max_select: row[:max_select],
          allow_quantity: row[:allow_quantity], required: row[:required],
          options: row[:options].select { |option| option[:active] }.map { |option| option.slice(:id, :name, :price_delta, :default_selected) }
        }
      end
    end
  end
end
