# frozen_string_literal: true

# The staff refresh and logout endpoints authenticate with the HttpOnly
# refresh cookie alone, so a browser on another site could make them act on a
# signed-in staff member (rotate or end the session, and receive a fresh
# access token in the body, which CORS only hides from the caller's script).
# A browser always sends `Origin` on such a POST; one that is neither this
# app's own host nor a configured allowed origin is refused before the
# cookie is used. Requests without `Origin` (non-browser clients, which hold
# no victim's cookie) are left alone, as is everything else.
class StaffSessionOriginGuard
  COOKIE_PATHS = %w[/api/v3/admin/auth/refresh /api/v3/admin/auth/logout].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) unless request.post? && COOKIE_PATHS.include?(request.path.chomp('.json'))

    origin = env['HTTP_ORIGIN'].to_s
    return @app.call(env) if origin.empty? || allowed?(origin, request)

    body = { error: { code: 'access_denied', message: 'Origin is not allowed.' } }.to_json
    [403, { 'content-type' => 'application/json', 'cache-control' => 'no-store' }, [body]]
  end

  private

  def allowed?(origin, request)
    uri = URI.parse(origin)
    return false unless uri.is_a?(URI::HTTP) && uri.host.present?
    return true if uri.host.casecmp?(request.host)

    Spree::AllowedOrigin.pluck(:origin).any? do |allowed|
      candidate = URI.parse(allowed)
      candidate.host.to_s.casecmp?(uri.host) && candidate.scheme == uri.scheme &&
        (Rails.env.development? || candidate.port == uri.port)
    rescue URI::InvalidURIError
      false
    end
  rescue URI::InvalidURIError
    false
  end
end

Rails.application.config.middleware.use StaffSessionOriginGuard
