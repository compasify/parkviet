# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Shared rules of the table commands: who may serve tables, which
      # shift a table order is booked on, the table letters, and locking
      # several orders without deadlocks.
      module Guard
        MODULE = 'fnb.tables'
        LABELS = ('A'..'Z').to_a.freeze

        module_function

        # Opening a table: the people serving tables and the cashiers.
        def serve!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          allowed = policy.allows?(branch, Capabilities::TABLE_SERVE) || policy.allows?(branch, Capabilities::OPEN_SHIFT)
          raise CanCan::AccessDenied if branch.disabled? || !allowed || !policy.permission?('write_pos_orders')
        end

        # Editing an order at a table (move, merge, split).
        def edit!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          raise CanCan::AccessDenied if workspace.branch.disabled? || workspace.register&.disabled? ||
            !policy.can_edit_workspace?(workspace) || !policy.permission?('write_pos_orders')
        end

        def table!(branch, resource_id)
          resource = Resource.locate(Resource.where(branch_id: branch.id), resource_id)
          raise ActiveRecord::RecordNotFound if resource.nil?

          resource
        end

        # A table that can take guests: active and not marked cleaning or out of service.
        def usable!(resource)
          raise Conflict.new('This table is archived.', reason: 'table_archived') unless resource.active?
          return if resource.manual_status == 'available'

          raise Conflict.new('This table is not available.', reason: 'table_unavailable', details: { manual_status: resource.manual_status })
        end

        # Table orders are booked on the open shift of the branch's table register.
        def booking_shift!(branch)
          if branch.table_register_id.nil?
            raise Conflict.new('Choose the register that table orders are booked on.', reason: 'table_register_missing')
          end

          shift = Shift.for_store(branch.store).open_now.where(register_id: branch.table_register_id).order(opened_at: :desc).first
          raise Conflict.new('No shift is open on the table register.', reason: 'no_open_shift') if shift.nil?

          shift
        end

        def guest_count!(value)
          return nil if value.nil? || value.to_s.strip.empty?

          count = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('The guest count is invalid.', reason: 'guest_count_invalid') unless count&.between?(0, 999)

          count
        end

        def open_orders(resource)
          Workspace.where(resource_id: resource.id, operational_status: Workspace::OPEN_STATUSES)
        end

        # The first letter no open order of the table uses.
        def next_label(resource, except: nil)
          used = open_orders(resource).where.not(id: except).pluck(:table_label).compact
          LABELS.find { |label| !used.include?(label) } ||
            raise(Conflict.new('This table has too many open orders.', reason: 'table_full'))
        end

        # Every order a command changes, locked in id order so two commands
        # over the same orders can never wait on each other.
        def lock_all!(workspaces)
          ids = workspaces.map(&:id).uniq.sort
          locked = Workspace.where(id: ids).order(:id).lock.to_a.index_by(&:id)
          workspaces.map { |workspace| locked.fetch(workspace.id) }
        end

        def editable!(workspace)
          unless Workspace::OPEN_STATUSES.include?(workspace.operational_status)
            raise Conflict.new('This order is no longer open.', revision: workspace.revision, reason: 'workspace_closed')
          end

          workspace.ensure_snapshot_editable!
        end

        # The source order: open for editing, by its lease holder, at the
        # revision the client saw.
        def source!(workspace, staff, revision, lease_generation, editor_id)
          raise Conflict.new('Workspace is not editing.', revision: workspace.revision) unless workspace.operational_status == 'editing'
          unless workspace.lease_current?(staff, editor_id) && workspace.lease_generation == lease_generation
            raise Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale')
          end
          raise Conflict.new('Revision is stale.', revision: workspace.revision) if workspace.revision != revision

          editable!(workspace)
        end

        # Lines leave one order for another whole. Discounts are bound to the
        # order they were given on, and traced units to their reservations,
        # so orders holding them are moved only after those are removed.
        def movable_lines!(workspace, sale_lines)
          if DiscountIntent.exists?(workspace_id: workspace.id) || LineDiscountIntent.manual.exists?(sale_line_id: sale_lines.map(&:id)) ||
             workspace.order.coupon_code.present?
            raise Conflict.new('Remove the discounts of this order first.', revision: workspace.revision, reason: 'discount_present')
          end
          return unless sale_lines.any? { |line| line.tracked_mode.to_s != 'none' }

          raise Conflict.new('Lots and serial numbers stay on their order.', revision: workspace.revision, reason: 'traced_line')
        end

        # Moves sale lines and their order lines onto another order. Promotion
        # rows of the lines go; both orders are summed again by the caller.
        def move_lines!(sale_lines, target)
          line_item_ids = sale_lines.map(&:line_item_id)
          Spree::Discount.where(line_item_id: line_item_ids).destroy_all
          # Taxes are written again for the order the lines join.
          Spree::TaxLine.where(line_item_id: line_item_ids).delete_all
          Spree::LineItem.where(id: line_item_ids).update_all(order_id: target.order_id, updated_at: Time.current)
          SaleLine.where(id: sale_lines.map(&:id)).update_all(workspace_id: target.id, order_id: target.order_id, updated_at: Time.current)
        end

        def recalculate!(workspace)
          workspace.order.reload
          Workspaces::ApplyDiscount.recalculate!(workspace)
        end

        def bump!(workspace)
          workspace.update!(revision: workspace.revision + 1)
        end

        def announce!(branch, workspaces, resources)
          Realtime.announce_workspaces(workspaces.map(&:id))
          resources.compact.uniq(&:id).each { |resource| Realtime.publish(branch, 'resource.updated', id: resource.prefixed_id) }
        end
      end
    end
  end
end
