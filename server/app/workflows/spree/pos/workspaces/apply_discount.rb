# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class ApplyDiscount
        ACTION = 'workspace.apply_discount'
        CLEAR_ACTION = 'workspace.clear_discount'

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, value_type:, value:, reason:, approval_id: nil)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = {
            'command' => 'apply_discount', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => editor_digest, 'value_type' => value_type.to_s, 'value' => value.to_s,
            'reason' => reason.to_s, 'approval_id' => approval_id.to_s.presence
          }
          authorize = -> { authorize!(workspace, staff) }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            validate_command!(workspace, staff, revision, lease_generation, editor_id)
            validate_discount!(workspace, value_type, value, reason)
            previous = DiscountIntent.find_by(workspace: workspace)
            before = previous && { value_type: previous.value_type, value: previous.value, amount: applied_amount(previous).to_s('F') }
            total_before = workspace.order.total

            intent = previous || DiscountIntent.new(workspace: workspace)
            intent.assign_attributes(actor: staff, value_type: value_type.to_s, value: value.to_s, reason: reason.to_s)
            intent.save!
            recalculate!(workspace)
            # The approval is checked against the amount the adjuster actually
            # applied; a mismatch raises and rolls the whole command back.
            amount = applied_amount(intent)
            approval = approve!(workspace, staff, revision, approval_id, amount: amount)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(
              store: workspace.store, actor: staff, action: 'workspace.discount.apply', subject: workspace,
              metadata: {
                value_type: intent.value_type, value: intent.value, reason: intent.reason, amount: amount.to_s('F'),
                before: before, total_before: total_before.to_s('F'),
                manual_discount: workspace.order.discounts.where(kind: 'manual').sum(:amount).to_s('F'),
                total: workspace.order.total.to_s('F'), currency: workspace.order.currency
              }.merge(approval_metadata(approval))
            )
            response(workspace)
          end
        end

        def self.clear(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, approval_id: nil)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = {
            'command' => 'clear_discount', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => editor_digest, 'approval_id' => approval_id.to_s.presence
          }
          authorize = -> { authorize!(workspace, staff) }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            validate_command!(workspace, staff, revision, lease_generation, editor_id)
            intent =DiscountIntent.find_by(workspace: workspace)
            amount = intent && applied_amount(intent)
            approval = approve!(workspace, staff, revision, approval_id, amount: amount, action: CLEAR_ACTION)
            before = intent && { value_type: intent.value_type, value: intent.value, amount: amount.to_s('F') }
            if intent
              discount_ids = intent.allocations.pluck(:discount_id)
              Spree::Pos::DiscountAllocation.where(discount_intent_id: intent.id).delete_all
              workspace.order.discounts.where(id: discount_ids).destroy_all
              intent.destroy!
            end
            recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.discount.clear', subject: workspace,
                               metadata: { before: before, total: workspace.order.total.to_s('F') }.merge(approval_metadata(approval)))
            response(workspace)
          end
        end

        def self.authorize!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? || !policy.can_edit_workspace?(workspace)
        end

        def self.response(workspace)
          workspace.to_pos
        end

        def self.validate_command!(workspace, staff, revision, lease_generation, editor_id)
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale') unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
          workspace.ensure_snapshot_editable!
        end

        def self.validate_discount!(workspace, value_type, value, reason)
          valid = DiscountIntent.new(workspace: workspace, actor: workspace.lease_holder, value_type: value_type.to_s,
                                     value: value.to_s, reason: reason.to_s).valid?
          raise Conflict, 'Discount is invalid.' unless valid
        end

        # Returns the consumed approval, or nil when the actor holds the capability.
        def self.approve!(workspace, staff, revision, approval_id, amount:, action: ACTION, capability: Capabilities::DISCOUNT, message: 'Discount approval is required.')
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          return nil if policy.allows?(workspace.branch, capability)

          raise Conflict, message if approval_id.blank?

          approval = Approval.locate(Approval.for_store(workspace.store).where(branch_id: workspace.branch_id), approval_id)
          raise Conflict, message if approval.nil?

          approval.consume!(action: action, amount: amount, currency: workspace.order.currency, revision: revision, subject: workspace, requester: staff)
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'approval.consume', subject: approval,
                             metadata: { approval_action: action, approver_id: approval.approver.prefixed_id, amount: amount&.to_s('F') })
          approval
        end

        def self.approval_metadata(approval)
          return {} if approval.nil?

          { approval_id: approval.prefixed_id, approver_id: approval.approver.prefixed_id }
        end

        # Amount currently applied through one intent's allocation rows.
        def self.applied_amount(intent)
          intent.allocations.joins(:discount).sum('spree_discounts.amount').abs
        end

        def self.recalculate!(workspace)
          # Door tickets pay for drinks through line intents the adjuster reads.
          Fnb::DrinkCredit.sync!(workspace)
          # Stale POS allocations must not cap this pass's campaign candidates.
          # The manual adjuster rebuilds these rows from their durable intents.
          workspace.order.line_items.reset
          owned_ids = DiscountAllocation.where(discount_id: workspace.order.discounts.select(:id)).select(:discount_id)
          workspace.order.discounts.where(id: owned_ids).destroy_all
          Spree::PromotionHandler::Cart.new(workspace.order).activate
          Spree.order_recalculate_totals_workflow.call(order: workspace.order)
          workspace.order.reload
          # The service charge follows the items and discounts just summed.
          ServiceCharges::Apply.call(workspace)
          # So does the minimum spend of a VIP table.
          Fnb::MinimumSpend.call(workspace)
        end
      end
    end
  end
end
