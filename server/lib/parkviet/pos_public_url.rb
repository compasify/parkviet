# frozen_string_literal: true

require 'ipaddr'
require 'uri'

module Parkviet
  # Where paired devices reach this server (POS_PUBLIC_BASE_URL) and where TLS
  # ends in front of it (POS_TLS_MODE). The address goes into every pairing
  # QR, so a value a device would refuse fails the boot instead.
  #
  # Plain Ruby outside the autoloaded app: config/environments/production.rb
  # reads it before autoloading is set up.
  module PosPublicUrl
    class Invalid < StandardError; end

    # none: plain HTTP on the shop network. internal: Caddy `tls internal`, the
    # shop installs Caddy's CA on its devices. public: a certificate from a
    # public CA (Let's Encrypt on a VPS).
    TLS_MODES = %w[none internal public].freeze
    # Devices accept plain HTTP only for these hosts, so the server only
    # advertises plain HTTP for them too.
    PRIVATE_NETWORKS = %w[10.0.0.0/8 172.16.0.0/12 192.168.0.0/16].map { |range| IPAddr.new(range) }.freeze
    LOCAL_LABELS = /(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+local/i
    LOCAL_NAME = /\A#{LOCAL_LABELS}\z/

    Configuration = Struct.new(:base_url, :tls_mode, keyword_init: true) do
      def host
        base_url && URI.parse(base_url).host
      end

      # Host and port as Rails' default_url_options and SPREE_HOST take them.
      def host_with_port
        return if base_url.nil?

        uri = URI.parse(base_url)
        uri.port == uri.default_port ? uri.host : "#{uri.host}:#{uri.port}"
      end

      def tls?
        %w[internal public].include?(tls_mode)
      end
    end

    module_function

    # @return [Configuration] both values checked against each other. An
    # address without POS_TLS_MODE takes its mode from the scheme (http: none,
    # https: public), so the SSL settings and host allow-list always follow
    # the address rather than staying wide open.
    # @raise [Invalid] for an address or mode the deployment cannot work with
    def configuration(env = ENV)
      base_url = normalize(env['POS_PUBLIC_BASE_URL'])
      mode = tls_mode(env)
      if base_url
        https = base_url.start_with?('https://')
        mode ||= https ? 'public' : 'none'
        raise Invalid, 'POS_PUBLIC_BASE_URL is https:// but POS_TLS_MODE is none. Use internal or public.' if mode == 'none' && https
        raise Invalid, "POS_PUBLIC_BASE_URL is http:// but POS_TLS_MODE is #{mode}. Use an https:// address." if mode != 'none' && !https
      end
      Configuration.new(base_url: base_url, tls_mode: mode)
    end

    # The address for a pairing QR, or nil when the deployment sets none.
    def base_url(env = ENV)
      normalize(env['POS_PUBLIC_BASE_URL'])
    end

    # @return [String, nil] nil when unset: Rails then keeps RAILS_ASSUME_SSL / RAILS_FORCE_SSL
    def tls_mode(env = ENV)
      value = env['POS_TLS_MODE'].to_s.strip.downcase
      return if value.empty?
      raise Invalid, "POS_TLS_MODE must be one of #{TLS_MODES.join(', ')}." unless TLS_MODES.include?(value)

      value
    end

    # "scheme://host[:port]", or nil for a blank value. Same rules as the
    # staff app's pairing check: http or https, a host, no credentials, path,
    # query or fragment, and plain http only for a private IPv4 address or a
    # `.local` name.
    def normalize(value)
      text = value.to_s.strip
      return if text.empty?

      uri = begin
        URI.parse(text)
      rescue URI::InvalidURIError
        raise Invalid, 'POS_PUBLIC_BASE_URL is not a valid URL.'
      end
      raise Invalid, 'POS_PUBLIC_BASE_URL must be an http:// or https:// address with a host.' unless uri.is_a?(URI::HTTP) && uri.host.to_s != ''
      raise Invalid, 'POS_PUBLIC_BASE_URL must not contain a user name or password.' if uri.userinfo
      raise Invalid, 'POS_PUBLIC_BASE_URL must not contain a query or fragment.' if uri.query || uri.fragment
      raise Invalid, 'POS_PUBLIC_BASE_URL must be the server origin, without a path.' unless ['', '/'].include?(uri.path)

      host = uri.host.downcase
      if uri.scheme == 'http' && !private_host?(host)
        raise Invalid, 'POS_PUBLIC_BASE_URL may use http:// only for a private IP (10/8, 172.16/12, 192.168/16) ' \
                       'or a .local name. Use https:// for a public host.'
      end

      port = uri.port == uri.default_port ? '' : ":#{uri.port}"
      "#{uri.scheme}://#{host}#{port}"
    end

    def private_host?(host)
      name = host.to_s.downcase
      return true if name.match?(LOCAL_NAME)

      address = IPAddr.new(name)
      address.ipv4? && PRIVATE_NETWORKS.any? { |network| network.include?(address) }
    rescue IPAddr::Error
      false
    end

    # Host names Rails accepts once the deployment sets POS_PUBLIC_BASE_URL;
    # nil leaves host authorization off, as before. On the shop network the
    # server answers to any private IPv4 address and `.local` name, so a
    # changed DHCP lease or a second name still reaches it; behind a public
    # certificate it answers only to its own names. POS_EXTRA_HOSTS (comma
    # separated) adds names such as the webhook tunnel's hostname.
    def allowed_hosts(env = ENV)
      config = configuration(env)
      return if config.base_url.nil?

      extra = env['POS_EXTRA_HOSTS'].to_s.split(',')
      hosts = [config.host, env['SPREE_HOST'].to_s.split(':').first, *extra].
              map { |host| host.to_s.strip.downcase }.reject(&:empty?).uniq
      return hosts if config.tls_mode == 'public'

      # Rails anchors a pattern itself and allows a port after it.
      hosts + PRIVATE_NETWORKS + [LOCAL_LABELS]
    end
  end
end
