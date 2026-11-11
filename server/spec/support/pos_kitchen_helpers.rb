# frozen_string_literal: true

require_relative 'pos_menu_helpers'

# Kitchen stations, routes and kitchen screens built on the real models, at
# a branch running `fnb.menu` and `fnb.kitchen`, for kitchen workflow,
# completion and request specs.
module PosKitchenHelpers
  include PosMenuHelpers

  def kitchen_branch(store, enabled: true, trigger: 'on_complete')
    branch = menu_branch(store)
    set_pos_module(branch, 'fnb.kitchen', enabled)
    branch.update!(kitchen_send_trigger: trigger)
    branch
  end

  def kitchen_station!(branch, name:, kind: 'prep', default: false, printer: nil, position: 0, active: true)
    Spree::Pos::KitchenStation.create!(store: branch.store, branch: branch, name: name, kind: kind, is_default: default,
                                       printer: printer, position: position, active: active)
  end

  def station_route!(station, product: nil, category: nil, mode: nil)
    Spree::Pos::StationRoute.create!(store: station.store, branch: station.branch, kitchen_station: station,
                                     product: product, kitchen_category: category, service_mode: mode)
  end

  def kitchen_screen!(branch, token, mode: 'kds', station: nil)
    Spree::Pos::Device.create!(store: branch.store, branch: branch, name: 'Bếp', mode: mode, platform: 'android',
                               token_digest: Spree::Pos::Device.digest(token), kitchen_station: station)
  end

  def kitchen_printer!(branch, token = Spree::Pos::Device.new_token)
    device = Spree::Pos::Device.create!(store: branch.store, branch: branch, name: 'Trạm in', mode: 'print_station', platform: 'android',
                                        token_digest: Spree::Pos::Device.digest(token))
    Spree::Pos::Printer.create!(store: branch.store, branch: branch, name: 'Máy in bếp', connection: 'escpos_lan', address: '10.0.0.9:9100',
                                paper: '80mm', command_language: 'escpos', roles: %w[kitchen_ticket], print_station_device: device)
  end

  def kitchen_send(sale, key: SecureRandom.uuid)
    Spree::Pos::Kitchen::Send.command(**editing_args(sale), key: key)
  end

  def tickets_of(sale)
    Spree::Pos::KitchenTicket.where(workspace_id: sale.workspace.id).order(:sequence).to_a
  end
end
