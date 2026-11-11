# frozen_string_literal: true

module Spree
  module Pos
    # The hardware checklist of one branch, read from what the server knows,
    # never ticked by hand: printers declared for receipts, kitchen tickets
    # and cup labels whose latest job printed; every kitchen station with a
    # kitchen screen or a printer; a print station seen recently; a customer
    # display still paired; the server address and the work waiting to leave
    # for the internet (VietQR, e-invoices); and the e-invoice settings.
    #
    # Each check is `ok`, `attention` (something to fix) or `not_needed` (the
    # branch does not use it: module or feature off, nothing printed through
    # a print station). The lists behind the checks come with it.
    class HardwareStatus
      OK = 'ok'
      ATTENTION = 'attention'
      NOT_NEEDED = 'not_needed'
      # A print station polls for jobs; one not seen in this window is offline.
      ONLINE_WINDOW = 3.minutes
      # Work for the internet older than this means the way out is down.
      OUTBOUND_STALE_SECONDS = 600
      PRINTER_ROLES = { 'receipt_printer' => ['receipt', nil], 'kitchen_printer' => ['kitchen_ticket', 'fnb.kitchen'],
                        'cup_label_printer' => ['cup_label', 'fnb.cup_label'] }.freeze
      SCREEN_MODES = %w[kds expo print_station].freeze

      def self.call(branch:, now: Time.current)
        new(branch, now).call
      end

      def initialize(branch, now)
        @branch = branch
        @store = branch.store
        @now = now
      end

      def call
        modules = ModulePolicy.for_branch(branch)
        printers = printer_rows
        devices = device_rows
        stations = station_rows(devices, printers)
        displays = live_displays
        server = server_row
        einvoice = einvoice_row
        checks = PRINTER_ROLES.map do |key, (role, module_key)|
          check(key, module_key && !modules[module_key] ? NOT_NEEDED : printer_status(printers, role))
        end
        checks << check('kitchen_stations', !modules['fnb.kitchen'] ? NOT_NEEDED : stations_status(stations))
        checks << check('print_station', print_station_status(printers, devices))
        checks << check('customer_display', customer_display_status(displays))
        checks << check('server', server[:ok] ? OK : ATTENTION)
        checks << check('einvoice', einvoice[:type] == 'none' ? NOT_NEEDED : (einvoice[:configured] ? OK : ATTENTION))
        {
          branch_id: branch.prefixed_id, generated_at: now.iso8601, checks: checks,
          printers: printers, stations: stations, devices: devices,
          customer_displays: { live: displays }, server: server.except(:ok), einvoice: einvoice
        }
      end

      private

      attr_reader :branch, :store, :now

      def check(key, status)
        { key: key, status: status }
      end

      # Active printers of the branch with their latest job, one query each.
      def printer_rows
        printers = Printer.where(branch_id: branch.id).active.order(:name, :id).to_a
        latest = PrintJob.where(printer_id: printers.map(&:id)).
                 select('DISTINCT ON (printer_id) printer_id, status, kind, last_error, printed_at, updated_at').
                 order(:printer_id, created_at: :desc, id: :desc).index_by(&:printer_id)
        printers.map do |printer|
          job = latest[printer.id]
          { id: printer.prefixed_id, name: printer.name, connection: printer.connection, roles: printer.roles,
            via_print_station: printer.station?, last_job_status: job&.status, last_job_kind: job&.kind,
            last_job_at: (job&.printed_at || job&.updated_at)&.iso8601, last_error: job&.last_error }
        end
      end

      def printer_status(printers, role)
        candidates = printers.select { |row| row[:roles].include?(role) }
        candidates.any? { |row| row[:last_job_status] == 'printed' } ? OK : ATTENTION
      end

      def device_rows
        Device.where(branch_id: branch.id, mode: SCREEN_MODES).active.includes(:kitchen_station).order(:name, :id).map do |device|
          { id: device.prefixed_id, name: device.name, mode: device.mode, kitchen_station_id: device.kitchen_station&.prefixed_id,
            last_seen_at: device.last_seen_at&.iso8601, online: online?(device) }
        end
      end

      def online?(device)
        device.last_seen_at.present? && device.last_seen_at > now - ONLINE_WINDOW
      end

      # A kitchen screen shows one station, or every station when none is set.
      def station_rows(devices, printers)
        screens = devices.select { |row| row[:mode] == 'kds' }
        printer_ids = printers.to_set { |row| row[:id] }
        KitchenStation.where(branch_id: branch.id, active: true).includes(:printer).order(:position, :id).map do |station|
          kds = station.kds_enabled ? screens.count { |row| [nil, station.prefixed_id].include?(row[:kitchen_station_id]) } : 0
          printer_id = station.printer&.prefixed_id
          printer = printer_ids.include?(printer_id) ? printer_id : nil
          { id: station.prefixed_id, name: station.name, kind: station.kind, printer_id: printer, kds_devices: kds,
            ok: kds.positive? || !printer.nil? }
        end
      end

      def stations_status(stations)
        stations.any? && stations.all? { |row| row[:ok] } ? OK : ATTENTION
      end

      def print_station_status(printers, devices)
        return NOT_NEEDED unless printers.any? { |row| row[:via_print_station] }

        devices.any? { |row| row[:mode] == 'print_station' && row[:online] } ? OK : ATTENTION
      end

      def live_displays
        DisplaySession.where(branch_id: branch.id, revoked_at: nil).where('token_expires_at > ?', now).count
      end

      def customer_display_status(live)
        return NOT_NEEDED unless FeaturePolicy.enabled?(branch, 'customer_display')

        live.positive? ? OK : ATTENTION
      end

      # The address devices pair with, and whether work for the internet is
      # leaving (the same figures as the system status page).
      def server_row
        status = SystemStatus.new(store: store, now: now)
        server = status.server
        outbound = status.outbound
        vietqr = status.vietqr
        stale = outbound[:oldest_pending_age_seconds].to_i > OUTBOUND_STALE_SECONDS
        { public_base_url: server[:public_base_url], tls_mode: server[:tls_mode], outbound_pending: outbound[:pending],
          outbound_failed: outbound[:failed], outbound_oldest_pending_age_seconds: outbound[:oldest_pending_age_seconds],
          vietqr_last_received_at: vietqr[:last_received_at],
          ok: server[:public_base_url].present? && outbound[:failed].zero? && !stale }
      end

      # Configured: an active settings row whose provider still has an
      # adapter and every credential field that adapter asks for.
      def einvoice_row
        type = StoreProfile.einvoice_type_for(store)
        setting = EinvoiceSetting.for_branch(branch)
        adapter = setting && Einvoices.adapter(setting.provider)
        missing = adapter ? adapter.credential_fields.map(&:to_s) - setting.credential_values.compact_blank.keys : []
        { type: type, provider: setting&.provider, configured: adapter.present? && missing.empty?, missing_fields: missing }
      end
    end
  end
end
