# frozen_string_literal: true

module Pos
  # Internal seam only. Callers still need an authenticated staff request;
  # there is deliberately no public route while POS authorization is qualified.
  class CreateWalkInDraft
    def self.call(store:, staff:)
      new.call(store: store, staff: staff)
    end

    def call(store:, staff:)
      staff = authorize!(store, staff)
      channel = Spree::Pos::SalesChannel.resolve!(store)

      result = nil
      ApplicationRecord.transaction do
        result = Spree.order_create_service.call(store: store, created_by: staff, params: { channel_id: channel.prefixed_id })
        raise ActiveRecord::Rollback unless result.success?

        Pos::WalkInOrder.create!(order: result.value)
      end
      result
    end

    private

    def authorize!(store, staff)
      valid_staff = staff.is_a?(Spree.admin_user_class) && staff.persisted?
      staff = Spree.admin_user_class.find_by(id: staff.id) if valid_staff
      active_staff = staff && !(staff.respond_to?(:deactivated?) && staff.deactivated?)
      permitted = active_staff && store.is_a?(Spree::Store) && store.persisted? &&
                  Spree.ability_class.new(staff, store: store).permission_keys.include?('write_pos_orders')
      raise CanCan::AccessDenied unless permitted

      staff
    end
  end
end
