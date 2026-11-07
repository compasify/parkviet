# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class ApplyLineDiscount
        ACTION = 'workspace.apply_line_discount'
        CLEAR_ACTION = 'workspace.clear_line_discount'

        class << self
          def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, value_type:, value:, reason:, approval_id: nil)
            payload = { 'command' => 'apply_line_discount', 'revision' => revision, 'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id), 'sale_line_id' => sale_line_id.to_s, 'value_type' => value_type.to_s, 'value' => value.to_s, 'reason' => reason.to_s, 'approval_id' => approval_id.to_s.presence }
            execute(workspace:, staff:, key:, payload:) do
              sale_line = validate!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id) || sale_line_by_core_id(workspace, sale_line_id)
              raise ActiveRecord::RecordNotFound if sale_line.nil?

              intent = LineDiscountIntent.find_or_initialize_by(sale_line: sale_line)
              intent.assign_attributes(workspace: workspace, actor: staff, value_type: value_type.to_s, value: value.to_s, reason: reason.to_s)
              raise Conflict, 'Line discount is invalid.' unless intent.valid?

              amount = preview_amount(workspace, sale_line, value_type, value)
              ApplyDiscount.approve!(workspace, staff, revision, approval_id, amount: amount, action: ACTION)
              intent.save!
              ApplyDiscount.recalculate!(workspace)
              workspace.update!(revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.line_discount.apply', subject: workspace, metadata: { sale_line_id: sale_line.prefixed_id, value_type: intent.value_type, value: intent.value, reason: intent.reason })
              workspace.to_pos
            end
          end

          def clear(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, approval_id: nil)
            payload = { 'command' => 'clear_line_discount', 'revision' => revision, 'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id), 'sale_line_id' => sale_line_id.to_s, 'approval_id' => approval_id.to_s.presence }
            execute(workspace:, staff:, key:, payload:) do
              validate!(workspace, staff, revision, lease_generation, editor_id)
              sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id) || sale_line_by_core_id(workspace, sale_line_id)
              raise ActiveRecord::RecordNotFound if sale_line.nil?

              intent = LineDiscountIntent.find_by(sale_line: sale_line)
              amount = intent ? ApplyDiscount.manual_total(workspace) : nil
              ApplyDiscount.approve!(workspace, staff, revision, approval_id, amount: amount, action: CLEAR_ACTION)
              if intent
                discount_ids = intent.allocations.pluck(:discount_id)
                Spree::Pos::DiscountAllocation.where(line_discount_intent_id: intent.id).delete_all
                workspace.order.discounts.where(id: discount_ids).destroy_all
                intent.destroy!
              end
              ApplyDiscount.recalculate!(workspace)
              workspace.update!(revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.line_discount.clear', subject: workspace, metadata: { sale_line_id: sale_line.prefixed_id })
              workspace.to_pos
            end
          end

          private

          def sale_line_by_core_id(workspace, prefixed)
            line = Spree::LineItem.find_by_prefix_id(prefixed.to_s)
            line && SaleLine.find_by(workspace: workspace, line_item_id: line.id)
          end

          def preview_amount(workspace, sale_line, value_type, value)
            line = sale_line.line_item
            if value_type.to_s.start_with?('item_')
              pos_ids = Spree::Pos::DiscountAllocation.where(discount_id: workspace.order.discounts.select(:id)).select(:discount_id)
              other = line.discounts.where.not(id: pos_ids).includes(:promotion_action).to_a.reject { |row| row.promotion? && row.promotion_action&.discount_scope == :line_item }.sum(&:amount)
              return LineDiscountIntent.item_override_amount(base: line.amount + other, value: value.to_s, value_type: value_type.to_s, currency: workspace.order.currency)
            end
            if value_type.to_s == 'unit_price'
              # Targets precede invoice discounts. Preview from the same base
              # as the adjuster, excluding all POS-owned discount allocations.
              pos_ids = Spree::Pos::DiscountAllocation.where(discount_id: workspace.order.discounts.select(:id)).select(:discount_id)
              other = workspace.order.discounts.where.not(id: pos_ids).where(line_item_id: line.id).sum(:amount)
              return TargetPriceDiscount.call(sale_line: sale_line, base: line.amount + other, value: value.to_s, currency: workspace.order.currency)
            end
            owned_ids = Spree::Pos::DiscountAllocation.where(line_discount_intent_id: LineDiscountIntent.where(sale_line_id: sale_line.id).select(:id)).select(:discount_id)
            other = workspace.order.discounts.where.not(id: owned_ids).where(line_item_id: line.id).sum(:amount)
            base = line.amount + other
            DiscountCalculator.call(bases: [base], value: value.to_s, value_type: value_type.to_s, currency: workspace.order.currency).sum
          rescue DiscountCalculator::InvalidDiscount
            raise Conflict, 'Line discount exceeds the eligible amount.'
          end

          def execute(workspace:, staff:, key:, payload:, &block)
            authorize = lambda do
              policy = AccessPolicy.new(store: workspace.store, staff: staff)
              raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? || workspace.shift.owner_id != staff.id || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
            end
            CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize, &block)
          end

          def validate!(workspace, staff, revision, lease_generation, editor_id)
            ApplyDiscount.validate_command!(workspace, staff, revision, lease_generation, editor_id)
            nil
          end
        end
      end
    end
  end
end
