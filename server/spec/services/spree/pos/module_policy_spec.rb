# frozen_string_literal: true

require_relative '../../../support/pos_credit_helpers'

# Module switches per branch: no row means off, a planned module is never
# on, store-wide checks look at active branches only, and a refusal is the
# same 409 shape as a feature kill-switch.
RSpec.describe Spree::Pos::ModulePolicy, pos_modules: :default do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }

  def turn(target, key, enabled)
    Spree::Pos::BranchModule.create!(store: target.store, branch: target, module_key: key, enabled: enabled, reason: 'spec')
  end

  def expect_disabled(key, &block)
    expect(&block).to raise_error(Spree::Pos::Conflict) do |error|
      expect(error.reason).to eq('module_disabled')
      expect(error.details).to eq(module: key)
    end
  end

  it 'reports every available module, off without a row, on only with an enabled row' do
    expect(described_class.for_branch(branch)).to eq('retail.units' => false, 'retail.measured' => false, 'retail.traceability' => false,
                                                     'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false, 'resources' => false, 'fnb.tables' => false, 'fnb.postpay' => false, 'fnb.service_charge' => false,
                                     'fnb.reservations' => false, 'fnb.bottle_keep' => false, 'fnb.pour_tracking' => false, 'fnb.meal_accounts' => false, 'fnb.vehicle_commission' => false, 'fnb.qr_order' => false, 'fnb.kiosk' => false,
          'timed_billing' => false)
    turn(branch, 'retail.units', true)
    turn(branch, 'retail.traceability', false)
    expect(described_class.for_branch(branch)).to eq('retail.units' => true, 'retail.measured' => false, 'retail.traceability' => false,
                                                     'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false, 'resources' => false, 'fnb.tables' => false, 'fnb.postpay' => false, 'fnb.service_charge' => false,
                                     'fnb.reservations' => false, 'fnb.bottle_keep' => false, 'fnb.pour_tracking' => false, 'fnb.meal_accounts' => false, 'fnb.vehicle_commission' => false, 'fnb.qr_order' => false, 'fnb.kiosk' => false,
          'timed_billing' => false)
    expect(described_class.for_branch(nil)).to eq({})
    expect(described_class.enabled?(branch, 'retail.units')).to be(true)
    expect(described_class.enabled?(branch, :'retail.traceability')).to be(false)
    expect(described_class.enabled?(branch, 'fnb.menu')).to be(false)
    expect(described_class.enabled?(branch, 'fnb.order_number')).to be(false)
    expect(described_class.enabled?(branch, 'fnb.tables')).to be(false)
  end

  it 'reads a branch in one query' do
    turn(branch, 'retail.units', true)
    queries = []
    callback = ->(*, payload) { queries << payload[:sql] unless payload[:name] == 'SCHEMA' || payload[:cached] }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') { described_class.for_branch(branch) }
    expect(queries.size).to eq(1)
  end

  it 'counts a module store-wide only when an active branch of the store has it on' do
    other = credit_branch(store)
    turn(other, 'retail.measured', true)
    expect(described_class.store_enabled?(store, 'retail.measured')).to be(true)
    expect(described_class.store_enabled?(store, 'retail.units')).to be(false)

    other.update!(status: 'disabled')
    expect(described_class.store_enabled?(store, 'retail.measured')).to be(false)

    foreign = credit_branch(create(:store, default_currency: 'VND', supported_currencies: 'VND'))
    turn(foreign, 'retail.units', true)
    expect(described_class.store_enabled?(store, 'retail.units')).to be(false)
  end

  it 'refuses with module_disabled, and an unknown key with module_unknown' do
    expect_disabled('retail.units') { described_class.require!(branch, 'retail.units') }
    expect_disabled('retail.traceability') { described_class.require_store!(store, 'retail.traceability') }
    expect_disabled('fnb.menu') { described_class.require!(branch, 'fnb.menu') }
    expect_disabled('fnb.tables') { described_class.require!(branch, 'fnb.tables') }

    turn(branch, 'retail.units', true)
    expect { described_class.require!(branch, 'retail.units') }.not_to raise_error
    expect { described_class.require_store!(store, 'retail.units') }.not_to raise_error

    expect { described_class.enabled?(branch, 'retail.teleport') }.to raise_error(Spree::Pos::Conflict) do |error|
      expect(error.reason).to eq('module_unknown')
    end
  end

  it 'stores only available modules, once per branch, within the branch store' do
    expect(Spree::Pos::BranchModule.new(store: store, branch: branch, module_key: with_planned_module('fnb.planned_example'), enabled: true)).not_to be_valid
    turn(branch, 'retail.units', true)
    expect(Spree::Pos::BranchModule.new(store: store, branch: branch, module_key: 'retail.units', enabled: false)).not_to be_valid
    foreign = create(:store)
    expect(Spree::Pos::BranchModule.new(store: foreign, branch: branch, module_key: 'retail.measured', enabled: true)).not_to be_valid
    expect(Spree::Pos::BranchModule.new(store: store, branch: branch, module_key: 'retail.measured', enabled: true, reason: 'x' * 201)).
      not_to be_valid
    row = Spree::Pos::BranchModule.find_by!(branch: branch, module_key: 'retail.units')
    expect(row.prefixed_id).to start_with('posbranchmod_')
    expect(row.to_pos).to include(module: 'retail.units', enabled: true, branch_id: branch.prefixed_id)
  end
end
