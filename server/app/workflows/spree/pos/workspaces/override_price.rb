# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Price override is a separate capability and revision-bound approval.
      class OverridePrice
        ACTION = 'workspace.override_price'

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, sale_line_id:, price:, reason:, approval_id: nil)
          payload = { 'command' => 'override_price', 'revision' => revision, 'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id), 'sale_line_id' => sale_line_id.to_s, 'price' => price.to_s, 'reason' => reason.to_s, 'approval_id' => approval_id.to_s.presence }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? || workspace.shift.owner_id != staff.id || !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            ApplyDiscount.validate_command!(workspace, staff, revision, lease_generation, editor_id)
            sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id)
            sale_line ||= begin
              line = Spree::LineItem.find_by_prefix_id(sale_line_id.to_s)
              line && SaleLine.find_by(workspace: workspace, line_item_id: line.id)
            end
            raise ActiveRecord::RecordNotFound if sale_line.nil?
            raise Conflict, 'Price override reason is required.' if reason.to_s.strip.blank? || reason.to_s.length > 200

            unit_price = Record.money(price.to_s)
            raise Conflict, 'Price override is invalid.' if unit_price.nil? || unit_price < 0
            raise Conflict, 'Price override is invalid.' if workspace.order.currency == 'VND' && !unit_price.frac.zero?

            approval = ApplyDiscount.approve!(workspace, staff, revision, approval_id, amount: unit_price * sale_line.sale_quantity, action: ACTION,
                                                                                    capability: Capabilities::PRICE_OVERRIDE, message: 'Price override approval is required.')

            intent = LineDiscountIntent.find_by(sale_line: sale_line, value_type: 'unit_price')
            if intent
              discount_ids = intent.allocations.pluck(:discount_id)
              Spree::Pos::DiscountAllocation.where(line_discount_intent_id: intent.id).delete_all
              workspace.order.discounts.where(id: discount_ids).destroy_all
              intent.destroy!
            end

            variant_unit = ManageLineItem.send(:variant_unit_for_sale_line, workspace, sale_line)
            line_price = UnitNormalizer.unit_price_per_base(price: unit_price, variant_unit: variant_unit)
            before = sale_line.line_item.price
            sale_line.line_item.update!(price: line_price, price_source: Spree::LineItem::MANUAL_PRICE_SOURCE)
            sale_line.assign_attributes(unit_price: unit_price, line_price: line_price)
            sale_line.update!(merge_key: sale_line.merge_key_now)
            ApplyDiscount.recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.price.override', subject: workspace, metadata: { sale_line_id: sale_line.prefixed_id, before: before.to_s('F'), after: line_price.to_s('F'), reason: reason.to_s }.merge(ApplyDiscount.approval_metadata(approval)))
            workspace.to_pos
          end
        end
      end
    end
  end
end
