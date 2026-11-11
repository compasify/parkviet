# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # Opens a page in the book: the guest's bottle, its level and a photo,
      # under a new code for its label. From a sold line (the bottle of a
      # completed order, or the bottle part of a bottle-service combo) or
      # typed in by hand. Kept for the branch's `bottle_keep_days`.
      module Open
        module_function

        def call(store:, staff:, key:, branch_id:, variant_id:, level_percent:, customer_id: nil, guest_name: nil, phone: nil,
                 source_sale_line_id: nil, note: nil, photo: nil)
          branch = Guard.branch!(store, branch_id)
          upload = Guard.photo!(photo)
          payload = { 'command' => 'bottle_keep.open', 'branch_id' => branch.prefixed_id, 'variant_id' => variant_id.to_s,
                      'level_percent' => level_percent.to_s, 'customer_id' => customer_id.to_s.presence,
                      'guest_name' => guest_name.to_s.squish.presence, 'phone' => phone.to_s.presence,
                      'source_sale_line_id' => source_sale_line_id.to_s.presence, 'note' => note.to_s.squish.presence,
                      'photo' => Guard.photo_digest(upload) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.keep!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            level = Guard.level!(level_percent)
            raise Conflict.new('An empty bottle is not kept.', reason: 'bottle_level_invalid') if level.zero?

            line = source_line!(branch, source_sale_line_id)
            variant = variant!(store, variant_id, line)
            customer = customer_id.present? ? CustomerProfile.locate(CustomerProfile.for_store(store), customer_id) || raise(ActiveRecord::RecordNotFound) : nil
            kept_on = BusinessDay.for(branch, Workspace.business_now)
            keep = BottleKeep.create!(
              store: store, branch: branch, customer_profile: customer, guest_name: guest_name.to_s.squish.first(120).presence,
              phone: phone.present? ? CustomerProfile.normalize_phone(phone).first(32) : nil, variant: variant,
              code: Guard.new_code(branch), level_percent: level, kept_on: kept_on, expires_on: kept_on + branch.bottle_keep_days,
              source_order_id: line&.order_id, source_sale_line: line, note: note.to_s.squish.first(200).presence,
              status: 'kept', created_by: staff
            )
            Guard.attach!(keep, upload)
            Guard.event!(keep, kind: 'open', actor: staff, level_before: nil, level_after: level, workspace: line&.workspace)
            Guard.audit!(keep, staff, 'bottle_keep.open', variant_id: variant.prefixed_id, source_sale_line_id: line&.prefixed_id)
            keep.reload.to_pos(with_events: true)
          end
        end

        # A line of a completed order of the branch, if named.
        def source_line!(branch, sale_line_id)
          return nil if sale_line_id.blank?

          line = SaleLine.locate(SaleLine.joins(:workspace).where(spree_pos_workspaces: { branch_id: branch.id, operational_status: 'completed' }),
                                 sale_line_id)
          raise Conflict.new('Only a bottle of a paid order is kept.', reason: 'bottle_source_invalid') if line.nil?

          line
        end

        # The bottle: the named variant of the store, or the line's own. A
        # combo line names the bottle among its parts.
        def variant!(store, variant_id, line)
          return line.variant if variant_id.blank? && line

          variant = Spree::Variant.find_by_prefix_id(variant_id.to_s)
          raise ActiveRecord::RecordNotFound if variant.nil? || variant.product&.store_id != store.id
          if line && variant.id != line.variant_id && line.line_components.none? { |part| part.variant_id == variant.id }
            raise Conflict.new('This bottle is not on that line.', reason: 'bottle_source_invalid')
          end

          variant
        end
      end
    end
  end
end
