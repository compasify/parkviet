# frozen_string_literal: true

require Rails.root.join('db/migrate/20261108183000_create_spree_pos_business_profiles')
require_relative '../support/pos_credit_helpers'

# The backfill keeps every branch that already runs as it was: profile
# `khac`, all three retail modules on, and a store profile so the store never
# sees the first-run setup. Runs the migration's own SQL on rows this example
# created.
RSpec.describe CreateSpreePosBusinessProfiles do
  include PosCreditHelpers

  def backfill!
    described_class.backfill_sql.each { |sql| ActiveRecord::Base.connection.execute(sql) }
  end

  it 'gives existing branches khac with three modules on, and their stores a store profile' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    first = credit_branch(store)
    first.update_columns(created_at: 3.days.ago)
    disabled = credit_branch(store)
    disabled.update!(status: 'disabled')
    configured_store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    configured = credit_branch(configured_store)
    Spree::Pos::BranchModule.create!(store: configured_store, branch: configured, module_key: 'retail.units', enabled: true, reason: 'profile:x')
    Spree::Pos::StoreProfile.create!(store: configured_store, profile_key: 'nha_thuoc', onboarded_at: 1.day.ago)
    empty_store = create(:store)

    backfill!
    backfill!

    [first, disabled].each do |branch|
      expect(branch.reload.profile_key).to eq('khac')
      expect(branch.profile_version).to eq(1)
      expect(Spree::Pos::BranchModule.where(branch: branch).pluck(:module_key, :enabled, :reason)).
        to contain_exactly(['retail.units', true, 'backfill'], ['retail.measured', true, 'backfill'], ['retail.traceability', true, 'backfill'])
      expect(Spree::Pos::ModulePolicy.for_branch(branch).values).to all(be(true))
    end
    profile = Spree::Pos::StoreProfile.find_by!(store: store)
    expect(profile.attributes.slice('profile_key', 'profile_version', 'wholesale', 'interests')).
      to eq('profile_key' => 'khac', 'profile_version' => 1, 'wholesale' => false, 'interests' => [])
    expect(profile.onboarded_at).to be_within(1.second).of(first.reload.created_at)
    expect(profile.prefixed_id).to start_with('posstoreprof_')

    # A branch or store that already has its own choice is left alone.
    expect(Spree::Pos::BranchModule.where(branch: configured).pluck(:module_key, :reason)).to eq([['retail.units', 'profile:x']])
    expect(Spree::Pos::StoreProfile.find_by!(store: configured_store).profile_key).to eq('nha_thuoc')
    expect(Spree::Pos::StoreProfile.where(store: empty_store)).to be_empty
  end
end
