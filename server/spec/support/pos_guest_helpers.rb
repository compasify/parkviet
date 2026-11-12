# frozen_string_literal: true

require_relative 'pos_table_helpers'

# Guests ordering from a table's QR code, built on the real workflows: a
# branch running tables, the menu, the kitchen and QR ordering, a table with
# its code, and guest sessions opened from that code.
module PosGuestHelpers
  include PosTableHelpers

  DECIDER = [Spree::Pos::Capabilities::GUEST_ORDER_DECIDE, Spree::Pos::Capabilities::TABLE_SERVE].freeze
  MANAGER = [Spree::Pos::Capabilities::RESOURCE_MANAGE].freeze

  def qr_branch(store)
    branch = table_branch(store)
    set_pos_module(branch, 'fnb.qr_order', true)
    branch
  end

  # [table code, token] for `table`, issued by a floor manager.
  def table_code!(table, staff: credit_staff(table.store, table.branch, MANAGER))
    _, token = Spree::Pos::TableCodes::Issue.call(store: table.store, staff: staff, key: SecureRandom.uuid,
                                                  resource_id: table.prefixed_id, base_url: 'http://pos.test')
    [Spree::Pos::TableCode.active.find_by!(resource_id: table.id), token]
  end

  # [session, token] of a guest phone that scanned `token`.
  def guest_session!(token)
    opened = Spree::Pos::GuestSessions::Open.call(table_code: token, client_address: '10.0.0.5', user_agent: 'spec')
    [opened.session, opened.token]
  end

  def guest_items(variant, quantity: 1, modifiers: [], note: nil)
    [{ 'variant_id' => variant.prefixed_id, 'quantity' => quantity, 'modifiers' => modifiers, 'note' => note }.compact]
  end

  def submit_guest_order(session, items, key: SecureRandom.uuid)
    Spree::Pos::GuestOrders::Submit.call(session: session, key: key, items: items)
  end

  def sold_out!(item, branch: self.branch)
    Spree::Pos::MenuAvailability.create!(branch: branch, menu_item: item,
                                         sold_out_on: Spree::Pos::BusinessDay.for(branch, Spree::Pos::Workspace.business_now))
  end

  def close_order!(workspace)
    workspace.update_columns(operational_status: 'canceled', updated_at: Time.current)
  end
end
