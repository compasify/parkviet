# frozen_string_literal: true

module Spree
  module Pos
    module Tables
      # Splits a table order into one bill per seat. Lines with a seat go to
      # that seat's bill; a shared line (no seat) goes to the seat the
      # cashier picks in `shared`, or stays on the first seat's bill. The
      # first seat keeps the original order; every other seat gets a new
      # order at the same table, on the same shift.
      #
      # An order-wide discount follows the money: the amount it took is
      # spread over the bills in proportion to their items (largest
      # remainder, whole units of the currency) as one flat discount per
      # bill, so the bills add up to the order they came from.
      module SplitBySeat
        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, shared: {})
          picks = normalize(shared)
          payload = { 'command' => 'table.split_by_seat', 'workspace_id' => workspace.prefixed_id, 'revision' => revision,
                      'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id),
                      'shared' => picks }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.edit!(workspace, staff) }) do
            source, = Guard.lock_all!([workspace])
            ModulePolicy.require!(source.branch, Guard::MODULE)
            Guard.source!(source, staff, revision, lease_generation, editor_id)
            raise Conflict.new('This order is not at a table.', revision: source.revision, reason: 'not_table_order') if source.resource.nil?

            lines = SaleLine.where(workspace_id: source.id).order(:id).to_a
            seats = seat_map!(source, lines, picks)
            numbers = seats.values.compact.uniq.sort
            raise Conflict.new('Give the dishes of at least two seats.', revision: source.revision, reason: 'split_seats_invalid') if numbers.size < 2

            movable!(source, lines)
            discount = take_discount!(source)
            table = source.resource
            table.lock!
            bills = numbers.drop(1).map do |seat|
              created = Workspaces::Create.draft!(store: source.store, staff: staff, shift: source.shift,
                                                  editor_digest: Workspace.editor_digest(editor_id), service_mode: source.service_mode,
                                                  resource: table, guest_count: 1, table_label: Guard.next_label(table))
              moving = lines.select { |line| seats[line.id] == seat }
              Guard.move_lines!(moving, created)
              moving.each { |line| Inventory::AllocateTraceability.release_line!(line) }
              [seat, created]
            end
            all = [[numbers.first, source]] + bills
            all.each { |_, bill| Guard.recalculate!(bill) }
            spread!(discount, all.map(&:last)) if discount
            bills.each { |_, bill| bill.update!(revision: bill.revision + 1) }
            Guard.bump!(source)
            AuditEntry.record!(store: source.store, actor: staff, action: 'table.split_by_seat', subject: source,
                               metadata: { seats: all.to_h { |seat, bill| [seat, bill.prefixed_id] }, shared: picks,
                                           discount: discount && discount[:amount].to_s('F') })
            bills.each do |seat, bill|
              AuditEntry.record!(store: source.store, actor: staff, action: 'workspace.create', subject: bill,
                                 metadata: { split_from_workspace_id: source.prefixed_id, seat: seat })
            end
            Guard.announce!(source.branch, all.map(&:last), [table])
            { 'workspace' => source.to_pos, 'new_workspaces' => bills.map { |_, bill| bill.to_pos } }
          end
        end

        # { sale_line_id => seat } for shared lines, as sent.
        def normalize(shared)
          raw = shared.respond_to?(:to_unsafe_h) ? shared.to_unsafe_h : shared.to_h
          raw.to_h { |id, seat| [id.to_s, Workspaces::TableLines.small!(seat, 1, 99, 'seat_invalid')] }.sort.to_h
        end

        # Line id => the seat whose bill it joins.
        def seat_map!(source, lines, picks)
          by_ref = lines.index_by(&:prefixed_id)
          picks.each do |line_id, seat|
            line = by_ref[line_id]
            if line.nil? || line.seat
              raise Conflict.new('Only shared dishes are given a seat here.', revision: source.revision, reason: 'split_lines_invalid')
            end
            unless lines.any? { |row| row.seat == seat }
              raise Conflict.new('Give a shared dish to a seat that has dishes.', revision: source.revision, reason: 'split_seats_invalid')
            end
          end
          lines.to_h { |line| [line.id, line.seat || picks[line.prefixed_id]] }
        end

        # Lines with their own discounts, a coupon or traced units stay
        # where they are; an order-wide discount is spread instead.
        def movable!(source, lines)
          if LineDiscountIntent.exists?(sale_line_id: lines.map(&:id)) || source.order.coupon_code.present?
            raise Conflict.new('Remove the item discounts and coupon of this order first.', revision: source.revision,
                                                                                            reason: 'discount_present')
          end
          return unless lines.any? { |line| line.tracked_mode.to_s != 'none' }

          raise Conflict.new('Lots and serial numbers stay on their order.', revision: source.revision, reason: 'traced_line')
        end

        # Removes the order-wide discount, remembering what it took.
        def take_discount!(source)
          intent = DiscountIntent.find_by(workspace_id: source.id)
          return nil if intent.nil?

          taken = { amount: Workspaces::ApplyDiscount.applied_amount(intent), reason: intent.reason, actor: intent.actor }
          discount_ids = intent.allocations.pluck(:discount_id)
          DiscountAllocation.where(discount_intent_id: intent.id).delete_all
          source.order.discounts.where(id: discount_ids).destroy_all
          intent.destroy!
          taken
        end

        def spread!(discount, bills)
          exponent = ::Money::Currency.find(bills.first.order.currency)&.exponent || 0
          unit = BigDecimal(10)**-exponent
          bases = bills.map { |bill| bill.order.reload.item_total }
          total = bases.sum
          return if total <= 0

          raw = bases.map { |base| discount[:amount] * base / total }
          shares = raw.map { |value| (value / unit).floor * unit }
          left = ((discount[:amount] - shares.sum) / unit).round
          raw.each_with_index.sort_by { |value, index| [-(value - shares[index]), index] }.first(left).each { |_, index| shares[index] += unit }
          bills.zip(shares).each do |bill, share|
            next unless share.positive?

            DiscountIntent.create!(workspace: bill, actor: discount[:actor], value_type: 'flat', value: share.to_s('F').sub(/\.0\z/, ''),
                                   reason: discount[:reason])
            Guard.recalculate!(bill)
          end
        end
      end
    end
  end
end
