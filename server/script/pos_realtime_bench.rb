# frozen_string_literal: true

# Commit-to-receive latency of POS branch events over the production cable
# adapter. Run inside the container, against development data only:
#
#   pnpm spree exec bash -c 'RAILS_ENV=production RAILS_LOG_LEVEL=warn \
#     DATABASE_URL=postgres://postgres@postgres/spree_development \
#     RAILS_FORCE_SSL=false RAILS_ASSUME_SSL=false SOLID_QUEUE_IN_PUMA=false \
#     bin/rails runner script/pos_realtime_bench.rb'
#
# It starts a Puma on BENCH_PORT, connects BENCH_CONNECTIONS device sockets
# from a forked process, publishes BENCH_RATE events a second for
# BENCH_SECONDS, each inside its own committed transaction, and prints p50/p95.
# The publisher, Puma and the clients are separate processes, so events cross
# the real Postgres path. CLOCK_MONOTONIC is shared by processes on one host.
#
# Everything it creates carries a random tag and is removed at the end, along
# with the Puma it started.

require 'json'
require 'net/http'
require 'socket'
require 'uri'
require 'websocket/driver'

abort 'Run with RAILS_ENV=production.' unless Rails.env.production?
abort "Expected the solid_cable adapter, got #{ActionCable.server.config.cable['adapter']}." unless ActionCable.server.config.cable['adapter'] == 'solid_cable'

