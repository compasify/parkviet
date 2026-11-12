# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The push token of the calling owner device, for the person signed
          # in on it. Only an owner device has one. The token is write-only.
          # `relay` says whether the store has a push relay at all: without
          # one the app hears events only while it is open.
          class PushRegistrationsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders], update: %w[read_pos_orders], destroy: %w[read_pos_orders]

            def show
              device = owner_device!
              render json: { data: payload(Spree::Pos::PushRegistration.find_by(device_id: device.id)) }
            end

            def update
              device = owner_device!
              row = Spree::Pos::PushRegistration.find_or_initialize_by(device_id: device.id)
              row.assign_attributes(store: current_store, staff: current_user)
              row.platform = params[:platform] if params.key?(:platform)
              row.token = params[:token] if params[:token].present?
              row.enabled = ActiveModel::Type::Boolean.new.cast(params[:enabled]) if params.key?(:enabled)
              row.save!
              audit!('push_registration.update', row, platform: row.platform, enabled: row.enabled)
              render json: { data: payload(row) }
            end

            def destroy
              device = owner_device!
              row = Spree::Pos::PushRegistration.find_by(device_id: device.id)
              if row
                row.destroy!
                audit!('push_registration.destroy', device, platform: row.platform)
              end
              render json: { data: payload(nil) }
            end

            private

            def owner_device!
              device = @pos_device
              return device if device&.mode == 'owner'

              raise Spree::Pos::Conflict.new('Push is set up from an owner device.', reason: 'owner_device_required')
            end

            def payload(row)
              { registration: row&.to_pos, relay: Spree::Pos::PushRelaySetting.where(store_id: current_store.id).exists? }
            end
          end
        end
      end
    end
  end
end
