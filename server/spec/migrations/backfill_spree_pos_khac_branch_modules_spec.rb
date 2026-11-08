# frozen_string_literal: true

require Rails.root.join('db/migrate/20261108210000_backfill_spree_pos_khac_branch_modules')
require_relative '../support/pos_credit_helpers'

# Branches created after the business-profiles migration and before
# Branches::Create had `khac` and no module rows. The fix gives exactly those
# the three retail modules and leaves every branch that has a row, or
# another profile, alone. Runs the migration's own SQL twice.
RSpec.describe BackfillSpreePosKhacBranchModules, pos_modules: :default do
  include PosCreditHelpers

  def backfill!
    ActiveRecord::Base.connection.execute(described_class.backfill_sql)
  end

  it 'turns the three retail modules on for khac branches without rows only' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    bare = credit_branch(store)
    disabled = credit_branch(store)
    disabled.update!(status: 'disabled')
    chosen = credit_branch(store)
    Spree::Pos::BranchModule.create!(store: store, branch: chosen, module_key: 'retail.units', enabled: false, reason: 'Tắt tay')
    pharmacy = credit_branch(store)
    pharmacy.update!(profile_key: 'nha_thuoc')

    backfill!
    backfill!

    [bare, disabled].each do |branch|
      expect(Spree::Pos::BranchModule.where(branch: branch).pluck(:module_key, :enabled, :reason)).
        to contain_exactly(['retail.units', true, 'backfill'], ['retail.measured', true, 'backfill'], ['retail.traceability', true, 'backfill'])
    end
    expect(Spree::Pos::BranchModule.where(branch: chosen).pluck(:module_key, :enabled, :reason)).to eq([['retail.units', false, 'Tắt tay']])
    expect(Spree::Pos::BranchModule.where(branch: pharmacy)).to be_empty
  end
end
