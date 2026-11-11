# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Adds one batch of items to a table order (one "add to order" press).
      # Several waiters and the cashier add to the same table at once, so
      # this needs no lease and no matching revision: additions commute. It
      # still runs under the workspace lock, refuses an order whose snapshot
      # a payment has locked, and moves the revision. A batch always writes
      # new lines; an item joins only an unsent line of the same batch.
      module AppendItems
        COMMAND = 'append_items'
        MAX_ITEMS = 50
        UUID = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

        module_function

        # @return [Hash] 'workspace' and the 'sale_line_ids' this batch wrote or grew
        def call(workspace:, staff:, key:, items:, append_batch_id: nil, device: nil)
          batch = batch_id!(append_batch_id)
          rows = items!(items)
          payload = { 'command' => COMMAND, 'append_batch_id' => batch, 'items' => rows }
          run(workspace: workspace, staff: staff, key: key, payload: payload) do
            validate_append!(workspace)
            # A batch named by the client groups its lines on every screen.
            batch ||= SecureRandom.uuid
            scope = SaleLine.where(workspace_id: workspace.id, append_batch_id: batch, kitchen_sent_quantity: 0)
            results = rows.map do |row|
              LineBuilder.add!(workspace: workspace, staff: staff, variant_id: row['variant_id'], quantity: row['quantity'],
                               modifiers: row['modifiers'], note: row['note'], merge: true, merge_scope: scope,
                               attributes: { added_by: staff, added_device: device, append_batch_id: batch })
            end
            ApplyDiscount.recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            sale_line_ids = results.map { |result| result.sale_line.prefixed_id }.uniq
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.items.append', subject: workspace,
                               metadata: { append_batch_id: batch, device_id: device&.prefixed_id, items: results.map(&:audit) })
            { 'workspace' => workspace.to_pos, 'sale_line_ids' => sale_line_ids }
          end
        end

        # Table orders take additions and unsent-line edits without a lease
        # where the branch runs tables; every other order keeps the lease.
        def lease_free?(workspace)
          workspace.resource_id.present? && ModulePolicy.enabled?(workspace.branch, Tables::Guard::MODULE)
        end

        # The rules of every lease-free command on a table order.
        # A kitchen send changes no money, so it still goes out once a payment
        # has locked the lines (snapshot: false).
        def validate_append!(workspace, snapshot: true)
          unless workspace.resource_id
            raise Conflict.new('Only a table order takes items this way.', revision: workspace.revision, reason: 'not_table_order')
          end

          ModulePolicy.require!(workspace.branch, Tables::Guard::MODULE)
          unless Workspace::OPEN_STATUSES.include?(workspace.operational_status)
            raise Conflict.new('This order is no longer open.', revision: workspace.revision, reason: 'workspace_closed')
          end

          workspace.ensure_snapshot_editable! if snapshot
        end

        # One command under the workspace lock, allowed to whoever may edit the order.
        def run(workspace:, staff:, key:, payload:, &)
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Deliveries::Assign.authorize!(workspace, staff) }, &)
        end

        def batch_id!(value)
          return nil if value.blank?
          raise Conflict.new('The batch ID is invalid.', reason: 'append_batch_invalid') unless value.to_s.match?(UUID)

          value.to_s.downcase
        end

        def items!(items)
          unless items.is_a?(Array) && items.size.between?(1, MAX_ITEMS)
            raise Conflict.new("Add between 1 and #{MAX_ITEMS} items at once.", reason: 'append_items_invalid')
          end

          items.map do |row|
            raise Conflict.new('An item is invalid.', reason: 'append_items_invalid') unless row.is_a?(Hash)

            row = row.stringify_keys
            raise Conflict.new('An item needs a variant.', reason: 'append_items_invalid') if row['variant_id'].blank?

            ManageLineItem.check_note!(row['note'])
            entry = { 'variant_id' => row['variant_id'].to_s, 'quantity' => row['quantity'].nil? ? 1 : row['quantity'] }
            modifiers = ManageLineItem.normalize_modifiers(row['modifiers'])
            entry['modifiers'] = modifiers unless modifiers.nil?
            entry['note'] = row['note'].to_s if row['note'].present?
            entry
          end
        end
      end
    end
  end
end
