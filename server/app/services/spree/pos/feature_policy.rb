# frozen_string_literal: true

module Spree
  module Pos
    # Kill-switches for the risky POS capabilities. The effective value at a
    # branch is the store default AND the branch override: a feature is on
    # only when the store turned it on (`write_pos_topology`) and the branch
    # has not been switched off. A branch override can therefore only turn a
    # feature off; a branch row is stored only as `enabled: false`, and
    # "turning a branch on" drops its override. Without any row a feature is
    # off.
    #
    # Off refuses only NEW commands of the feature (409, reason
    # `feature_disabled`). It never deletes or rewrites attempts, receipts or
    # ledger rows, never skips audit, and it leaves every recovery and
    # resolution path open: replaying a command already executed with the
    # same key, receipt lookups and prints, tender cancel/resolve, approving,
    # confirming or resolving refunds already requested, liability payouts,
    # collections of existing debt, receiving or canceling returns already
    # prepared, display clear/revoke and display reads, confirming or
    # canceling cash requests already made, export downloads, shift close,
    # reconciliation and reports. See `require!` call sites for the entries.
    module FeaturePolicy
      FEATURES = FeatureFlag::FEATURES
      DISABLED = 'feature_disabled'
      # Store defaults and switching a branch back on need the store
      # permission; switching one branch off also accepts
      # `pos.topology.manage` held at that branch.
      STORE_PERMISSION = 'write_pos_topology'

      module_function

      # Store default per feature, false without a row.
      def store_defaults(store)
        rows = FeatureFlag.for_store(store).where(branch_id: nil).pluck(:feature, :enabled).to_h
        FEATURES.index_with { |feature| rows.fetch(feature, false) }
      end

      # Features switched off at the branch.
      def branch_off(branch)
        return [] if branch.nil?

        FeatureFlag.where(branch_id: branch.id, enabled: false).pluck(:feature)
      end

      # { 'credit' => false, ... } effective at the branch (store defaults without one).
      def for_branch(store, branch)
        off = branch_off(branch)
        store_defaults(store).to_h { |feature, on| [feature, on && !off.include?(feature)] }
      end

      # Store default, branch override and effective value per feature.
      def describe(store, branch)
        defaults = store_defaults(store)
        off = branch_off(branch)
        FEATURES.index_with do |feature|
          { store: defaults[feature], branch_override: off.include?(feature) ? false : nil,
            effective: defaults[feature] && !off.include?(feature) }
        end
      end

      def store_enabled?(store, feature)
        FeatureFlag.where(store_id: store.id, branch_id: nil, feature: known!(feature)).pick(:enabled) || false
      end

      def enabled?(branch, feature)
        feature = known!(feature)
        return false if FeatureFlag.exists?(branch_id: branch.id, feature: feature, enabled: false)

        FeatureFlag.where(store_id: branch.store_id, branch_id: nil, feature: feature).pick(:enabled) || false
      end

      # Quick credit refines credit: it is usable only while both are on.
      def quick_credit?(branch)
        enabled?(branch, :credit) && enabled?(branch, :quick_credit)
      end

      # Raised at the start of a new command of the feature, after the
      # executor has ruled out a replay.
      def require!(branch, feature)
        refuse!(feature) unless enabled?(branch, feature)
      end

      # For store-wide configuration (for example a SKU's tracked mode).
      def require_store!(store, feature)
        refuse!(feature) unless store_enabled?(store, feature)
      end

      def refuse!(feature)
        raise Conflict.new("#{feature.to_s.humanize} is turned off.", reason: DISABLED, details: { feature: feature.to_s })
      end

      def store_manager?(policy)
        policy.permission?(STORE_PERMISSION)
      end

      # May read the switches of the branch (all branches for store managers).
      def manage?(policy, branch)
        return true if store_manager?(policy)

        branch.present? && policy.allows?(branch, Capabilities::MANAGE)
      end

      # Sets the store default (`branch` nil, `enabled` true or false), or
      # switches one branch off (`enabled` false) or back to the store
      # default (`enabled` true or nil both drop the override). Audited only
      # when something changes. Switching the customer display off spends
      # every open pairing code where it went off.
      def set!(store:, actor:, feature:, enabled:, reason:, branch: nil)
        authorize_switch!(store, actor, branch, enabled)

        feature = known!(feature)
        note = reason.to_s.strip
        raise Conflict.new('A reason is required.', reason: 'reason_required') if note.blank?
        raise Conflict.new('Reason is too long.', reason: 'reason_invalid') if note.length > 200
        raise Conflict.new('A store default must be on or off.', reason: 'feature_value_invalid') if branch.nil? && enabled.nil?

        ApplicationRecord.transaction do
          (branch || store).lock!
          row = FeatureFlag.find_by(store_id: store.id, branch_id: branch&.id, feature: feature)
          before = row&.enabled
          after = stored_value(branch, enabled)
          next for_branch(store, branch) if before == after

          if after.nil?
            row.destroy!
          else
            row ||= FeatureFlag.new(store: store, branch: branch, feature: feature)
            row.update!(enabled: after, reason: note, changed_by: actor)
          end
          spend_pairing_codes!(store, branch) if feature == 'customer_display' && after == false
          AuditEntry.record!(store: store, actor: actor, action: 'feature_flag.change', subject: branch || store,
                             metadata: { feature: feature, scope: branch ? 'branch' : 'store', branch_id: branch&.prefixed_id,
                                         from: before, to: after, reason: note })
          for_branch(store, branch)
        end
      end

      # Switching one branch off is open to its topology manager; anything
      # that can switch a feature on is for store managers.
      def authorize_switch!(store, actor, branch, enabled)
        policy = AccessPolicy.new(store: store, staff: actor)
        allowed = branch && enabled == false ? manage?(policy, branch) : store_manager?(policy)
        raise CanCan::AccessDenied unless allowed
      end

      # A branch keeps only `false`; true or nil there means no override.
      def stored_value(branch, enabled)
        return enabled if branch.nil?

        enabled == false ? false : nil
      end

      def spend_pairing_codes!(store, branch)
        sessions = DisplaySession.where(store_id: store.id)
        sessions = sessions.where(branch_id: branch.id) if branch
        DisplayPairing.where(used_at: nil, display_session_id: sessions.select(:id)).update_all(used_at: Time.current)
      end

      def known!(feature)
        name = feature.to_s
        raise Conflict.new('Unknown feature.', reason: 'feature_unknown') unless FEATURES.include?(name)

        name
      end
    end
  end
end
