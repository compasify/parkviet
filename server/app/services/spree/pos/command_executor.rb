# frozen_string_literal: true

module Spree
  module Pos
    class CommandExecutor
      def self.call(store:, actor:, key:, payload:, workspace: nil, authorize:)
        new(store:, actor:, key:, payload:, workspace:, authorize:).call { yield }
      end

      def initialize(store:, actor:, key:, payload:, workspace:, authorize:)
        @store = store
        @actor = actor
        @key = key.to_s
        @payload = payload
        @workspace = workspace
        @authorize = authorize
        @digest = CommandReceipt.digest_for('workspace_id' => workspace&.prefixed_id, 'payload' => payload)
      end

      def call
        raise Conflict, 'Missing idempotency key.' if key.blank?

        @authorize.call

        existing = find_receipt
        return existing.result if existing&.digest == digest
        raise Conflict, 'Idempotency key was reused with a different payload.' if existing

        ApplicationRecord.transaction do
          workspace&.lock!
          @authorize.call
          existing = find_receipt
          next existing.result if existing&.digest == digest
          raise Conflict, 'Idempotency key was reused with a different payload.' if existing

          result = stringify(yield)
          # Credit approvals are bound to one workspace snapshot; close the ones
          # this command made unusable in the same transaction.
          Credit::Release.sweep!(workspace: workspace, actor: actor) if workspace
          # Working on a draft keeps its serial/lot reservations alive.
          Inventory::AllocateTraceability.refresh!(workspace) if workspace
          receipt = CommandReceipt.create!(
            store: store,
            workspace: workspace,
            actor: actor,
            idempotency_key: key,
            digest: digest,
            result: result
          )
          remember_workspace(receipt, result)
          result
        end
      rescue ActiveRecord::RecordNotUnique
        raced = find_receipt
        # Only a concurrent receipt for this key is a replay; any other unique
        # violation belongs to the command itself.
        raise if raced.nil?

        @authorize.call
        return raced.result if raced.digest == digest

        raise Conflict, 'Idempotency key was reused with a different payload.'
      end

      private

      attr_reader :store, :actor, :key, :payload, :workspace, :digest

      def find_receipt
        CommandReceipt.find_by(store_id: store.id, actor_id: actor.id, idempotency_key: key)
      end

      def stringify(result)
        result.is_a?(Hash) ? result.deep_stringify_keys : result
      end

      def remember_workspace(receipt, result)
        return if receipt.workspace_id.present? || !result.is_a?(Hash) || result['order_id'].blank?

        found = Workspace.find_by_prefix_id(result['id'])
        receipt.update!(workspace: found) if found
      end
    end
  end
end
