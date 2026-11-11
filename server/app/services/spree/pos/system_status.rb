# frozen_string_literal: true

module Spree
  module Pos
    # What the installer and the store administrator need to know about this
    # server: its address and TLS mode, whether the database, jobs and realtime
    # answer, and what is stuck (failed prints, work waiting to leave for the
    # internet, the last backup). Counts, ages and timestamps only.
    class SystemStatus
      # The realtime probe gives up after this; the page then reports it unreachable.
      PROBE_TIMEOUT = 2
      REALTIME_CACHE_KEY = 'spree/pos/system_status/realtime'
      REALTIME_CACHE_TTL = 30.seconds
      FAILED_PRINT_WINDOW = 24.hours
      # The backup service writes `parkviet-<UTC timestamp>.dump` files here (deploy/scripts/backup.sh).
      BACKUP_PATTERN = 'parkviet-*.dump'

      def initialize(store:, now: Time.current, env: ENV)
        @store = store
        @now = now
        @env = env
      end

      def call
        {
          generated_at: now.iso8601, version: version, server: server, database: database, jobs: jobs,
          realtime: realtime, printing: printing, outbound: outbound, vietqr: vietqr, backup: backup
        }
      end

      private

      attr_reader :store, :now, :env

      def version
        { app: env['PARKVIET_VERSION'].presence || 'development', spree: Spree.version, rails: Rails.version }
      end

      def server
        config = Parkviet::PosPublicUrl.configuration(env)
        { public_base_url: config.base_url, tls_mode: config.tls_mode || 'unset' }
      end

      def database
        started = monotonic
        ApplicationRecord.connection.select_value('SELECT 1')
        { ok: true, latency_ms: elapsed_ms(started) }
      rescue ActiveRecord::ActiveRecordError
        { ok: false, latency_ms: nil }
      end

      # Solid Queue runs inside Puma by default; a supervisor that stopped
      # heartbeating counts as down.
      def jobs
        alive = SolidQueue::Process.where(last_heartbeat_at: (now - SolidQueue.process_alive_threshold)..).count
        ready = SolidQueue::ReadyExecution
        {
          ok: alive.positive?, in_puma: env.fetch('SOLID_QUEUE_IN_PUMA', 'true') == 'true', processes: alive,
          ready: ready.count, oldest_ready_age_seconds: age(ready.minimum(:created_at)),
          failed: SolidQueue::FailedExecution.count
        }
      rescue ActiveRecord::ActiveRecordError
        { ok: false, in_puma: nil, processes: nil, ready: nil, oldest_ready_age_seconds: nil, failed: nil }
      end

      # The probe holds a Puma thread for up to two timeouts, so every open
      # status tab shares one result per REALTIME_CACHE_TTL; measured_at says
      # when it was taken.
      def realtime
        Rails.cache.fetch(REALTIME_CACHE_KEY, expires_in: REALTIME_CACHE_TTL) { probe_realtime }
      end

      # One message through the same pub/sub adapter branch events use, timed
      # from broadcast to delivery in this process. It covers the adapter
      # (Solid Cable polls Postgres), not the last hop to a device's socket.
      def probe_realtime
        pubsub = ActionCable.server.pubsub
        channel = "pos:system_probe:#{SecureRandom.hex(8)}"
        subscribed = Thread::Queue.new
        delivered = Thread::Queue.new
        handler = ->(_message) { delivered << monotonic }
        pubsub.subscribe(channel, handler, -> { subscribed << true })
        probe_ms = nil
        if subscribed.pop(timeout: PROBE_TIMEOUT)
          started = monotonic
          pubsub.broadcast(channel, '{}')
          at = delivered.pop(timeout: PROBE_TIMEOUT)
          probe_ms = ((at - started) * 1000).round(1) if at
        end
        { ok: !probe_ms.nil?, adapter: cable_adapter, probe_ms: probe_ms, measured_at: now.iso8601 }
      rescue StandardError => e
        Rails.logger.warn("[pos] realtime probe failed: #{e.class}")
        { ok: false, adapter: cable_adapter, probe_ms: nil, measured_at: now.iso8601 }
      ensure
        pubsub&.unsubscribe(channel, handler) if handler
      end

      def cable_adapter
        ActionCable.server.config.cable&.fetch('adapter', nil).to_s
      end

      def printing
        prints = PrintJob.for_store(store)
        pending = prints.pending
        {
          pending: pending.count, oldest_pending_age_seconds: age(pending.minimum(:created_at)),
          failed_last_24h: prints.where(status: 'failed', updated_at: (now - FAILED_PRINT_WINDOW)..).count,
          failed_window_hours: FAILED_PRINT_WINDOW.in_hours.to_i
        }
      end

      # The outbox is the queue for work that leaves this server (e-invoices,
      # platform orders). It keeps filling while the internet is down and
      # drains when it is back; selling never waits on it.
      def outbound
        rows = OutboxEntry.for_store(store)
        pending = rows.where(status: %w[pending processing])
        { pending: pending.count, failed: rows.where(status: 'failed').count,
          oldest_pending_age_seconds: age(pending.minimum(:available_at)) }
      end

      # Bank notifications arrive from the internet (a tunnel on a shop
      # server). The last arrival shows whether that path still works.
      # Events link to a store only through their payment method; events
      # rejected or unmatched before one was resolved belong to no store and
      # count everywhere, as in the VietQR webhook events list.
      def vietqr
        events = SpreeVietqr::WebhookEvent
        method_ids = Spree::PaymentMethod::Vietqr.where(store_id: store.id).select(:id)
        events = events.where(payment_method_id: method_ids).or(events.where(payment_method_id: nil))
        { last_received_at: events.maximum(:created_at)&.iso8601, unmatched: events.unmatched.count }
      end

      def backup
        dir = env['POS_BACKUP_DIR'].presence
        return { configured: false, last_at: nil, count: 0 } if dir.nil? || !File.directory?(dir)

        files = Dir.glob(File.join(dir, BACKUP_PATTERN))
        last = files.map { |file| File.mtime(file) }.max
        { configured: true, last_at: last&.utc&.iso8601, count: files.size }
      end

      def age(time)
        return if time.nil?

        [(now - time).to_i, 0].max
      end

      def monotonic
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def elapsed_ms(started)
        ((monotonic - started) * 1000).round(1)
      end
    end
  end
end
