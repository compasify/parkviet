# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # Takes in a delivery platform's order as the cashier reads it off the
      # platform's tablet: a delivery sale on the cashier's open shift, with
      # the platform as its source, menu lines with their options, and the
      # platform's own price where it differs from the menu's. The order goes
      # straight to the kitchen with its call number, whatever the branch's
      # send trigger, since the customer has already paid the platform.
      #
      # One command, idempotent by its key, and one order per platform
      # reference at a branch: the same reference again is refused with the
      # order it already made. Orders from a platform's own API would enter
      # through this same workflow.
      module Enter
        MODULE = 'fnb.delivery_platforms'
        MAX_LINES = 50
        MAX_QUANTITY = 100
        NOTE_MAX = 1000
        PRICE_REASON = 'platform_price'

        module_function

        def call(store:, staff:, key:, editor_id:, platform:, platform_order_ref:, lines:, pickup_code: nil, note: nil,
                 register_id: nil, branch_id: nil)
          platform = platform.to_s
          ref = platform_order_ref.to_s.strip
          pickup = pickup_code.to_s.strip.presence
          note = note.to_s.strip.presence
          rows = normalize_lines(lines)
          payload = {
            'command' => 'platform_order.enter', 'editor_digest' => Workspace.editor_digest(editor_id),
            'register_id' => register_id.to_s, 'branch_id' => branch_id.to_s, 'platform' => platform,
            'platform_order_ref' => ref, 'pickup_code' => pickup, 'note' => note, 'lines' => rows
          }
          authorize = lambda do
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).permission?('write_pos_orders')
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            validate!(platform, ref, pickup, note, rows)
            branch = branch!(store, staff, register_id, branch_id)
            ModulePolicy.require!(branch, MODULE)
            setting = PlatformSetting.find_by(branch_id: branch.id, platform: platform)
            raise Conflict.new('This platform is not turned on at the branch.', reason: 'platform_disabled') unless setting&.active?

            # One reference, one order: entries of one platform at a branch
            # take turns, so a double entry always finds the first.
            setting.lock!
            existing = PlatformOrder.find_by(branch_id: branch.id, platform: platform, platform_order_ref: ref)
            if existing
              raise Conflict.new('This platform order is already entered.', reason: 'platform_order_duplicate',
                                                                            details: { platform_order_id: existing.prefixed_id })
            end

            workspace = open_workspace!(store, staff, key, editor_id, register_id, branch_id)
            raise Conflict, 'The order must be entered at the branch of the platform.' unless workspace.branch_id == branch.id

            workspace.update!(order_source: platform, note: note)
            rows.each_with_index { |row, index| add_line!(workspace, staff, key, editor_id, row, index) }
            Workspaces::ApplyDiscount.recalculate!(workspace)
            workspace.update!(revision: workspace.revision + 1)

            order = PlatformOrder.new(store: store, branch: branch, workspace: workspace, platform: platform,
                                      platform_order_ref: ref, pickup_code: pickup, status: 'accepted',
                                      commission_rate: setting.commission_rate, currency: workspace.order.currency,
                                      entered_by: staff)
            order.assign_gross(workspace.order.total)
            order.save!
            OrderNumbers.assign!(workspace)
            Kitchen::Send.call(workspace: workspace, actor: staff, send_key: "platform:#{order.prefixed_id}")
            AuditEntry.record!(store: store, actor: staff, action: 'platform_order.enter', subject: workspace,
                               metadata: { platform_order_id: order.prefixed_id, platform: platform, platform_order_ref: ref,
                                           gross: order.gross_amount.to_s('F') })
            order.reload.to_pos
          end
        end

        def normalize_lines(lines)
          Array(lines).first(MAX_LINES + 1).map do |line|
            line = line.respond_to?(:to_unsafe_h) ? line.to_unsafe_h : line.to_h
            line = line.transform_keys(&:to_s)
            modifiers = line['modifiers'].nil? ? nil : Array(line['modifiers']).map { |row| modifier(row) }
            { 'variant_id' => line['variant_id'].to_s, 'quantity' => line['quantity'].to_s, 'modifiers' => modifiers,
              'note' => line['note'].to_s.strip.presence, 'platform_price' => line['platform_price'].to_s.strip.presence }
          end
        end

        def modifier(row)
          row = row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row.to_h
          row = row.transform_keys(&:to_s)
          quantity = row['quantity'].nil? ? 1 : Integer(row['quantity'].to_s, exception: false) || row['quantity'].to_s
          { 'option_id' => row['option_id'].to_s, 'quantity' => quantity }
        end

        def validate!(platform, ref, pickup, note, rows)
          raise Conflict.new('Choose GrabFood or ShopeeFood.', reason: 'platform_invalid') unless PlatformSetting::PLATFORMS.include?(platform)
          raise Conflict.new('The platform order code is invalid.', reason: 'platform_order_ref_invalid') unless ref.match?(PlatformOrder::REF_FORMAT)
          raise Conflict.new('The pickup code is too long.', reason: 'pickup_code_invalid') if pickup && pickup.length > PlatformOrder::PICKUP_MAX
          raise Conflict, 'The note is too long.' if note && note.length > NOTE_MAX
          raise Conflict.new('The order has no items.', reason: 'platform_order_empty') if rows.empty?
          raise Conflict, "An order takes at most #{MAX_LINES} lines." if rows.size > MAX_LINES

          rows.each do |row|
            quantity = Integer(row['quantity'], exception: false)
            raise Conflict, 'Quantity is invalid.' if quantity.nil? || quantity < 1 || quantity > MAX_QUANTITY
            next if row['platform_price'].nil?

            price = Record.money(row['platform_price'])
            raise Conflict.new('The platform price is invalid.', reason: 'platform_price_invalid') if price.nil?
          end
        end

        # The register's branch, or the register-less branch the cashier
        # works at; the workspace command checks the shift itself.
        def branch!(store, staff, register_id, branch_id)
          if register_id.present?
            register = Register.locate(Register.for_store(store), register_id)
            raise ActiveRecord::RecordNotFound if register.nil?

            return register.branch
          end
          branch = Branch.locate(AccessPolicy.new(store: store, staff: staff).visible_branches, branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          branch
        end

        def open_workspace!(store, staff, key, editor_id, register_id, branch_id)
          result = Workspaces::Create.call(store: store, staff: staff, key: "#{key}:workspace", editor_id: editor_id,
                                           register_id: register_id.presence, branch_id: branch_id.presence,
                                           service_mode: 'delivery')
          Workspace.find_by_prefix_id(result['id'])
        end

        # A menu line as the counter adds it, then the platform's price.
        def add_line!(workspace, staff, key, editor_id, row, index)
          Workspaces::ManageLineItem.add(
            workspace: workspace, staff: staff, revision: workspace.revision, lease_generation: workspace.lease_generation,
            editor_id: editor_id, key: "#{key}:line:#{index}", variant_id: row['variant_id'],
            quantity: Integer(row['quantity']), modifiers: row['modifiers'], note: row['note'], merge: false
          )
          sale_line = SaleLine.where(workspace_id: workspace.id).order(:id).last
          unless sale_line&.kind == SaleLineKinds::Menu::KIND
            raise Conflict.new('Platform orders take menu items only.', reason: 'platform_item_not_menu')
          end

          price = row['platform_price'] && Record.money(row['platform_price'])
          reprice!(workspace, staff, sale_line, price) if price && price != sale_line.unit_price
        end

        # The platform's price for one unit of the line, options included.
        # Audited as a price override with the platform as its reason; the
        # platform set it, so no approval is asked for.
        def reprice!(workspace, staff, sale_line, price)
          raise Conflict.new('The platform price is invalid.', reason: 'platform_price_invalid') unless Record.countable_money?(price,
                                                                                                                                workspace.order.currency)

          variant_unit = Workspaces::ManageLineItem.send(:variant_unit_for_sale_line, workspace, sale_line)
          line_price = UnitNormalizer.unit_price_per_base(price: price, variant_unit: variant_unit)
          before = sale_line.unit_price
          sale_line.line_item.update!(price: line_price, price_source: Spree::LineItem::MANUAL_PRICE_SOURCE)
          sale_line.assign_attributes(unit_price: price, line_price: line_price)
          sale_line.update!(merge_key: sale_line.merge_key_now)
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.price.override', subject: workspace,
                             metadata: { sale_line_id: sale_line.prefixed_id, before: before.to_s('F'), after: price.to_s('F'),
                                         reason: PRICE_REASON, platform: workspace.order_source })
        end
      end
    end
  end
end
