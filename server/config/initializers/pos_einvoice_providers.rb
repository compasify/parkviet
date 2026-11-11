# frozen_string_literal: true

# E-invoice provider adapters a store may pick (Spree::Pos::Einvoices). Only
# registered providers are offered. The sandbox issues nothing outside this
# database, so production offers it only with POS_EINVOICE_SANDBOX=on.
# `to_prepare` rebuilds the registry after every code reload in development.
Rails.application.config.to_prepare do
  Spree::Pos::Einvoices.reset!
  if !Rails.env.production? || ENV['POS_EINVOICE_SANDBOX'] == 'on'
    Spree::Pos::Einvoices.register(Spree::Pos::Einvoices::SandboxProvider::KEY, 'Spree::Pos::Einvoices::SandboxProvider')
  end
end
