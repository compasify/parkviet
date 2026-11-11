# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

RSpec.describe 'Moving and splitting table orders' do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:area) { area!(branch) }
  let(:first_table) { table!(area, name: 'Bàn 1') }
  let(:second_table) { table!(area, name: 'Bàn 2', x: 4) }
  let(:dish) { menu_product!(store, branch, price: 40_000) }
  let(:drink) { menu_product!(store, branch, price: 15_000) }

  before { table_register!(branch, cashier) }

  describe Spree::Pos::Tables::Move do
    it 'moves the order with its lines and takes a free letter at the new table' do
      order = open_table(cashier, first_table)
      add_dish(order, dish)
      open_table(cashier, second_table)

      described_class.call(**editing_args(order), resource_id: second_table.prefixed_id)

      expect(order.workspace.reload).to have_attributes(resource_id: second_table.id, table_label: 'B')
      expect(order.workspace.order.item_total).to eq(40_000)
      expect(Spree::Pos::AuditEntry.where(action: 'table.move', subject_id: order.workspace.id).count).to eq(1)
    end

    it 'refuses the same table and unavailable tables' do
      order = open_table(cashier, first_table)
      expect { described_class.call(**editing_args(order), resource_id: first_table.prefixed_id) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('same_table') }

      second_table.update!(manual_status: 'out_of_service')
      expect { described_class.call(**editing_args(order), resource_id: second_table.prefixed_id) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('table_unavailable') }
    end
  end

  describe Spree::Pos::Tables::Split do
    it 'moves the chosen lines whole to a new order at the chosen table' do
      order = open_table(cashier, first_table)
      add_dish(order, dish)
      add_dish(order, drink, quantity: 2)
      line = Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).find_by!(variant_id: drink.id)

      result = described_class.call(**editing_args(order), sale_line_ids: [line.prefixed_id], resource_id: second_table.prefixed_id,
                                                            guest_count: 1)

      created = Spree::Pos::Workspace.find_by_prefix_id!(result['new_workspace']['id'])
      expect(created).to have_attributes(resource_id: second_table.id, shift_id: order.workspace.shift_id, guest_count: 1, table_label: 'A')
      expect(created.order.reload.item_total).to eq(30_000)
      expect(order.workspace.order.reload.item_total).to eq(40_000)
      expect(line.reload.workspace_id).to eq(created.id)
    end

    it 'leaves at least one line and takes only lines of the order' do
      order = open_table(cashier, first_table)
      add_dish(order, dish)
      line = Spree::Pos::SaleLine.find_by!(workspace_id: order.workspace.id)
      expect { described_class.call(**editing_args(order), sale_line_ids: [line.prefixed_id]) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('split_all_lines') }
      expect { described_class.call(**editing_args(order), sale_line_ids: ['posline_nope']) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('split_lines_invalid') }
    end
  end
end