module PosRealtimeBench
  PORT = Integer(ENV.fetch('BENCH_PORT', 3901))
  CONNECTIONS = Integer(ENV.fetch('BENCH_CONNECTIONS', 20))
  RATE = Integer(ENV.fetch('BENCH_RATE', 50))
  SECONDS = Integer(ENV.fetch('BENCH_SECONDS', 120))
  GRACE_SECONDS = 15
  READY_TIMEOUT = 180
  CHANNEL = { channel: 'Spree::Pos::BranchChannel' }.freeze

  module_function

  def now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  # The driver's socket contract: a URL and a way to write bytes.
  class Client
    attr_reader :url

    def initialize(token, branch_id, on_event)
      @url = "ws://127.0.0.1:#{PORT}/cable"
      @identifier = CHANNEL.merge(branch_id: branch_id).to_json
      @on_event = on_event
      @confirmed = false
      @tcp = TCPSocket.new('127.0.0.1', PORT)
      @tcp.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @driver = WebSocket::Driver.client(self, protocols: ['actioncable-v1-json', "pos-device.#{token}"])
      @driver.on(:message) { |event| handle(event.data) }
      @driver.start
    end

    def confirmed? = @confirmed

    # The server must select Action Cable's protocol, never the token.
    def protocol = @driver.protocol

    def write(data)
      @tcp.write(data)
    end

    def pump
      @driver.parse(@tcp.read_nonblock(65_536))
      true
    rescue IO::WaitReadable
      true
    rescue EOFError, SystemCallError
      false
    end

    def io = @tcp

    def close
      @tcp.close unless @tcp.closed?
    end

    private

    def handle(raw)
      received = PosRealtimeBench.now
      data = JSON.parse(raw)
      case data['type']
      when 'welcome' then @driver.text({ command: 'subscribe', identifier: @identifier }.to_json)
      when 'confirm_subscription' then @confirmed = true
      when 'reject_subscription' then raise 'Subscription rejected.'
      when 'disconnect' then raise "Server disconnected the client: #{data['reason']}"
      when 'ping' then nil
      else @on_event.call(data.dig('message', 'id'), received) if data['message']
      end
    end
  end

  def percentile(sorted, fraction)
    return nil if sorted.empty?

    sorted[[(sorted.size * fraction).ceil - 1, 0].max]
  end

  def wait_for_server(pid)
    deadline = now + READY_TIMEOUT
    loop do
      raise 'Puma exited during boot; see the log above.' if Process.waitpid(pid, Process::WNOHANG)

      begin
        return if Net::HTTP.get_response(URI("http://127.0.0.1:#{PORT}/up")).code == '200'
      rescue SystemCallError, EOFError, Net::ReadTimeout
        nil
      end
      raise "Puma was not ready after #{READY_TIMEOUT}s." if now > deadline

      sleep 1
    end
  end

  # Child process: connect, report readiness, then record arrivals until told
  # to stop. Returns [[id, received_at], ...] through the pipe.
  def run_clients(token, branch_id, ready, stop, results)
    arrivals = []
    clients = Array.new(CONNECTIONS) { Client.new(token, branch_id, ->(id, at) { arrivals << [id, at] }) }
    by_io = clients.to_h { |client| [client.io, client] }
    announced = false
    loop do
      readable, = IO.select(by_io.keys + [stop], nil, nil, 1)
      Array(readable).each do |io|
        next if io == stop

        client = by_io.fetch(io)
        unless client.pump
          by_io.delete(io)
          raise 'A client lost its connection during the run.'
        end
      end
      if !announced && clients.all?(&:confirmed?)
        raise "Token protocol selected: #{clients.first.protocol}" unless clients.all? { |client| client.protocol == 'actioncable-v1-json' }

        ready.puts('ready')
        ready.flush
        announced = true
      end
      break if Array(readable).include?(stop)
    end
    clients.each(&:close)
    results.binmode
    results.write(JSON.generate(arrivals))
    results.close
  end

  def create_fixture(tag)
    store = Spree::Store.default
    location = Spree::StockLocation.create!(store: store, name: "Bench #{tag}", address1: '1 Bench', city: 'HCM', zipcode: '70000',
                                            country_code: 'VN', active: false, backorderable_default: false, propagate_all_variants: false)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "Bench #{tag}", code: "bench#{tag}",
                                        timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    token = Spree::Pos::Device.new_token
    device = Spree::Pos::Device.create!(store: store, branch: branch, name: "Bench #{tag}", mode: 'kds', platform: 'web',
                                        token_digest: Spree::Pos::Device.digest(token))
    [location, branch, device, token]
  end

  def destroy_fixture(location, branch, device)
    SolidCable::Message.where(channel: [Spree::Pos::Realtime.stream_name(branch), "action_cable/#{device.prefixed_id}"]).delete_all
    device.delete
    branch.delete
    location.delete
  end

  # Paced against the clock, so a slow commit does not lower the offered rate.
  def publish_events(branch)
    sent = {}
    interval = 1.0 / RATE
    started = now
    (RATE * SECONDS).times do |index|
      target = started + (index * interval)
      delay = target - now
      sleep(delay) if delay.positive?

      id = "bench_#{index}"
      ActiveRecord::Base.transaction do
        ActiveRecord.after_all_transactions_commit { sent[id] = now }
        Spree::Pos::Realtime.publish(branch, 'workspace.updated', id: id, revision: index)
      end
    end
    [sent, now - started]
  end

  def report(sent, arrivals, elapsed)
    latencies = arrivals.filter_map { |id, at| sent[id] && (at - sent[id]) * 1000 }.sort
    expected = sent.size * CONNECTIONS
    puts format('offered: %<count>d events in %<elapsed>.1fs (%<rate>.1f/s), %<conns>d connections',
                count: sent.size, elapsed: elapsed, rate: sent.size / elapsed, conns: CONNECTIONS)
    puts format('delivered: %<got>d of %<expected>d (%<pct>.2f%%)', got: latencies.size, expected: expected, pct: 100.0 * latencies.size / expected)
    puts format('commit-to-receive ms: p50=%<p50>.1f p95=%<p95>.1f p99=%<p99>.1f max=%<max>.1f',
                p50: percentile(latencies, 0.5), p95: percentile(latencies, 0.95), p99: percentile(latencies, 0.99), max: latencies.last)
  end

  def stop_process(pid)
    Process.kill('TERM', pid)
    20.times do
      return if Process.waitpid(pid, Process::WNOHANG)

      sleep 0.5
    end
    Process.kill('KILL', pid)
    Process.waitpid(pid)
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  end

  def run
    tag = SecureRandom.hex(4)
    location, branch, device, token = create_fixture(tag)
    server = client = nil
    begin
      server = Process.spawn({ 'PORT' => PORT.to_s, 'SOLID_QUEUE_IN_PUMA' => 'false' },
                             'bundle', 'exec', 'puma', '-C', 'config/puma.rb', '-p', PORT.to_s, '-e', 'production')
      wait_for_server(server)
      puts "Puma #{server} ready on #{PORT}; connecting #{CONNECTIONS} clients."

      ready_read, ready_write = IO.pipe
      stop_read, stop_write = IO.pipe
      results_read, results_write = IO.pipe
      client = fork do
        [ready_read, stop_write, results_read].each(&:close)
        run_clients(token, branch.prefixed_id, ready_write, stop_read, results_write)
        exit!(0)
      rescue StandardError => e
        warn "Client process failed: #{e.class}: #{e.message}"
        exit!(1)
      end
      [ready_write, stop_read, results_write].each(&:close)

      raise 'Clients never subscribed.' unless ready_read.wait_readable(60) && ready_read.gets

      # Let the listener register the stream before the first event counts.
      sleep 2
      puts "Publishing #{RATE}/s for #{SECONDS}s."
      sent, elapsed = publish_events(branch)
      sleep GRACE_SECONDS
      stop_write.close
      arrivals = JSON.parse(results_read.read)
      Process.waitpid(client)
      client = nil
      report(sent, arrivals, elapsed)
    ensure
      stop_process(client) if client
      stop_process(server) if server
      destroy_fixture(location, branch, device)
      puts 'Bench data removed; Puma stopped.'
    end
  end
end

PosRealtimeBench.run
