# frozen_string_literal: true

# deploy/.env.prod.example ships `change-me` for every secret. A production
# server that still carries one would sign sessions, encrypt data or guard
# /jobs with a value anyone can read, so the boot stops here and names the
# variables (never their values). Skipped during `assets:precompile`, which
# runs without runtime secrets.
if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"].blank?
  placeholders = %w[
    SECRET_KEY_BASE
    POSTGRES_PASSWORD
    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
    MISSION_CONTROL_PASSWORD
  ].select { |name| ENV[name].to_s.strip.downcase.start_with?("change-me") }

  if placeholders.any?
    raise "Replace the change-me placeholder in #{placeholders.join(', ')} " \
          "(deploy/.env.prod) with a generated secret before starting in production."
  end
end
