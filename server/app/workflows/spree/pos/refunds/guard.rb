# frozen_string_literal: true

module Spree
  module Pos
    module Refunds
      module Guard
        module_function

        def request!(store, refund_id)
          request = RefundRequest.locate(RefundRequest.for_store(store), refund_id)
          raise ActiveRecord::RecordNotFound if request.nil?

          request
        end

        def allows?(store, staff, branch, *capabilities)
          policy = AccessPolicy.new(store: store, staff: staff)
          !branch.disabled? && policy.permission?('write_pos_orders') && capabilities.any? { |capability| policy.allows?(branch, capability) }
        end
      end
    end
  end
end
