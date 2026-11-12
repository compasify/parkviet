# frozen_string_literal: true

module Spree
  module Pos
    module DeviceApi
      # The self-ordering kiosk's side (server/openapi/pos-staff.yaml). A
      # device paired as `kiosk` works here as its service account, without a
      # PIN: this is the only API it reaches (the staff API refuses a device
      # token without a person's session). It reads its state and menu,
      # places orders from the guest's basket (prices come from the server's
      # menu), follows the QR payment and finishes or hands the order to the
      # counter. Writes take an Idempotency-Key and are rate limited per
      # device. Kiosks::Policy holds what the account may do.
      class KioskController < BaseController
        WRITE_ATTEMPTS = 30
        READ_ATTEMPTS = 120
        WINDOW = 1.minute
        LIMIT_STORE = Rails.cache.is_a?(ActiveSupport::Cache::NullStore) ? ActiveSupport::Cache::MemoryStore.new : Rails.cache
        RATE_LIMITED = -> { render json: { error: { code: 'rate_limited', message: 'Too many requests. Try again in a minute.' } }, status: :too_many_requests }

        before_action { require_mode!('kiosk') }
        rate_limit to: WRITE_ATTEMPTS, within: WINDOW, only: %i[create finish pay_at_counter cancel], store: LIMIT_STORE,
                   by: -> { "kiosk:write:#{@device.id}" }, with: RATE_LIMITED
        rate_limit to: READ_ATTEMPTS, within: WINDOW, only: %i[state menu show], store: LIMIT_STORE,
                   by: -> { "kiosk:read:#{@device.id}" }, with: RATE_LIMITED

        rescue_from Conflict do |error|
          details = { reason: error.reason }.compact
          details = error.details.merge(details) if error.details.is_a?(Hash)
          render json: { error: { code: 'conflict', message: error.message, details: details } }, status: :conflict
        end
        rescue_from CanCan::AccessDenied do
          render json: { error: { code: 'access_denied', message: 'This kiosk cannot do that.' } }, status: :forbidden
        end

        def state
          render json: { data: Kiosks::State.call(@device) }
        end

        def menu
          ModulePolicy.require!(@device.branch, Kiosks::Policy::MODULE)
          render json: { data: GuestMenu.call(@device.branch, channel: :kiosk) }
        end

        def create
          key = idempotency_key
          return if key.nil?

          items = params.to_unsafe_h['items']
          render json: { data: Kiosks::Order.place(device: @device, key: key, items: items, payment: params[:payment]) }, status: :created
        end

        def show
          render json: { data: Kiosks::View.call(order!, @device) }
        end

        def finish = command(:finish)
        def pay_at_counter = command(:pay_at_counter)
        def cancel = command(:cancel)

        private

        def command(name)
          key = idempotency_key
          return if key.nil?

          render json: { data: Kiosks::Order.public_send(name, device: @device, workspace: order!, key: key) }
        end

        # An order this kiosk still holds; any other is not found.
        def order!
          account = Kiosks::Policy.account!(@device)
          workspace = Workspace.locate(Workspace.for_store(@device.store).where(branch_id: @device.branch_id), params[:id].to_s)
          raise ActiveRecord::RecordNotFound if workspace.nil? || !Kiosks::Policy.kiosk_owned?(workspace, account)

          workspace
        end

        def idempotency_key
          key = request.headers['Idempotency-Key'].to_s
          if key.blank? || key.length > 200
            render json: { error: { code: 'parameter_invalid', message: 'Idempotency-Key is required.' } }, status: :unprocessable_content
            return
          end

          key
        end
      end
    end
  end
end
