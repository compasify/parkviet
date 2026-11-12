# frozen_string_literal: true

module Spree
  module Pos
    # Cash sales a counter made while the server was out of reach. The
    # counter only records what it sold and the cash it took; the server
    # decides everything when the sale is replayed (Ingest): prices, stock,
    # the order and call numbers, the business date, the e-invoice. Money
    # moves through the ordinary commands only: a draft on the cashier's
    # shift, its lines, one cash tender, its receipt, complete.
    module OfflineSales
      REPLAYING = :spree_pos_offline_replaying
      # A random (version 4) UUID, as browsers make them.
      UUID = /\A\h{8}-\h{4}-4\h{3}-[89ab]\h{3}-\h{12}\z/
      PROVISIONAL = /\AOFF-[A-Za-z0-9-]{1,32}\z/
      NAME_MAX = 120

      module_function

      # The command key a counter must send for one offline sale, so every
      # replay of the same sale lands on the same receipt.
      def key_for(offline_id)
        "offline:#{offline_id}"
      end

      # The editor that holds the lease of the order replayed for a sale:
      # the sale's own random id, so no other editor ever shares it.
      def editor_for(offline_id)
        offline_id
      end

      # While a sale made earlier is written, the kitchen and cup labels are
      # not sent again: the counter already handed the order over.
      def replaying
        previous = ActiveSupport::IsolatedExecutionState[REPLAYING]
        ActiveSupport::IsolatedExecutionState[REPLAYING] = true
        yield
      ensure
        ActiveSupport::IsolatedExecutionState[REPLAYING] = previous
      end

      def replaying?
        ActiveSupport::IsolatedExecutionState[REPLAYING] == true
      end

      # Lines as the counter recorded them: what to sell (the guest order
      # rules: menu variants, options, notes, bounded counts) plus the name and
      # unit price the counter showed, kept only to compare and display.
      def lines!(rows)
        normalized = GuestOrders::Submit.normalize!(rows)
        normalized.each_with_index.map do |row, index|
          source = rows[index].to_h.stringify_keys
          price = Record.money(source['unit_price'].to_s)
          raise Conflict.new('A line price is invalid.', reason: 'offline_sale_invalid') if price.nil?

          row.merge('unit_price' => price.to_s('F'), 'name' => source['name'].to_s.squish.first(NAME_MAX).presence)
        end
      end

      # Every line still sells at the branch: on its menu and not sold out
      # today. Returns the reason and details of the first that does not.
      def unavailable(branch, rows)
        menu = GuestMenu.variants(branch, channel: :kiosk)
        rows.each do |row|
          entry = menu[row['variant_id']]
          return ['item_unavailable', { 'variant_id' => row['variant_id'] }] if entry.nil?
          return ['item_sold_out', { 'menu_item_id' => entry[:id], 'variant_id' => row['variant_id'] }] if entry[:sold_out]
        end
        nil
      end

      # A new counter order on `shift` holding `rows`, one line per row in
      # order (never merged, so each line maps back to its row).
      def draft!(store:, staff:, shift:, editor:, key:, rows:, sale_ref:)
        workspace = Workspaces::Create.draft!(store: store, staff: staff, shift: shift, editor_digest: Workspace.editor_digest(editor),
                                              service_mode: 'counter')
        AuditEntry.record!(store: store, actor: staff, action: 'workspace.create', subject: workspace, metadata: { offline_sale: sale_ref })
        rows.each_with_index do |row, index|
          current = workspace.reload
          Workspaces::ManageLineItem.add(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                         editor_id: editor, key: "#{key}:line:#{index}", variant_id: row['variant_id'],
                                         quantity: row['quantity'], modifiers: row['modifiers'].presence, note: row['note'], merge: false)
        end
        workspace.reload
        kinds = SaleLine.where(workspace_id: workspace.id).distinct.pluck(:kind)
        raise Conflict.new('Only menu and ordinary items sell offline.', reason: 'item_unavailable') unless (kinds - %w[menu ordinary]).empty?

        workspace
      end

      # The order paid in cash (`handed` from the customer, at least the
      # total) and completed, through the ordinary tender and complete.
      def pay_and_complete!(workspace, staff, editor, key, handed)
        total = workspace.reload.order.total
        raise Conflict.new('Cash handed is less than the total.', reason: 'offline_cash_short') if handed < total

        if total.positive?
          method = PaymentMethodResolver.new(store: workspace.store).available(branch: workspace.branch).find { |row| row.kind == 'cash' }
          raise Conflict.new('Cash is not available at this branch.', reason: 'cash_unavailable') if method.nil?

          Tenders::Prepare.call(workspace: workspace, staff: staff, revision: workspace.revision, lease_generation: workspace.lease_generation,
                                editor_id: editor, key: "#{key}:prepare", payment_method_id: method.prefixed_id || "posmethod-#{method.kind}",
                                amount: total.to_s('F'))
          current = workspace.reload
          attempt = TenderAttempt.where(workspace_id: workspace.id, status: 'prepared').order(:id).last
          Tenders::Confirm.call(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                editor_id: editor, key: "#{key}:confirm", attempt_id: attempt.prefixed_id,
                                handed_amount: handed.to_s('F'), evidence_kind: 'cash_count')
        end
        current = workspace.reload
        Workspaces::Complete.call(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                  editor_id: editor, key: "#{key}:complete")
        workspace.reload
      end

      # The cashier's lease on a parked replayed order, and the order back
      # in editing (on their open shift when the old one closed).
      def resume!(workspace, staff, editor, key)
        unless workspace.reload.lease_current?(staff, editor)
          Workspaces::ClaimLease.call(workspace: workspace, staff: staff, key: "#{key}:lease", editor_id: editor)
        end
        current = workspace.reload
        return current if current.operational_status == 'editing'

        Workspaces::ChangeStatus.call(workspace: current, staff: staff, status: 'editing', revision: current.revision,
                                      lease_generation: current.lease_generation, key: "#{key}:resume", editor_id: editor)
        workspace.reload
      end

      # Who may sell at the branch: an active member who opens shifts and
      # takes payments, with the POS order permission.
      def seller!(store, staff, branch)
        policy = AccessPolicy.new(store: store, staff: staff)
        return if policy.permission?('write_pos_orders') && policy.allows?(branch, Capabilities::OPEN_SHIFT) &&
          policy.allows?(branch, Capabilities::PAYMENT)

        raise CanCan::AccessDenied
      end

      def time!(value)
        Time.iso8601(value.to_s)
      rescue ArgumentError
        raise Conflict.new('A time is invalid.', reason: 'offline_sale_invalid')
      end

      def money!(value)
        amount = Record.money(value.to_s)
        raise Conflict.new('An amount is invalid.', reason: 'offline_sale_invalid') if amount.nil?

        amount
      end
    end
  end
end
