# frozen_string_literal: true

require 'active_support/file_update_checker'

module Parkviet
  # Development file watcher for a source tree bind-mounted into Docker from
  # Windows or macOS. There every File.mtime crosses the mount (~2 ms each)
  # and inotify events never arrive, so Rails' default checker, which stats
  # every watched file before each request, adds about two seconds to every
  # request, and an evented watcher would miss edits altogether.
  #
  # This one runs the same check in a background thread and answers `updated?`
  # from a flag, so a request waits only when code really changed. An edit is
  # picked up by the next scan, a second or two after it is saved.
  #
  # Plain Ruby outside the autoloaded app: config/environments/development.rb
  # needs it before autoloading is set up, and reloading must not unload it.
  class BackgroundFileUpdateChecker
    INTERVAL = 1.0

    def initialize(files, dirs = {}, &)
      @checker = ActiveSupport::FileUpdateChecker.new(files, dirs, &)
      @lock = Mutex.new
      @changed = false
      @thread = Thread.new { poll }
      @thread.name = 'file-update-checker'
    end

    def updated?
      @changed
    end

    def execute
      @lock.synchronize do
        @changed = false
        @checker.execute
      end
    end

    def execute_if_updated # rubocop:disable Naming/PredicateMethod -- Rails file_watcher API
      return false unless updated?

      yield if block_given?
      execute
      true
    end

    private

    def poll
      loop do
        sleep INTERVAL
        next if @changed

        @lock.synchronize { @changed = @checker.updated? }
      rescue StandardError => e
        # A file deleted mid-scan raises; the next scan sees the settled tree.
        warn "[file-update-checker] #{e.class}: #{e.message}"
      end
    end
  end
end
