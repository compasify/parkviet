# frozen_string_literal: true

module Spree
  module Pos
    module Menu
      # The menu a branch sells from right now, in one read: categories,
      # items with their sizes and current prices (a running time-of-day menu
      # applied, hidden items left out), modifier groups, today's sold-out
      # items and the favourites row. Only active items whose product the
      # branch may sell are listed. `etag` changes whenever any of it does.
      class Reader
        THUMBNAIL = [256, 256].freeze

        def self.call(branch:, now: Workspace.business_now)
          new(branch, now).call
        end

        def initialize(branch, now)
          @branch = branch
          @store = branch.store
          @now = now
        end

        def call
          schedules = Pricing.running_schedules(branch, now)
          business_date = BusinessDay.for(branch, now)
          sold_out = MenuAvailability.sold_out_ids(branch, business_date).to_set
          items = menu_items.filter_map { |item| item_row(item, schedules, sold_out) }
          group_ids = items.flat_map { |row| row[:modifier_group_ids] }.uniq
          groups = ModifierGroup.for_store(store).includes(modifier_options: :variant).to_a.
                   select { |group| group_ids.include?(group.prefixed_id) }
          item_ids = items.to_set { |row| row[:id] }
          favorites = MenuFavorite.where(branch_id: branch.id).includes(:menu_item).order(:position, :id).
                      map { |row| row.menu_item.prefixed_id }.select { |id| item_ids.include?(id) }
          body = {
            branch_id: branch.prefixed_id, currency: store.default_currency, business_date: business_date.iso8601,
            module_enabled: ModulePolicy.enabled?(branch, Guard::MODULE),
            categories: MenuCategory.for_store(store).where(active: true).order(:position, :name).map(&:to_pos),
            items: items, modifier_groups: groups.sort_by { |group| [group.position, group.id] }.map(&:to_pos),
            schedules: schedules.map { |schedule| { id: schedule.prefixed_id, name: schedule.name } },
            favorites: favorites
          }
          body.merge(etag: Digest::SHA256.hexdigest(body.to_json)[0, 32])
        end

        private

        attr_reader :branch, :store, :now

        def menu_items
          sellable = SalesChannel.sellable_products(store).where(id: BranchProduct.where(branch_id: branch.id).select(:product_id))
          MenuItem.for_store(store).active.where(product_id: sellable.select(:id)).
            includes({ product: [:tax_category, :primary_media, { variants: [:prices, :option_values] }] }, :menu_category,
                     { menu_item_modifier_groups: :modifier_group }, { combo_components: { variant: :product } }).
            order(:position, :id).to_a
        end

        def item_row(item, schedules, sold_out)
          variants = item.sizes(now: now).filter_map { |variant| size_row(item, variant, schedules) }
          return if variants.empty?

          item.to_pos.merge(
            image_url: image_url(item.product), sold_out: sold_out.include?(item.id), variants: variants
          )
        end

        def size_row(item, variant, schedules)
          scheduled, schedule = Pricing.scheduled_price(branch, item, variant, now, schedules: schedules)
          list = SalesChannel.price(variant, store: store, currency: store.default_currency)&.amount
          price = scheduled || list
          return if price.nil?

          {
            id: variant.prefixed_id, name: variant.is_master? ? nil : variant.options_text.presence, sku: variant.sku.presence,
            barcode: variant.barcode.presence, price: price.to_s('F'), list_price: list&.to_s('F'),
            schedule_id: schedule&.prefixed_id
          }
        rescue Conflict => e
          raise unless e.reason == 'menu_item_hidden'

          nil
        end

        # A small rendition of the product's first image, or nil. A broken
        # attachment must not stop the menu from loading.
        def image_url(product)
          image = product.primary_media || product.media.first
          attachment = image.try(:attachment)
          return unless attachment.respond_to?(:attached?) && attachment.attached?

          helpers = Rails.application.routes.url_helpers
          if attachment.respond_to?(:variable?) && attachment.variable?
            helpers.rails_representation_path(attachment.variant(resize_to_limit: THUMBNAIL), only_path: true)
          else
            helpers.rails_blob_path(attachment, only_path: true)
          end
        rescue StandardError => e
          Rails.logger.warn("[pos] menu image for #{product.prefixed_id} failed: #{e.class}: #{e.message}")
          nil
        end
      end
    end
  end
end
