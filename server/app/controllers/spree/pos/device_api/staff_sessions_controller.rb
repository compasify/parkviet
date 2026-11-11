# frozen_string_literal: true

module Spree
  module Pos
    module DeviceApi
      # Names at this branch, then a PIN session. The list has no email and no PIN.
      class StaffSessionsController < BaseController
        def index
          rows = StaffMembership.for_store(@device.store).where(branch: @device.branch, status: 'active').includes(:staff)
          render json: {
            data: rows.map { |row| { id: row.prefixed_id, name: row.staff.full_name.presence || row.staff.email.split('@').first, pin_set: row.pin_digest.present? } }
          }
        end

        def create
          result = Devices::StaffSignIn.call(device: @device, membership_id: params[:membership_id], pin: params[:pin])
          render json: { data: result }, status: :created
        rescue Conflict => e
          status = %w[pin_locked pin_rate_limited].include?(e.reason) ? :too_many_requests : :unauthorized
          render json: { error: { code: e.reason, message: e.message } }, status: status
        end

        def destroy
          token = request.headers['X-Pos-Staff-Session']
          require_staff!
          return if performed?

          Devices::StaffSignOut.call(device: @device, token: token)
          head :no_content
        end
      end
    end
  end
end
