# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_table_helpers'

RSpec.describe Spree::Pos::Resource do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store) }
  let(:area) { area!(branch) }

  it 'takes only the known kinds and shapes' do
    expect(table!(area, name: 'Bàn 1', kind: 'billiard', shape: 'round')).to be_persisted
    expect(described_class.new(store: store, branch: branch, area: area, name: 'X', kind: 'boat')).not_to be_valid
    expect(described_class.new(store: store, branch: branch, area: area, name: 'X', shape: 'star')).not_to be_valid
    expect do
      table = table!(area, name: 'Bàn 2')
      ActiveRecord::Base.transaction(requires_new: true) { table.update_column(:kind, 'boat') }
    end.to raise_error(ActiveRecord::StatementInvalid, /chk_pos_resources_kind/)
  end

  it 'keeps active names unique per branch, and frees the name of an archived table' do
    first = table!(area, name: 'Bàn 1')
    expect(described_class.new(store: store, branch: branch, area: area, name: 'bàn 1')).not_to be_valid

    first.update!(status: 'archived')
    expect(table!(area, name: 'Bàn 1')).to be_persisted
    other_branch = table_branch(store)
    expect(table!(area!(other_branch), name: 'Bàn 1')).to be_persisted
  end

  it 'belongs to an area of its own branch' do
    other = area!(table_branch(store))
    expect(described_class.new(store: store, branch: branch, area: other, name: 'Bàn 9')).not_to be_valid
  end

  describe 'orders at a table' do
    let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
    let(:table) { table!(area, name: 'Bàn 1') }

    before { table_register!(branch, cashier) }

    it 'points only dine-in and timed orders at a table' do
      workspace = open_table(cashier, table).workspace
      expect(workspace).to have_attributes(service_mode: 'dine_in', resource_id: table.id)

      workspace.service_mode = 'takeaway'
      expect(workspace).not_to be_valid
      workspace.service_mode = 'timed'
      expect(workspace).to be_valid
      expect do
        ActiveRecord::Base.transaction(requires_new: true) { workspace.update_column(:service_mode, 'counter') }
      end.to raise_error(ActiveRecord::StatementInvalid, /chk_pos_workspaces_resource_mode/)
    end

    it 'lets a table move: the table is not part of what a workspace keeps fixed' do
      workspace = open_table(cashier, table).workspace
      other = table!(area, name: 'Bàn 2', x: 4)
      expect(workspace.update(resource: other)).to be(true)
    end

    it 'keeps guest counts between 0 and 999' do
      workspace = open_table(cashier, table).workspace
      workspace.guest_count = 1000
      expect(workspace).not_to be_valid
    end
  end
end
