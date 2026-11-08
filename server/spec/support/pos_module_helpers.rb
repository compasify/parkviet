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
  # Set by the `with branch modules off` shared context (below).
  mattr_accessor :modules_off, default: false
  mattr_accessor :off_requests, default: { off: 0, setup: 0 }

  # The setup commands a module guards (ModulePolicy.require!): configuring a
  # SKU, a scale label format, opening tracked stock. `disable` of a label
  # format is not one of them.
  SETUP_COMMANDS = [
    [:put, %r{\A/api/v3/admin/pos/units/variant\z}],
    [:post, %r{\A/api/v3/admin/pos/branches/[^/]+/label_formats\z}],
    [:patch, %r{\A/api/v3/admin/pos/branches/[^/]+/label_formats/[^/]+\z}],
    [:post, %r{\A/api/v3/admin/pos/inventory/opening_balances\z}]
  ].freeze

  def self.setup_command?(method, path)
    path = path.to_s.split('?', 2).first
    SETUP_COMMANDS.any? { |verb, pattern| verb == method.to_s.downcase.to_sym && pattern.match?(path) }
  end

  # Every branch module row on or off at once, without the workflow.
  def self.switch_all!(enabled)
    Spree::Pos::BranchModule.where.not(enabled: enabled).update_all(enabled: enabled, updated_at: Time.current)
  end

  # While `modules_off` is set, every request runs with all branch modules
  # off, except a setup command, which runs with them on and turns them off
  # again when it returns. That is a manager who switches the modules on,
  # configures a SKU and switches them off again before anybody sells. So
  # everything a spec does after configuring (sell, tender, complete, return,
  # refund, receive, read) runs against off rows, and the setup guards stay
  # live: a guard added to a selling path would fail the off-run.
  module ModulesOffRequests
    def process(method, path, **)
      return super unless PosModuleHelpers.modules_off

      begin
        setup = PosModuleHelpers.setup_command?(method, path)
        PosModuleHelpers.off_requests[setup ? :setup : :off] += 1
        PosModuleHelpers.switch_all!(setup)
        super
      ensure
        PosModuleHelpers.switch_all!(false)
      end
    end
  end

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
      { store_id: branch.store_id, branch_id: branch.id, module_key: key, enabled: !modules_off, reason: 'spec default',
        created_at: now, updated_at: now }
    end
    Spree::Pos::BranchModule.insert_all(rows, unique_by: :idx_pos_branch_modules_key)
  end
end

Spree::Pos::Branch.after_create { PosModuleHelpers.enable_profile_modules!(self) if PosModuleHelpers.enable_on_create }
ActionDispatch::Integration::Session.prepend(PosModuleHelpers::ModulesOffRequests)

# D5: turning a module off never changes how a configured SKU sells. Branches
# get their module rows written off; setup commands still run (see
# ModulesOffRequests), and the example ends with every row off.
RSpec.shared_context 'with branch modules off' do
  around do |example|
    PosModuleHelpers.modules_off = true
    example.run
  ensure
    PosModuleHelpers.modules_off = false
  end

  after do
    on = Spree::Pos::BranchModule.where(enabled: true).pluck(:module_key)
    expect(on).to be_empty, "expected every branch module off after the example, still on: #{on.inspect}"
  end
end

# Spec files that sell configured SKUs carry `modules_off_rerun: true`. Run
# them a second time with every branch module off:
#
#   pnpm spree rspec spec/requests/spree/pos/ --tag modules_off_rerun
#
# The tag is both the filter and the switch. Examples about the setup guard
# itself (`module_setup: true`, they expect 409 `module_disabled`, which the
# off-run lets through on purpose) are left out of that run.
RSpec.configure do |config|
  config.include PosModuleHelpers
  config.around do |example|
    PosModuleHelpers.enable_on_create = example.metadata[:pos_modules] != :default
    example.run
  ensure
    PosModuleHelpers.enable_on_create = true
  end

  # `.rspec` requires rails_helper before the command line filters are in
  # place, so look at them only once spec files are loading.
  config.when_first_matching_example_defined(modules_off_rerun: true) do
    if config.inclusion_filter.rules.key?(:modules_off_rerun)
      config.include_context 'with branch modules off', modules_off_rerun: true
      config.filter_run_excluding module_setup: true
    end
  end

  config.after(:suite) do
    counts = PosModuleHelpers.off_requests
    next if counts.values.sum.zero?

    puts "\nBranch modules off: #{counts[:off]} requests ran with every module off, " \
         "#{counts[:setup]} setup commands ran with them on."
  end
end
