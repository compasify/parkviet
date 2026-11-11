# frozen_string_literal: true

module Spree
  module Pos
    # E-invoices of completed POS orders and the registry of provider
    # adapters. A store picks one registered provider in its settings; a
    # provider without an adapter cannot be picked. Adapters register in
    # config/initializers/pos_einvoice_providers.rb (see
    # docs/einvoice-providers.md for adding one).
    module Einvoices
      MANAGE = Capabilities::EINVOICE_MANAGE
      ISSUE_EVENT = 'einvoice.issue'
      # Turnover a household business may reach in a year before e-invoices
      # become mandatory (above it, per the rules in docs/legal/hddt-nd254-tt91.md).
      MANDATORY_REVENUE = BigDecimal('1000000000')
      WARNING_SHARES = [BigDecimal('0.8'), BigDecimal('1')].freeze

      Registration = Struct.new(:key, :class_name, keyword_init: true) do
        def adapter
          class_name.constantize
        end
      end

      class << self
        def providers
          @providers ||= {}
        end

        def register(key, class_name)
          providers[key.to_s] = Registration.new(key: key.to_s, class_name: class_name.to_s)
        end

        def reset!
          @providers = {}
        end

        def registered?(key)
          providers.key?(key.to_s)
        end

        def adapter(key)
          providers[key.to_s]&.adapter
        end

        # The adapter instance for a settings row, nil when its provider is
        # no longer registered.
        def provider_for(setting)
          adapter(setting.provider)&.new(setting)
        end

        def catalog
          providers.values.map do |registration|
            adapter = registration.adapter
            { key: registration.key, label: adapter.label, sandbox: adapter.sandbox?,
              credential_fields: adapter.credential_fields, tax_code_lookup: adapter.tax_code_lookup? }
          end
        end
      end

      module_function

      def manage!(store, staff, branch = nil)
        access = AccessPolicy.new(store: store, staff: staff)
        return if access.permission?('write_pos_topology')
        return if branch && access.allows?(branch, MANAGE)

        raise CanCan::AccessDenied
      end

      def settings!(store, staff)
        return if AccessPolicy.new(store: store, staff: staff).permission?('write_pos_topology')

        raise CanCan::AccessDenied
      end

      # Queues one issue attempt now (or at `at`). Issue is idempotent, so a
      # second queued attempt for the same invoice does nothing once issued.
      def queue!(einvoice, at: Time.current)
        einvoice.update!(next_attempt_at: at)
        OutboxEntry.create!(store: einvoice.store, event_type: ISSUE_EVENT, aggregate_type: einvoice.class.name,
                            aggregate_id: einvoice.id, status: 'pending', available_at: at,
                            payload: { 'einvoice_id' => einvoice.prefixed_id, 'order_id' => einvoice.order.prefixed_id })
      end

      # End of the branch's business day containing `at`, in the branch zone.
      def business_day_end(branch, at)
        zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
        date = BusinessDay.for(branch, at)
        zone.local(date.year, date.month, date.day) + 1.day + BusinessDay.cutoff_minutes(branch.business_day_cutoff).minutes
      end

      # Last minute of the calendar day of `at` in the branch zone: data of a
      # cash-register invoice must reach the tax authority the same day.
      def calendar_day_end(branch, at)
        zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
        at.in_time_zone(zone).end_of_day - 1.minute
      end
    end
  end
end
