# frozen_string_literal: true

require_relative 'pos_kitchen_helpers'
require_relative 'pos_recipe_helpers'

# A counter-service branch built on the real models: menu, kitchen, call
# numbers and cup labels, for call number, cup label and call board specs.
module PosCounterServiceHelpers
  include PosKitchenHelpers
  include PosRecipeHelpers

  def counter_branch(store, trigger: 'on_complete', kitchen: true, cup_labels: true)
    branch = kitchen_branch(store, enabled: kitchen, trigger: trigger)
    set_pos_module(branch, 'fnb.order_number', true)
    set_pos_module(branch, 'fnb.cup_label', cup_labels)
    branch
  end

  # A label printer on a live print station, set as the branch's cup label printer.
  def cup_printer!(branch)
    device = Spree::Pos::Device.create!(store: branch.store, branch: branch, name: 'Trạm tem', mode: 'print_station', platform: 'android',
                                        token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
    printer = Spree::Pos::Printer.create!(store: branch.store, branch: branch, name: 'Máy in tem', connection: 'escpos_lan',
                                          address: '10.0.0.8:9100', paper: '58mm', command_language: 'tspl', roles: %w[cup_label],
                                          print_station_device: device)
    branch.update!(cup_label_printer: printer)
    printer
  end

  def cup_item!(store, branch, **)
    menu_item!(store, branch, **).tap { |item| item.update!(cup_label: true) }
  end

  def cup_jobs(sale)
    Spree::Pos::PrintJob.where(kind: 'cup_label', source_type: 'Spree::Pos::Workspace', source_id: sale.workspace.id).order(:id)
  end

  # "n/N" of every queued label, in print order.
  def cup_counts(sale)
    cup_jobs(sale).map { |job| job.document['header'].first['lines'].first.split(' · ').last }
  end
end
