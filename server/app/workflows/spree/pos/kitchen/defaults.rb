# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # The kitchen a table-service shop starts with: the profile's stations
      # (Bếp, Bar) and a route sending drinks (kitchen category `do_uong`)
      # to the bar; everything else goes to the default station, the first.
      # Both only fill what is missing, so running them again changes
      # nothing, and managers edit the result like any station or route.
      # Each record is audited like the kitchen setup commands.
      module Defaults
        BAR_CATEGORY = 'do_uong'
        NAMES = { 'prep' => 'Bếp', 'bar' => 'Bar' }.freeze

        module_function

        # The profile's station kinds, when the branch has no station yet.
        def stations!(store:, actor:, branch:, kinds:)
          return [] if KitchenStation.where(branch_id: branch.id).exists?

          kinds.each_with_index.map do |kind, index|
            station = KitchenStation.create!(store: store, branch: branch, name: NAMES.fetch(kind), kind: kind,
                                             is_default: index.zero?, position: index)
            AuditEntry.record!(store: store, actor: actor, action: 'kitchen_station.create', subject: station,
                               metadata: { 'name' => station.name, 'kind' => kind, 'source' => 'profile' })
            station
          end
        end

        # Drinks to the first active bar station, unless a route for the
        # category exists already.
        def routes!(store:, actor:, branch:)
          bar = KitchenStation.where(branch_id: branch.id, kind: 'bar').active.ordered.first
          return [] if bar.nil? || StationRoute.where(branch_id: branch.id, kitchen_category: BAR_CATEGORY).exists?

          route = StationRoute.create!(store: store, branch: branch, kitchen_station: bar, kitchen_category: BAR_CATEGORY)
          AuditEntry.record!(store: store, actor: actor, action: 'station_route.create', subject: route,
                             metadata: { 'kitchen_category' => BAR_CATEGORY, 'kitchen_station_id' => bar.prefixed_id,
                                         'source' => 'profile' })
          [route]
        end
      end
    end
  end
end
