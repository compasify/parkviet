# frozen_string_literal: true

module Spree
  module Pos
    # Assignable POS capabilities. Selling stays gated per capability; payment
  # collection and liability resolution are separate capabilities.
    module Capabilities
      MANAGE = 'pos.topology.manage'
      OPEN_SHIFT = 'pos.shift.open'
      DISCOUNT = 'pos.discount.apply'
      PRICE_OVERRIDE = 'pos.price.override'
      CUSTOMER = 'pos.customer.write'
      PAYMENT = 'pos.payment.collect'
      RESOLVE = 'pos.payment.resolve'
      RECOVER = 'pos.topology.recover'
      APPROVE = 'pos.approval.grant'
      TAKEOVER = 'pos.workspace.takeover'
      # Credit stays off until a manager configures an account; configuring
      # accounts and selling on credit are separate grants.
      CREDIT_MANAGE = 'pos.credit.manage'
      CREDIT_SELL = 'pos.credit.sell'
      # Preparing and receiving returns and requesting refunds. Paying a refund
      # out still needs an approval from someone else.
      RETURN = 'pos.return.process'
      # Manual drawer movements (cash in/out, safe drop) on one's own shift.
      CASH_MOVE = 'pos.cash.move'
      # Reading every shift's reports at a branch (others see their own
      # shifts only), and exporting reports.
      REPORT_READ = 'pos.report.read'
      REPORT_EXPORT = 'pos.report.export'
      # Typed stock at a branch: opening balances, receipts, transfers,
      # counts and quarantine of serial/lot-tracked goods.
      INVENTORY_MANAGE = 'pos.inventory.manage'
      # Recall search: which sales, orders and customers got a lot or serial.
      INVENTORY_TRACE = 'pos.inventory.trace'
      # Pair, rename and revoke branch devices, and reset another person's PIN.
      DEVICE_MANAGE = 'pos.device.manage'
      # Add, change, disable and test the branch's printers.
      PRINTER_MANAGE = 'pos.printer.manage'
      # Change the store's menu: categories, items, options, combos, time-of-day menus.
      MANAGE_MENU = 'pos.menu.manage'
      # Mark a menu item sold out at the branch for the business day.
      SET_SOLD_OUT = 'pos.menu.sold_out'
      # The branch's e-invoices: list, buyer details, retry, cancel an
      # unsent one and request a replacement. Provider settings stay with
      # store administrators.
      EINVOICE_MANAGE = 'pos.einvoice.manage'
      # Working a kitchen screen as a person: start, finish, bump, recall
      # and serve kitchen items. A paired kitchen screen needs no grant.
      OPERATE_KITCHEN = 'pos.kitchen.operate'
      # A branch's kitchen setup: stations, routes and when orders are sent.
      MANAGE_KITCHEN = 'pos.kitchen.manage'
      # Serving tables: open a table and edit its orders without owning the
      # shift they are booked on. Counter orders stay with their cashier.
      TABLE_SERVE = 'pos.table.serve'
      # A branch's floor plan: areas, tables and their cleaning / out of service marks.
      RESOURCE_MANAGE = 'pos.resource.manage'
      ASSIGNABLE = [MANAGE, OPEN_SHIFT, DISCOUNT, PRICE_OVERRIDE, CUSTOMER, PAYMENT, RESOLVE, RECOVER, APPROVE, TAKEOVER,
                    CREDIT_MANAGE, CREDIT_SELL, RETURN, CASH_MOVE, REPORT_READ, REPORT_EXPORT,
                    INVENTORY_MANAGE, INVENTORY_TRACE, DEVICE_MANAGE, PRINTER_MANAGE, MANAGE_MENU, SET_SOLD_OUT,
                    EINVOICE_MANAGE, OPERATE_KITCHEN, MANAGE_KITCHEN, TABLE_SERVE, RESOURCE_MANAGE].freeze

      def self.sanitize(values)
        Array(values).map(&:to_s).uniq
      end
    end
  end
end
