# frozen_string_literal: true

module Spree
  module Pos
    # A table a waiter's device follows, so it hears when that table's dishes
    # are ready even when someone else took the order.
    class DeviceTablePin < Record
      self.table_name = 'spree_pos_device_table_pins'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :device, class_name: 'Spree::Pos::Device'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :staff, class_name: staff_class_name, optional: true

      validate :same_branch

      private

      def same_branch
        errors.add(:resource, :invalid) if device && resource && device.branch_id != resource.branch_id
      end
    end
  end
end
