# frozen_string_literal: true

# Warn (don't crash) when a production app boots without Active Record
# encryption keys: Spree then stores webhook signing keys, gateway customer ids
# and OAuth tokens in plain text. See config/application.rb and .env.example.
# Skipped during `assets:precompile`, which runs without runtime secrets.
if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"].blank?
  missing = %i[primary_key deterministic_key key_derivation_salt].reject do |key|
    Rails.configuration.active_record.encryption[key].present?
  end

  if missing.any?
    Rails.logger.warn(
      "[Spree] Active Record encryption is not fully configured (missing: #{missing.join(', ')}). " \
      "Secrets such as webhook signing keys and OAuth tokens will be stored in plain text. " \
      "Generate keys with `bin/rails db:encryption:init` and set " \
      "#{missing.map { |key| "ACTIVE_RECORD_ENCRYPTION_#{key.upcase}" }.join(', ')}."
    )
  end
end
