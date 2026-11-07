# frozen_string_literal: true

# Risky POS features are off until a manager turns them on. Specs written
# before the kill-switches exercise every feature, so whenever a spec creates
# a branch, every feature's store default of that branch's store is switched
# on (rows written straight to the table: no audit, purged with the rest of
# an example's committed rows). Examples about the switches themselves opt
# out with `pos_features: :default`, which leaves the product default
# (everything off).
module PosFeatureHelpers
  mattr_accessor :enable_on_create, default: true

  # Store default (no branch) or switching one branch off / back on.
  def set_pos_feature(store, feature, enabled, actor:, branch: nil, reason: 'Kiểm thử')
    Spree::Pos::FeaturePolicy.set!(store: store, actor: actor, branch: branch, feature: feature, enabled: enabled, reason: reason)
  end

  def self.enable_store_defaults!(store_id)
    now = Time.current
    actor_id = Spree.admin_user_class.order(:id).pick(:id) || 0
    rows = Spree::Pos::FeatureFlag::FEATURES.map do |feature|
      { store_id: store_id, branch_id: nil, feature: feature, enabled: true, changed_by_id: actor_id,
        reason: 'spec default', created_at: now, updated_at: now }
    end
    Spree::Pos::FeatureFlag.insert_all(rows, unique_by: :idx_pos_feature_flags_store_default)
  end
end

Spree::Pos::Branch.after_create { PosFeatureHelpers.enable_store_defaults!(store_id) if PosFeatureHelpers.enable_on_create }

RSpec.configure do |config|
  config.include PosFeatureHelpers
  config.around do |example|
    PosFeatureHelpers.enable_on_create = example.metadata[:pos_features] != :default
    example.run
  ensure
    PosFeatureHelpers.enable_on_create = true
  end
end
