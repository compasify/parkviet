require "active_support/core_ext/integer/time"
require_relative "../../lib/parkviet/pos_public_url"

Rails.application.configure do
  # POS deployments (deploy/docker-compose.prod.yml) name the address devices
  # use and where TLS ends; both are validated here, before anything binds.
  pos_deployment = Parkviet::PosPublicUrl.configuration

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  if ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_SECRET_ACCESS_KEY"].present?
    config.active_storage.service = :amazon
  elsif ENV["CLOUDFLARE_ACCESS_KEY_ID"].present? && ENV["CLOUDFLARE_SECRET_ACCESS_KEY"].present? && ENV["CLOUDFLARE_ENDPOINT"].present?
    config.active_storage.service = :cloudflare
  elsif ENV["OVH_ACCESS_KEY_ID"].present? && ENV["OVH_SECRET_ACCESS_KEY"].present?
    config.active_storage.service = :ovh
  elsif ENV["DO_SPACES_ACCESS_KEY_ID"].present? && ENV["DO_SPACES_SECRET_ACCESS_KEY"].present?
    config.active_storage.service = :digitalocean
  elsif ENV["S3_ACCESS_KEY_ID"].present? && ENV["S3_SECRET_ACCESS_KEY"].present? && ENV["S3_ENDPOINT"].present?
    config.active_storage.service = :s3_compatible
  else
    config.active_storage.service = :local
  end

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # POS_TLS_MODE, when set, decides both: `none` is plain HTTP on the shop
  # network, `internal` and `public` mean Caddy terminates TLS in front.
  # Without it, the scheme of POS_PUBLIC_BASE_URL picks `none` or `public`.
  if pos_deployment.tls_mode
    config.assume_ssl = pos_deployment.tls?
    config.force_ssl = pos_deployment.tls?
    # Caddy's internal CA is a shop-network choice that may be switched back
    # to plain HTTP; HSTS would then lock browsers out of the server.
    config.ssl_options = (config.ssl_options || {}).merge(hsts: false) if pos_deployment.tls_mode == "internal"
  else
    config.assume_ssl = ENV["RAILS_ASSUME_SSL"] != "false"
    config.force_ssl = ENV["RAILS_FORCE_SSL"] != "false"
  end

  # Host authorization, only once a POS deployment names its address: the
  # shop network accepts private IPv4 addresses and `.local` names (see
  # Parkviet::PosPublicUrl.allowed_hosts). Health checks come from Docker and
  # Caddy by container name, so /up is exempt.
  if (pos_hosts = Parkviet::PosPublicUrl.allowed_hosts)
    config.hosts.concat(pos_hosts)
    config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  end

  # Canonical public host for all generated URLs — Active Storage attachment
  # URLs in API payloads, links in emails, and any URL built outside a request
  # context. Without it, URLs fall back to the store's URL setting (which is
  # "localhost" on a fresh install). Host only, optionally with a port
  # (e.g. "store.example.com" or "203.0.113.7:8080"). On Render the
  # platform-provided external hostname is used unless SPREE_HOST is set.
  # RAILS_HOST is the former name and still works.
  public_host = ENV["SPREE_HOST"].presence || ENV["RAILS_HOST"].presence ||
                ENV["RENDER_EXTERNAL_HOSTNAME"].presence || pos_deployment.host_with_port
  if public_host
    no_ssl = !config.assume_ssl && !config.force_ssl
    routes.default_url_options = { host: public_host, protocol: no_ssl ? "http" : "https" }
  end

  # Serve compiled assets (and, via Spree.cdn_host in config/initializers/spree.rb,
  # Active Storage attachments) from a CDN. Host only, no protocol.
  config.asset_host = ENV["CDN_HOST"] if ENV["CDN_HOST"].present?

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Condensed single-line request logs (e.g. "GET /products 200 12ms")
  config.lograge.enabled = true
  config.lograge.formatter = ->(data) {
    duration = data[:duration].to_i
    "#{data[:method]} #{data[:path]} #{data[:status]} #{duration}ms"
  }

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Solid Cache: the cache lives in Postgres — nothing extra to run.
  config.cache_store = :solid_cache_store

  # SMTP configuration via environment variables.
  # Works with any SMTP provider (Resend, Postmark, Mailgun, SendGrid, SES, etc.)
  if ENV["SMTP_HOST"].present?
    config.action_mailer.delivery_method = :smtp
    smtp_settings = {
      address:              ENV["SMTP_HOST"],
      port:                 ENV.fetch("SMTP_PORT", 587).to_i,
      enable_starttls_auto: true
    }
    # Only request SMTP-AUTH when credentials are provided — the quick-start
    # compose delivers to Mailpit anonymously; real providers set SMTP_USERNAME.
    if ENV["SMTP_USERNAME"].present?
      smtp_settings[:user_name]      = ENV["SMTP_USERNAME"]
      smtp_settings[:password]       = ENV["SMTP_PASSWORD"]
      smtp_settings[:authentication] = :plain
    end
    config.action_mailer.smtp_settings = smtp_settings
  end

  config.action_mailer.default_url_options = { host: public_host || "example.com" }
  config.action_mailer.default_options = { from: ENV["SMTP_FROM_ADDRESS"] } if ENV["SMTP_FROM_ADDRESS"].present?

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]
end
