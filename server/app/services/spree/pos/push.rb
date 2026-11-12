# frozen_string_literal: true

module Spree
  module Pos
    # Background notifications for owner devices, through the store's push
    # relay (PushRelaySetting). The relay gets the event name and a record
    # id, nothing else: the app wakes and reads the details from the server
    # with its own session. Without relay settings this does nothing.
    # Delivery happens in PushDeliveryJob after commit and never fails a
    # command.
    module Push
      # Events a phone may be woken for, and who may hear each at the branch.
      EVENTS = {
        'approval_request.created' => Capabilities::APPROVE,
        'owner_alert.created' => Capabilities::REPORT_READ
      }.freeze

      module_function

      # @param except [Spree::AdminUser, nil] nobody is woken for their own request
      def notify(branch, event, record, except: nil)
        capability = EVENTS.fetch(event)
        return unless PushRelaySetting.where(store_id: branch.store_id).exists?

        recipients(branch, capability, except).each do |registration_id|
          ActiveRecord.after_all_transactions_commit do
            PushDeliveryJob.perform_later(registration_id, event, record.prefixed_id)
          rescue StandardError => e
            Rails.logger.error("[pos] push enqueue failed: #{e.class}: #{e.message}")
          end
        end
      end

      # Enabled registrations of active owner devices of the store whose
      # person may hear this event at the branch.
      def recipients(branch, capability, except)
        rows = PushRegistration.enabled.joins(:device).
               where(store_id: branch.store_id, spree_pos_devices: { status: 'active', mode: 'owner', store_id: branch.store_id }).
               includes(:staff).to_a
        rows.reject! { |row| row.staff_id == except.id } if except
        rows.select { |row| AccessPolicy.new(store: branch.store, staff: row.staff).allows?(branch, capability) }.map(&:id)
      end
    end
  end
end
