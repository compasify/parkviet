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
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id || workspace.lease_holder_id != staff.id ||
              !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            validate_command!(workspace, staff, revision, lease_generation, editor_id)
            validate_discount!(workspace, value_type, value, reason)
            amount = preview_amount(workspace, value_type, value)
            approve!(workspace, staff, revision, approval_id, amount: amount)

            intent = DiscountIntent.find_or_initialize_by(workspace: workspace)
            intent.assign_attributes(actor: staff, value_type: value_type.to_s, value: value.to_s, reason: reason.to_s)
            intent.save!
            recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(
              store: workspace.store, actor: staff, action: 'workspace.discount.apply', subject: workspace,
              metadata: {
                value_type: intent.value_type, value: intent.value, reason: intent.reason,
                manual_discount: workspace.order.discounts.where(kind: 'manual').sum(:amount).to_s('F'),
                total: workspace.order.total.to_s('F'), currency: workspace.order.currency
              }
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
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id || workspace.lease_holder_id != staff.id ||
              !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            validate_command!(workspace, staff, revision, lease_generation, editor_id)
            amount = DiscountIntent.find_by(workspace: workspace) ? manual_total(workspace) : nil
            approve!(workspace, staff, revision, approval_id, amount: amount, action: CLEAR_ACTION)
            intent = DiscountIntent.find_by(workspace: workspace)
            if intent
              discount_ids = intent.allocations.pluck(:discount_id)
              Spree::Pos::DiscountAllocation.where(discount_intent_id: intent.id).delete_all
              workspace.order.discounts.where(id: discount_ids).destroy_all
              intent.destroy!
            end
            recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.discount.clear', subject: workspace)
            response(workspace)
          end
        end

        def self.response(workspace)
          workspace.to_pos
        end

        def self.validate_command!(workspace, staff, revision, lease_generation, editor_id)
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          raise Conflict.new('Lease is stale.', revision: workspace.revision) unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision
          raise Conflict, 'Order is completed or has a payment.' if workspace.order.completed? || workspace.order.payments.exists?
        end

        def self.validate_discount!(workspace, value_type, value, reason)
          valid = DiscountIntent.new(workspace: workspace, actor: workspace.lease_holder, value_type: value_type.to_s,
                                     value: value.to_s, reason: reason.to_s).valid?
          raise Conflict, 'Discount is invalid.' unless valid
        end

        def self.approve!(workspace, staff, revision, approval_id, amount:, action: ACTION)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          return if policy.allows?(workspace.branch, Capabilities::DISCOUNT)

          raise Conflict, 'Discount approval is required.' if approval_id.blank?

          approval = Approval.locate(Approval.for_store(workspace.store).where(branch_id: workspace.branch_id), approval_id)
          raise Conflict, 'Discount approval is required.' if approval.nil?

          approval.consume!(action: action, amount: amount, currency: workspace.order.currency, revision: revision, subject: workspace, requester: staff)
        end

        def self.manual_total(workspace)
          workspace.order.discounts.where(kind: 'manual').sum(:amount).abs
        end

        def self.preview_amount(workspace, value_type, value)
          order = workspace.order
          owned_ids = DiscountIntent.find_by(workspace: workspace)&.allocations&.select(:discount_id) || []
          other_discounts = order.discounts.where.not(id: owned_ids).group(:line_item_id).sum(:amount)
          bases = order.line_items.to_a.sort_by(&:id).map { |line| line.amount + (other_discounts[line.id] || 0) }
          DiscountCalculator.call(bases: bases, value: value.to_s, value_type: value_type.to_s, currency: order.currency).sum
        rescue DiscountCalculator::InvalidDiscount
          raise Conflict, 'Discount exceeds the current eligible amount or cannot be represented.'
        end

        def self.recalculate!(workspace)
          # Stale POS allocations must not cap this pass's campaign candidates.
          # The manual adjuster rebuilds these rows from their durable intents.
          workspace.order.line_items.reset
          owned_ids = DiscountAllocation.where(discount_id: workspace.order.discounts.select(:id)).select(:discount_id)
          workspace.order.discounts.where(id: owned_ids).destroy_all
          Spree::PromotionHandler::Cart.new(workspace.order).activate
          Spree.order_recalculate_totals_workflow.call(order: workspace.order)
          workspace.order.reload
        end
      end
    end
  end
end
