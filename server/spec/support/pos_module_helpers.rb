# frozen_string_literal: true

# POS modules are off at a branch without a row (see ModulePolicy), and the
# setup commands of a module refuse while it is off. Specs written before
# modules configure units, scale labels and tracked stock on branches they
# build directly, so whenever a spec creates a branch it gets the modules of
# its industry profile on, the same rows Branches::Create writes (`khac`, the
# column default, has all three). Rows are written straight to the table:
# no audit, purged with the rest of an example's committed rows.
#
# Examples about module rows themselves opt out with `pos_modules: :default`,
# which leaves a branch built outside Branches::Create with no rows, as in
# production.
module PosModuleHelpers
  mattr_accessor :enable_on_create, default: true

  # Turns one module on or off at a branch without the workflow (no audit, no
  # dependency checks): for arranging a spec, never for asserting the switch.
  def set_pos_module(branch, key, enabled)
    row = Spree::Pos::BranchModule.find_or_initialize_by(branch_id: branch.id, module_key: key)
    row.update!(store_id: branch.store_id, enabled: enabled, reason: 'spec setup')
  end

  def self.enable_profile_modules!(branch)
    keys = Spree::Pos::BusinessProfiles.find(branch.profile_key)&.modules || Spree::Pos::Modules.available_keys
    keys &= Spree::Pos::Modules.available_keys
    return if keys.empty?

    now = Time.current
    rows = keys.map do |key|
      { store_id: branch.store_id, branch_id: branch.id, module_key: key, enabled: true, reason: 'spec default',
        created_at: now, updated_at: now }
    end
    Spree::Pos::BranchModule.insert_all(rows, unique_by: :idx_pos_branch_modules_key)
  end
end

Spree::Pos::Branch.after_create { PosModuleHelpers.enable_profile_modules!(self) if PosModuleHelpers.enable_on_create }

RSpec.configure do |config|
  config.include PosModuleHelpers
  config.around do |example|
    PosModuleHelpers.enable_on_create = example.metadata[:pos_modules] != :default
    example.run
  ensure
    PosModuleHelpers.enable_on_create = true
  end
end
