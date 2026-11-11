# frozen_string_literal: true

module Spree
  module Pos
    module Deliveries
      # Marks a draft as an order to deliver (`delivery` feature), with a
      # free-text deliverer and an optional delivery fee. The fee is an
      # order-level Spree::Fee, so core sums it into the order total and so
      # into what the customer pays or owes; the POS never adds it up. A fee
      # changes the quoted money, so it can change only while the snapshot is
      # editable; the deliverer can be renamed until the sale is completed.
      class Assign
        MAX_FEE = BigDecimal('100000000')

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, deliverer:, fee:)
          payload = {
            'command' => 'delivery.assign', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'deliverer' => deliverer.to_s, 'fee' => fee.to_s
          }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(workspace, staff) }) do
            validate_editing!(workspace, staff, revision, lease_generation, editor_id)
            FeaturePolicy.require!(workspace.branch, :delivery)
            name = deliverer!(deliverer)
            amount = fee!(fee, workspace.order.currency)

            delivery = Delivery.find_or_initialize_by(workspace_id: workspace.id)
            before = delivery.persisted? ? { deliverer: delivery.deliverer, fee: delivery.fee_amount.to_s('F') } : nil
            fee_changed = delivery.new_record? ? amount.positive? : delivery.fee_amount != amount
            workspace.ensure_snapshot_editable! if fee_changed

            delivery.assign_attributes(store: workspace.store, branch: workspace.branch, order: workspace.order,
                                       deliverer: name, fee_amount: amount)
            delivery.created_by ||= staff
            delivery.save!
            write_fee!(workspace, delivery) if fee_changed
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.delivery.set', subject: workspace,
                               metadata: { delivery_id: delivery.prefixed_id, deliverer: name, fee: amount.to_s('F'),
                                           before: before, total: workspace.order.reload.total.to_s('F') })
            workspace.to_pos
          end
        end

        # Back to a counter sale: the fee row goes and the total follows.
        # Not gated by the switch: undoing a delivery is always possible.
        def self.clear(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          payload = {
            'command' => 'delivery.clear', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id)
          }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(workspace, staff) }) do
            validate_editing!(workspace, staff, revision, lease_generation, editor_id)
            delivery = Delivery.find_by(workspace_id: workspace.id)
            if delivery
              workspace.ensure_snapshot_editable! if delivery.fee_amount.positive?
              before = { deliverer: delivery.deliverer, fee: delivery.fee_amount.to_s('F') }
              fee = delivery.fee
              delivery.destroy!
              if fee
                fee.destroy!
                recalculate!(workspace)
              end
              workspace.update!(revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.delivery.clear', subject: workspace,
                                 metadata: { before: before, total: workspace.order.reload.total.to_s('F') })
            end
            workspace.to_pos
          end
        end

        def self.authorize!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
            !policy.can_edit_workspace?(workspace) || !policy.permission?('write_pos_orders')
        end

        def self.validate_editing!(workspace, staff, revision, lease_generation, editor_id)
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
            raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale')
          end
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
        end

        def self.deliverer!(value)
          name = Delivery.normalize_deliverer(value)
          raise Conflict.new('Deliverer name is too long.', reason: 'deliverer_invalid') if name && name.length > Delivery::DELIVERER_MAX

          name
        end

        def self.fee!(value, currency)
          text = value.to_s.strip
          amount = text.empty? ? BigDecimal('0') : Record.money(text)
          unless amount && amount <= MAX_FEE && Record.countable_money?(amount, currency)
            raise Conflict.new('Delivery fee is invalid.', reason: 'delivery_fee_invalid')
          end

          amount
        end

        # One order-level fee row per delivery: created, resized or removed,
        # then the order re-summed the way every POS money change is.
        def self.write_fee!(workspace, delivery)
          fee = delivery.fee
          if delivery.fee_amount.zero?
            delivery.update!(fee: nil)
            fee&.destroy!
          elsif fee
            fee.update!(amount: delivery.fee_amount)
          else
            fee = workspace.order.fees.create!(kind: Delivery::FEE_KIND, label: Delivery::FEE_LABEL, amount: delivery.fee_amount)
            delivery.update!(fee: fee)
          end
          recalculate!(workspace)
        end

        # The recalculation every POS money command runs (promotions, manual
        # discounts, then core totals).
        def self.recalculate!(workspace)
          Workspaces::ApplyDiscount.recalculate!(workspace)
        end
      end
    end
  end
end
