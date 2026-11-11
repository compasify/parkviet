# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # A branch's kitchen setup: stations, the routes that send items to
      # them, and when orders are sent. Every change is one command with an
      # idempotency key and an audit entry. Adding a station or a route needs
      # `fnb.kitchen` on at the branch; changing or removing what exists does not.
      module Setup
        STATION_FIELDS = %w[name kind kds_enabled is_default warn_after_minutes late_after_minutes position active].freeze
        ROUTE_FIELDS = %w[kitchen_category service_mode].freeze

        module_function

        def create_station(store:, staff:, key:, branch:, attributes:)
          run(store, staff, key, branch, 'kitchen_station.create', attributes) do
            ModulePolicy.require!(branch, Send::MODULE)
            station = KitchenStation.new(store: store, branch: branch)
            save_station!(station, branch, attributes)
            audit!(store, staff, 'kitchen_station.create', station, attributes)
            station.to_pos
          end
        end

        def update_station(store:, staff:, key:, station:, attributes:)
          run(store, staff, key, station.branch, 'kitchen_station.update', attributes.merge('id' => station.prefixed_id)) do
            station.lock!
            save_station!(station, station.branch, attributes)
            audit!(store, staff, 'kitchen_station.update', station, attributes)
            station.to_pos
          end
        end

        # A station that has tickets stays, so their history keeps its name;
        # switch it off instead.
        def destroy_station(store:, staff:, key:, station:)
          run(store, staff, key, station.branch, 'kitchen_station.destroy', 'id' => station.prefixed_id) do
            unless station.destroy
              raise Conflict.new('This station has tickets. Switch it off instead.', reason: 'kitchen_station_in_use')
            end

            audit!(store, staff, 'kitchen_station.destroy', station, 'name' => station.name)
            { 'id' => station.prefixed_id }
          end
        end

        def create_route(store:, staff:, key:, branch:, attributes:)
          run(store, staff, key, branch, 'station_route.create', attributes) do
            ModulePolicy.require!(branch, Send::MODULE)
            route = StationRoute.new(store: store, branch: branch)
            save_route!(route, store, branch, attributes)
            audit!(store, staff, 'station_route.create', route, attributes)
            route.to_pos
          end
        end

        def update_route(store:, staff:, key:, route:, attributes:)
          run(store, staff, key, route.branch, 'station_route.update', attributes.merge('id' => route.prefixed_id)) do
            route.lock!
            save_route!(route, store, route.branch, attributes)
            audit!(store, staff, 'station_route.update', route, attributes)
            route.to_pos
          end
        end

        def destroy_route(store:, staff:, key:, route:)
          run(store, staff, key, route.branch, 'station_route.destroy', 'id' => route.prefixed_id) do
            route.destroy!
            audit!(store, staff, 'station_route.destroy', route, route.to_pos.except(:id))
            { 'id' => route.prefixed_id }
          end
        end

        def set_trigger(store:, staff:, key:, branch:, trigger:)
          value = trigger.to_s
          run(store, staff, key, branch, 'kitchen.send_trigger', 'kitchen_send_trigger' => value) do
            raise Conflict.new('The send trigger is invalid.', reason: 'kitchen_trigger_invalid') unless Send::TRIGGERS.include?(value)

            branch.lock!
            before = branch.kitchen_send_trigger
            if before != value
              branch.update!(kitchen_send_trigger: value)
              audit!(store, staff, 'kitchen.send_trigger', branch, 'before' => before, 'after' => value)
            end
            settings(branch)
          end
        end

        def settings(branch)
          { 'branch_id' => branch.prefixed_id, 'kitchen_send_trigger' => branch.kitchen_send_trigger,
            'module_enabled' => ModulePolicy.enabled?(branch, Send::MODULE) }
        end

        def run(store, staff, key, branch, command, attributes, &)
          payload = { 'command' => command, 'branch_id' => branch.prefixed_id, 'attributes' => attributes }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, branch) }, &)
        end

        # One default per branch: naming a new one clears the old.
        def save_station!(station, branch, attributes)
          station.assign_attributes(attributes.slice(*STATION_FIELDS))
          station.printer = printer!(branch, attributes['printer_id']) if attributes.key?('printer_id')
          if attributes.key?('expo_station_id')
            station.expo_station = attributes['expo_station_id'].present? ? Guard.station!(branch, attributes['expo_station_id']) : nil
          end
          if station.is_default && station.will_save_change_to_is_default?
            KitchenStation.where(branch_id: branch.id, is_default: true).where.not(id: station.id).update_all(is_default: false, updated_at: Time.current)
          end
          station.save!
        end

        def save_route!(route, store, branch, attributes)
          route.assign_attributes(attributes.slice(*ROUTE_FIELDS).transform_values(&:presence))
          route.kitchen_station = Guard.station!(branch, attributes['kitchen_station_id']) if attributes.key?('kitchen_station_id')
          route.product = product!(store, attributes['product_id']) if attributes.key?('product_id')
          taken = StationRoute.where(branch_id: branch.id, product_id: route.product_id, kitchen_category: route.kitchen_category,
                                     service_mode: route.service_mode).where.not(id: route.id).exists?
          raise Conflict.new('A route for that item and service mode exists.', reason: 'station_route_taken') if taken

          route.save!
        rescue ActiveRecord::RecordNotUnique
          raise Conflict.new('A route for that item and service mode exists.', reason: 'station_route_taken')
        end

        def printer!(branch, id)
          return if id.blank?

          Printer.locate(Printer.where(branch_id: branch.id), id) || raise(ActiveRecord::RecordNotFound)
        end

        def product!(store, id)
          return if id.blank?

          product = Spree::Product.find_by_prefix_id(id.to_s)
          raise ActiveRecord::RecordNotFound if product.nil? || product.store_id != store.id

          product
        end

        def audit!(store, staff, action, subject, metadata)
          AuditEntry.record!(store: store, actor: staff, action: action, subject: subject, metadata: metadata.to_h)
        end
      end
    end
  end
end
