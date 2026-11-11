# frozen_string_literal: true

module Spree
  module Pos
    module Menu
      # Marks a menu item sold out at a branch for the current business day,
      # or back on sale. The mark lapses by itself when the business date
      # moves on. Screens hear `menu.sold_out` after commit and read the menu again.
      module SetSoldOut
        module_function

        def call(store:, staff:, key:, branch:, menu_item:, sold_out:, device: nil)
          sold_out = sold_out == true
          payload = { 'command' => 'menu.sold_out', 'branch_id' => branch.prefixed_id, 'menu_item_id' => menu_item.prefixed_id,
                      'sold_out' => sold_out }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.sold_out!(store, staff, branch, device: device) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            raise ActiveRecord::RecordNotFound if branch.disabled?

            business_date = BusinessDay.for(branch, Workspace.business_now)
            row = MenuAvailability.lock.find_or_initialize_by(branch_id: branch.id, menu_item_id: menu_item.id)
            before = row.sold_out_on == business_date
            row.update!(sold_out_on: sold_out ? business_date : nil, updated_by: staff)
            if before != sold_out
              AuditEntry.record!(store: store, actor: staff, action: 'menu.sold_out', subject: menu_item,
                                 metadata: { branch_id: branch.prefixed_id, sold_out: sold_out, business_date: business_date.iso8601 })
              Realtime.publish(branch, 'menu.sold_out', id: menu_item.prefixed_id, refs: { menu_item_id: menu_item.prefixed_id })
            end
            { 'menu_item_id' => menu_item.prefixed_id, 'branch_id' => branch.prefixed_id, 'sold_out' => sold_out,
              'business_date' => business_date.iso8601 }
          end
        end
      end
    end
  end
end
