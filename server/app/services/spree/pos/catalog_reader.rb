# frozen_string_literal: true

module Spree
  module Pos
    # The caller must resolve the branch's authorized assortment on the server.
    # This object is not an authorization boundary and must not receive a
    # client-supplied scope or be exposed until an assortment policy exists.
    class CatalogReader
      MAX_LIMIT = 100
      MAX_QUERY_LENGTH = 200

      def initialize(store:, products:, stock_location: nil, currency: nil)
        raise ArgumentError, 'an authorized product relation is required' unless products.is_a?(ActiveRecord::Relation) && products.klass == Spree::Product
        raise ArgumentError, 'stock location must belong to the store' if stock_location && stock_location.store_id != store.id

        @store = store
        @products = products.where(spree_products: { store_id: store.id })
        @stock_location = stock_location
        @currency = currency || store.default_currency
      end

      def search(query:, page: 1, limit: 25, exact_barcode: false)
        raise ArgumentError, 'query must be a string' unless query.is_a?(String)

        query = query.strip
        raise ArgumentError, 'invalid query' if query.length > MAX_QUERY_LENGTH || (exact_barcode && query.empty?)

        page = Integer(page)
        limit = Integer(limit)
        raise ArgumentError, 'invalid pagination' if page < 1 || page > 2_147_483_647 || limit < 1

        limit = [limit, MAX_LIMIT].min
        scope = Spree::Variant.joins(:product).where(product_id: @products.select(:id))
        scope = scope.where('spree_variants.discontinue_on IS NULL OR spree_variants.discontinue_on > ?', Time.current)
        # A product with option variants is sold through them, never through its master.
        scope = scope.where(<<~SQL.squish)
          spree_variants.is_master = FALSE OR NOT EXISTS (
            SELECT 1 FROM spree_variants options
            WHERE options.product_id = spree_variants.product_id AND options.is_master = FALSE AND options.deleted_at IS NULL
          )
        SQL
        scope = if exact_barcode
                  scope.where(barcode: query)
                elsif query.empty?
                  scope
                else
                  escaped = ActiveRecord::Base.sanitize_sql_like(query)
                  scope.where('spree_products.name ILIKE :term OR spree_variants.sku ILIKE :term OR spree_variants.barcode ILIKE :term', term: "%#{escaped}%")
                end
        scope = scope.order('spree_variants.id ASC')
        count = scope.count
        variants = scope.includes(:product, :prices).offset((page - 1) * limit).limit(limit).to_a
        levels = if @stock_location
                   Spree::StockLevel.where(stock_location_id: @stock_location.id, variant_id: variants.map(&:id)).index_by(&:variant_id)
                 else
                   {}
                 end
        {
          data: variants.map { |variant|
            price = SalesChannel.price(variant, store: @store, currency: @currency)
            {
              id: variant.prefixed_id,
              product_id: variant.product.prefixed_id,
              name: variant.product.name,
              sku: variant.sku,
              barcode: variant.barcode,
              price: price&.amount&.to_s('F'),
              compare_at_price: price&.compare_at_amount&.to_s('F'),
              currency: @currency,
              stock_on_hand: levels[variant.id]&.count_on_hand
            }
          },
          meta: { page: page, limit: limit, count: count, pages: (count + limit - 1) / limit,
                  ambiguous: exact_barcode && count > 1 }
        }
      end
    end
  end
end
