# frozen_string_literal: true

module Spree
  module Pos
    class CommandExecutor
      STACK = :spree_pos_command_stack
      CHANGED_WORKSPACES = :spree_pos_command_changed_workspaces
      # A lease renewal changes nothing another screen shows, and every open
      # editor sends one every 40 seconds.
      SILENT_COMMANDS = %w[refresh_lease].freeze

      # `replay_authorize`, when given, is used instead of `authorize` for a
      # replay of a receipt this actor already holds for this key (it gets the
      # receipt). Commands whose authorization depends on state the command
      # itself ends (an open shift) use it so a lost response can still be
      # recovered; it must still check the actor's membership.
      def self.call(store:, actor:, key:, payload:, authorize:, workspace: nil, replay_authorize: nil, &)
        new(store:, actor:, key:, payload:, workspace:, authorize:, replay_authorize:).call(&)
      end

      def self.log_secret
        @log_secret ||= Rails.application.key_generator.generate_key('spree.pos.command_log.key_digest', 32)
      end

      def initialize(store:, actor:, key:, payload:, workspace:, authorize:, replay_authorize: nil)
        @store = store
        @actor = actor
        @key = key.to_s
        @payload = payload
        @workspace = workspace
        @authorize = authorize
        @replay_authorize = replay_authorize
        @digest = CommandReceipt.digest_for('workspace_id' => workspace&.prefixed_id, 'payload' => payload)
      end

      # Every command leaves one structured log line (see #log): which
      # command, where, and how it ended, correlated by a keyed digest of the
      # idempotency key. A command run inside another command's transaction
      # is tagged with that parent; the parent logs after its own commit.
      def call(&)
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        stack = (ActiveSupport::IsolatedExecutionState[STACK] ||= [])
        @parent = stack.last
        stack.push(command_name)
        outcome = 'executed'
        result = execute(&)
        outcome = 'replayed' if @replayed
        @committed = !@replayed
        result
      rescue Conflict => e
        outcome = e.reason == FeaturePolicy::DISABLED ? 'feature_disabled' : 'conflict'
        @failure = e.reason
        raise
      rescue CanCan::AccessDenied, ActiveRecord::RecordNotFound
        outcome = 'refused'
        raise
      rescue StandardError => e
        outcome = 'error'
        @failure = e.class.name
        raise
      ensure
        if started
          stack&.pop
          announce_changes if stack&.empty?
          log(outcome, started)
        end
      end

      def execute
        raise Conflict, 'Missing idempotency key.' if key.blank?

        if @replay_authorize
          existing = find_receipt
          if existing&.digest == digest
            @replay_authorize.call(existing)
            return replayed(existing)
          end
        end

        # Authorization and the receipt lookup run once, under the workspace
        # lock, where the shift and lease state they read cannot change. A
        # second pass before the lock repeated the same queries on every command.
        ApplicationRecord.transaction do
          workspace&.lock!
          @authorize.call
          existing = find_receipt
          next replayed(existing) if existing&.digest == digest
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
          note_changed_workspace(receipt)
          result
        end
      rescue ActiveRecord::RecordNotUnique
        raced = find_receipt
        # Only a concurrent receipt for this key is a replay; any other unique
        # violation belongs to the command itself.
        raise if raced.nil?

        @authorize.call
        return replayed(raced) if raced.digest == digest

        raise Conflict, 'Idempotency key was reused with a different payload.'
      end

      private

      attr_reader :store, :actor, :key, :payload, :workspace, :digest

      def command_name
        payload.is_a?(Hash) ? payload['command'] : nil
      end

      def replayed(receipt)
        @replayed = true
        receipt.result
      end

      # Correlation only: prefixed ids of the store, branch and workspace,
      # the command name and a keyed (HMAC) digest of the idempotency key, so
      # the log cannot be matched against guessed keys. Never the key itself,
      # tokens, amounts, names or other payload values.
      def log(outcome, started)
        fields = {
          event: 'pos.command', command: command_name, parent: @parent, outcome: outcome, reason: @failure,
          store: store&.prefixed_id, branch: branch_ref, workspace: workspace&.prefixed_id, actor: actor&.prefixed_id,
          key_digest: key.present? ? OpenSSL::HMAC.hexdigest('SHA256', self.class.log_secret, key)[0, 16] : nil,
          duration_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
        }.compact
        Rails.logger.tagged('pos', 'command') { Rails.logger.info(fields.to_json) }
      rescue StandardError
        nil
      end

      # Only a branch of this store; a client-sent id of another store's
      # branch is never echoed into the log.
      def branch_ref
        return workspace.branch&.prefixed_id if workspace

        value = payload.is_a?(Hash) ? payload['branch_id'] : nil
        return unless value.is_a?(String) && value.match?(/\A[a-z]+_[A-Za-z0-9]{1,40}\z/)

        Branch.locate(Branch.for_store(store), value)&.prefixed_id
      end

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

      # The receipt names the workspace of a command given one and of a
      # creation, and no workspace for shift, return or device commands.
      def note_changed_workspace(receipt)
        return if receipt.workspace_id.nil? || SILENT_COMMANDS.include?(command_name)

        (ActiveSupport::IsolatedExecutionState[CHANGED_WORKSPACES] ||= Set.new) << receipt.workspace_id
      end

      # Nested commands share their parent's transaction, so only the
      # outermost one knows it committed. Each changed workspace is announced
      # once, however many commands touched it.
      def announce_changes
        changed = ActiveSupport::IsolatedExecutionState.delete(CHANGED_WORKSPACES)
        Realtime.announce_workspaces(changed.to_a) if @committed && changed.present?
      end
    end
  end
end
