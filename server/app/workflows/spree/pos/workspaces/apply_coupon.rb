# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class ApplyCoupon
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, coupon_code:)
          code = coupon_code.to_s.strip.downcase
          editor_digest = Workspace.editor_digest(editor_id)
          payload = {
            'command' => 'apply_coupon', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => editor_digest, 'coupon_code' => code
          }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id || workspace.lease_holder_id != staff.id ||
              !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            ApplyDiscount.validate_command!(workspace, staff, revision, lease_generation, editor_id)
            raise Conflict, 'Coupon code is required.' if code.blank?

            order = workspace.order
            raise Conflict, 'Order has no items.' if order.line_items.empty?

            owned_ids = DiscountAllocation.where(discount_id: order.discounts.select(:id)).select(:discount_id)
            order.discounts.where(id: owned_ids).destroy_all

            previous_codes = order.promotions.select { |p| p.coupon_code? || p.code.present? }.map(&:code).compact_blank
            previous_codes.each do |prev|
              next if prev.casecmp?(code)

              Spree.coupon_handler.new(order, enable_gift_cards: false).remove(prev)
            end

            order.coupon_code = code
            handler = Spree.coupon_handler.new(order, enable_gift_cards: false).apply
            unless handler.successful?
              ApplyDiscount.recalculate!(workspace)
              raise Conflict, (handler.error.presence || 'Coupon code is invalid or not eligible.')
            end

            order.update_column(:coupon_code, code)
            ApplyDiscount.recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(
              store: workspace.store, actor: staff, action: 'workspace.coupon.apply', subject: workspace,
              metadata: {
                coupon_code: code,
                discount_total: workspace.order.discounts.sum(:amount).to_s('F'),
                total: workspace.order.total.to_s('F'),
                currency: workspace.order.currency
              }
            )
            workspace.to_pos
          end
        end

        def self.clear(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = {
            'command' => 'clear_coupon', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => editor_digest
          }
          authorize = lambda do
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
              workspace.shift.owner_id != staff.id || workspace.lease_holder_id != staff.id ||
              !policy.allows?(workspace.branch, Capabilities::OPEN_SHIFT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            ApplyDiscount.validate_command!(workspace, staff, revision, lease_generation, editor_id)
            order = workspace.order
            codes = [order.coupon_code, *order.promotions.select { |p| p.coupon_code? || p.code.present? }.map(&:code)].compact_blank.uniq
            codes.each { |c| Spree.coupon_handler.new(order, enable_gift_cards: false).remove(c) }
            coupon_promo_ids = order.promotions.select { |p| p.coupon_code? || p.code.present? }.map(&:id)
            if coupon_promo_ids.any?
              order.order_promotions.where(promotion_id: coupon_promo_ids).destroy_all
              order.discounts.where(promotion_id: coupon_promo_ids).destroy_all
            end
            order.update_column(:coupon_code, nil)
            ApplyDiscount.recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.coupon.clear', subject: workspace)
            workspace.to_pos
          end
        end
      end
    end
  end
end
