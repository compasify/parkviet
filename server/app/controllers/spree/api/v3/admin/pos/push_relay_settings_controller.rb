# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The store's push relay: its HTTPS address and signing key. The key
          # is accepted on write and never returned; leaving it out of an
          # update keeps the stored one. `check` sends the relay a signed
          # `relay.check` with no device, so the dashboard can show whether
          # the server reaches it. Store administration (write_pos_topology) only.
          class PushRelaySettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[write_pos_topology], update: %w[write_pos_topology], destroy: %w[write_pos_topology],
                            check: %w[write_pos_topology]

            def show
              render json: { data: Spree::Pos::PushRelaySetting.for_store(current_store)&.to_pos }
            end

            def update
              setting = Spree::Pos::PushRelaySetting.find_or_initialize_by(store_id: current_store.id)
              setting.url = params[:url].to_s.strip if params.key?(:url)
              setting.relay_key = params[:key].to_s.strip if params[:key].present?
              setting.changed_by = current_user
              setting.save!
              audit!('push_relay.update', setting, url: setting.url)
              render json: { data: setting.to_pos }
            end

            def destroy
              setting = Spree::Pos::PushRelaySetting.for_store(current_store)
              if setting
                audit!('push_relay.destroy', setting, url: setting.url)
                setting.destroy!
              end
              render json: { data: nil }
            end

            def check
              setting = Spree::Pos::PushRelaySetting.for_store(current_store)
              raise Spree::Pos::Conflict.new('Set up the push relay first.', reason: 'push_relay_missing') if setting.nil?

              Spree::Pos::Push::RelayClient.check(setting: setting, store: current_store)
              render json: { data: setting.reload.to_pos }
            end
          end
        end
      end
    end
  end
end
