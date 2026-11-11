# frozen_string_literal: true

module Spree
  module Pos
    # What a customer display may show for its session: the pinned order's
    # lines, totals and amount still due and, for a pinned bank transfer that
    # is still waiting, the amount, the transfer note and the receiving
    # account text configured on the store's bank payment method. It never
    # carries staff, customer, debt or balance data. In `call_board` mode it
    # shows the branch's call numbers instead (CallBoard), with the name the
    # guest gave for the call.
    #
    # Each read takes the next per-session sequence number, so the display
    # can refuse a cached or reordered response, and a signed lease the
    # display returns with its acknowledgement.
    class DisplayState
      ACCOUNT_TEXT_MAX = 300

      def self.call(session)
        new(session).call
      end

      def initialize(session)
        @session = session
      end

      def call
        now = Time.current
        sequence = next_sequence!(now)
        {
          session_id: session.prefixed_id, generation: session.generation, sequence: sequence,
          issued_at: now.iso8601(3), lease_id: session.lease_for(now), freshness_ttl_seconds: session.freshness_seconds,
          token_expires_at: session.token_expires_at.iso8601, branch_name: session.branch.name
        }.merge(content)
      end

      private

      attr_reader :session

      def next_sequence!(now)
        DisplaySession.connection.select_value(
          DisplaySession.sanitize_sql_array(
            ['UPDATE spree_pos_display_sessions SET state_sequence = state_sequence + 1, last_seen_at = ? WHERE id = ? RETURNING state_sequence',
             now, session.id]
          )
        ).to_i
      end

      def content
        # The call board shows the branch's call numbers, never an order.
        if session.mode == 'call_board'
          return { state: 'call_board', order: nil, payment: nil }.merge(CallBoard.call(branch: session.branch))
        end

        workspace = session.pinned_workspace
        return { state: 'idle', order: nil, payment: nil } if workspace.nil? || workspace.operational_status == 'canceled'

        order = workspace.order
        if workspace.operational_status == 'completed'
          return { state: 'completed', order: { number: order.number, currency: order.currency, total: money(order.total) }, payment: nil }
        end

        allocated = FundsAllocation.where(workspace_id: workspace.id, status: 'active', collection_id: nil).sum(:amount)
        line_items = order.line_items.includes(variant: :product).sort_by(&:id)
        sale_lines = SaleLine.where(line_item_id: line_items.map(&:id)).includes(:line_modifiers, :line_components).index_by(&:line_item_id)
        {
          state: 'order',
          order: {
            number: order.number, currency: order.currency,
            lines: line_items.map { |line| line_row(line, sale_lines[line.id]) },
            item_total: money(order.item_total), discount_total: money(order.discounts.sum(:amount)),
            total: money(order.total), paid: money(allocated), amount_due: money([order.total - allocated, 0].max)
          },
          payment: payment(order)
        }
      end

      def line_row(line, sale_line)
        {
          name: line.variant.product.name,
          quantity: sale_line ? sale_line.sale_quantity.to_s('F').delete_suffix('.0') : line.quantity.to_s,
          unit: sale_line&.sale_unit_code, amount: money(line.amount),
          options: options(sale_line)
        }
      end

      # What the customer picked on a menu line, as short texts: options with
      # their count, then combo contents. The cashier's note stays off the screen.
      def options(sale_line)
        return [] unless sale_line&.kind == SaleLineKinds::Menu::KIND

        sale_line.line_modifiers.map { |row| row.quantity > 1 ? "#{row.name} ×#{row.quantity}" : row.name } +
          sale_line.line_components.map { |row| row.quantity > 1 ? "#{row.name} ×#{row.quantity}" : row.name }
      end

      # Only a bank tender still waiting is shown; confirmed, canceled or
      # unknown attempts drop off the screen. A VietQR tender adds its QR and
      # the receiving account it was issued for.
      def payment(order)
        attempt = session.pinned_tender_attempt
        return nil if attempt.nil? || attempt.status != 'prepared'

        if attempt.pos_payment_method.kind == 'vietqr'
          qr = VietqrTender.display(attempt)
          return nil if qr.nil?

          return { kind: 'vietqr', amount: money(attempt.amount), currency: attempt.currency }.merge(qr)
        end

        { kind: 'bank_manual', amount: money(attempt.amount), currency: attempt.currency,
          transfer_note: order.number, account_text: account_text(attempt) }
      end

      def account_text(attempt)
        core = PaymentMethodResolver.new(store: session.store).core_for(attempt.pos_payment_method)
        text = ActionView::Base.full_sanitizer.sanitize(core&.description.to_s).to_s.squish
        text.presence&.first(ACCOUNT_TEXT_MAX)
      end

      def money(value)
        BigDecimal((value || 0).to_s).to_s('F')
      end
    end
  end
end
