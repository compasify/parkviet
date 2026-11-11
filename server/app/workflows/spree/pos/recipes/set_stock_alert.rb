# frozen_string_literal: true

module Spree
  module Pos
    module Recipes
      # Sets a branch's low-stock threshold of one variant, in its stock
      # unit, or removes it (`min_quantity` blank). Takes
      # pos.inventory.manage at the branch and `fnb.recipes` on there.
      # Audited as `stock_alert.change`.
      module SetStockAlert
        module_function

        def call(store:, staff:, key:, branch:, variant:, min_quantity:)
          minimum = min_quantity.to_s.strip
          payload = { 'command' => 'stock_alert.set', 'branch_id' => branch.prefixed_id, 'variant_id' => variant.prefixed_id,
                      'min_quantity' => minimum }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, MODULE)
            alert = StockAlert.lock.find_or_initialize_by(branch_id: branch.id, variant_id: variant.id)
            before = alert.persisted? ? alert.min_quantity : nil
            if minimum.empty?
              alert.destroy! if alert.persisted?
            else
              raise Conflict.new('The threshold is a whole number above zero.', reason: 'stock_alert_invalid') unless minimum.match?(/\A\d{1,9}\z/)

              alert.update!(store: store, min_quantity: minimum.to_i)
            end
            AuditEntry.record!(store: store, actor: staff, action: 'stock_alert.change', subject: branch,
                               metadata: { branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, from: before,
                                           to: minimum.empty? ? nil : minimum.to_i })
            { 'branch_id' => branch.prefixed_id, 'variant_id' => variant.prefixed_id, 'min_quantity' => minimum.empty? ? nil : minimum.to_i }
          end
        end

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::INVENTORY_MANAGE)

          raise CanCan::AccessDenied
        end
      end
    end
  end
end
