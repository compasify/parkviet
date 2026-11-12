# frozen_string_literal: true

module Spree
  module Pos
    module StoredValueCards
      # Shared rules of prepaid money and minutes cards (module
      # `timed_billing`): who sells and reads them, finding them, amounts.
      module Guard
        MODULE = Timed::Guard::MODULE

        module_function

        def branch!(store, branch_id)
          Timed::Guard.branch!(store, branch_id)
        end

        # Selling, topping up and paying with a card: whoever takes payments.
        def collect!(store, staff, branch)
          raise CanCan::AccessDenied if branch.disabled?
          raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::PAYMENT)
        end

        # Reading cards and their history.
        def read!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          keys = [Capabilities::PAYMENT, Capabilities::OPEN_SHIFT, Capabilities::TIMED_OPERATE, Capabilities::REPORT_READ]
          raise CanCan::AccessDenied if keys.none? { |key| policy.allows?(branch, key) }
        end

        def card!(store, card_id)
          StoredValueAccount.locate(StoredValueAccount.for_store(store).cards, card_id) || raise(ActiveRecord::RecordNotFound)
        end

        # A card read from its QR code or tag.
        def by_token!(store, token)
          StoredValueAccount.find_card(store, token) || raise(Conflict.new('This card is not known.', reason: 'stored_value_card_unknown'))
        end

        # A positive whole amount in the currency (signed when `allow_negative`).
        def amount!(value, currency, allow_negative: false)
          text = value.to_s.strip
          negative = allow_negative && text.start_with?('-')
          parsed = Record.money(negative ? text.delete_prefix('-') : text)
          invalid = parsed.nil? || parsed.zero? || !Record.countable_money?(parsed, currency)
          raise Conflict.new('The amount is invalid.', reason: 'stored_value_amount_invalid') if invalid

          negative ? -parsed : parsed
        end

        # Whole minutes, 1 to 100 000 (signed when `allow_negative`).
        def minutes!(value, allow_negative: false)
          minutes = Integer(value.to_s.strip, 10)
          raise ArgumentError if minutes.zero? || minutes.abs > 100_000 || (minutes.negative? && !allow_negative)

          minutes
        rescue ArgumentError
          raise Conflict.new('The minutes are invalid.', reason: 'stored_value_minutes_invalid')
        end

        def text!(value, max, field)
          string = value.to_s.strip
          raise Conflict.new("The #{field} is too long.", reason: 'stored_value_invalid', details: { field: field }) if string.length > max

          string.presence
        end

        # A slip for the card's top-up, printed like a receipt.
        def slip(card, branch, staff, amount, minutes, cash, kind)
          text = Kitchen::TicketDocument
          lines = [
            { 'kind' => 'title', 'title' => card.minutes? ? 'NẠP THẺ GIỜ' : 'NẠP THẺ TIỀN', 'number' => card.card_hint },
            card.holder_name.present? ? text.text([card.holder_name], bold: true, align: 'center') : nil,
            { 'kind' => 'divider', 'style' => 'solid' },
            text.text(["Số tiền nạp: #{money(amount)}"], bold: true),
            minutes ? text.text(["Số phút nạp: #{minutes}"], bold: true) : nil,
            text.text(["#{kind == 'cash' ? 'Tiền mặt' : 'Chuyển khoản'} · Khách đưa #{money(cash[:handed])} · Thối #{money(cash[:change])}"]),
            text.text([card.minutes? ? "Còn: #{card.minutes_balance} phút" : "Số dư: #{money(card.balance)}"], bold: true),
            text.text(["Thu ngân: #{StaffName.call(staff)}"]),
            text.text([PrintDocuments::Text.document_time(Workspace.database_now.iso8601, branch.timezone)], align: 'center')
          ].compact
          PrintDocuments.wrap('receipt', {
                                'documentType' => nil, 'page' => BottleKeeps::Label::PAGE, 'banners' => [], 'header' => lines,
                                'meta' => [{ 'label' => 'Thẻ', 'value' => card.card_hint }],
                                'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def money(value)
          PrintDocuments::Text.money(value)
        end
      end
    end
  end
end
