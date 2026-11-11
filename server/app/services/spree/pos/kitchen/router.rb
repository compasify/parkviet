# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # Which station makes a sale line, first match wins:
      #   1. a route for the product and the service mode;
      #   2. a route for the product, every mode;
      #   3. a route for the item's kitchen category and the service mode;
      #   4. a route for the kitchen category, every mode;
      #   5. the branch's default station, else its first active station.
      # Never raises for a missing route: a branch with an active station
      # always gets one, and only a branch without any gets nil. One instance
      # serves one send and reads the routes once.
      class Router
        def self.station_for(branch, sale_line, service_mode)
          new(branch).station_for(sale_line, service_mode)
        end

        def initialize(branch)
          @branch = branch
          @categories = {}
        end

        def station_for(sale_line, service_mode)
          route_for(sale_line.variant.product_id, category_of(sale_line), service_mode)
        end

        # The same choice for a product of the menu, without a sale line.
        def station_for_product(product_id, kitchen_category, service_mode)
          route_for(product_id, kitchen_category, service_mode)
        end

        def stations
          @stations ||= KitchenStation.where(branch_id: @branch.id).active.ordered.to_a
        end

        private

        def route_for(product_id, category, service_mode)
          mode = service_mode.to_s.presence
          candidates = [
            routes[[:product, product_id, mode]],
            routes[[:product, product_id, nil]],
            category && routes[[:category, category, mode]],
            category && routes[[:category, category, nil]]
          ]
          candidates.compact.first || fallback
        end

        def fallback
          stations.find(&:is_default) || stations.first
        end

        # Routes to inactive stations are skipped as if absent.
        def routes
          @routes ||= begin
            live = stations.index_by(&:id)
            StationRoute.where(branch_id: @branch.id, kitchen_station_id: live.keys).to_a.to_h do |route|
              target = route.product_id ? [:product, route.product_id] : [:category, route.kitchen_category]
              [[*target, route.service_mode], live[route.kitchen_station_id]]
            end
          end
        end

        def category_of(sale_line)
          product_id = sale_line.variant.product_id
          return @categories[product_id] if @categories.key?(product_id)

          @categories[product_id] = MenuItem.where(store_id: @branch.store_id, product_id: product_id).pick(:kitchen_category)
        end
      end
    end
  end
end
