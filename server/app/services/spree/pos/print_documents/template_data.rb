# frozen_string_literal: true

module Spree
  module Pos
    module PrintDocuments
      # Every queued document reduced to one shape, mirroring
      # receipt-template/data.ts: rows are picked, labelled and formatted here,
      # never computed. Input is JSON-shaped, so a golden file's input feeds
      # both this and the TypeScript side unchanged.
      module TemplateData
        SNAPSHOT_TYPES = { 'sale' => 'sale', 'return' => 'return', 'return_supplement' => 'return', 'refund' => 'refund',
                           'shift_closure' => 'shift_closure' }.freeze

        module_function

        def row(field, label, value, strong: false)
          { field: field, label: label, value: value, strong: strong }
        end

        def t(...) = Text.t(...)
        def str(value) = Text.str(value)
        def rows(value) = Text.rows(value)
        def obj(value) = Text.obj(value)
        def money(...) = Text.money(...)
        def bare(...) = Text.bare(...)
        def non_zero?(value) = Text.non_zero?(value)

        def line_labels
          { index: t('receiptTemplates.print.index'), name: t('receiptTemplates.print.name'), qty: t('ticketQty'),
            price: t('ticketPrice'), discount: t('ticketDiscount'), amount: t('ticketTotal') }
        end

        def signature_labels
          { 'buyer' => t('receiptTemplates.print.buyer'), 'seller' => t('receiptTemplates.print.seller'),
            'cashier' => t('receiptTemplates.print.cashier') }
        end

        def method_label(kind)
          case kind
          when 'cash' then t('receiptCash')
          when 'vietqr' then t('receiptVietqr')
          when 'platform_receivable' then t('receiptPlatform')
          else t('receiptBank')
          end
        end

        def empty_line(name)
          { name: name, sku: nil, quantity: nil, unit: nil, price: nil, price_cell: '', discount_note: nil, discount_cell: '',
            amount: '', amount_cell: '', conversion: nil, trace: [], notes: [] }
        end

        def trace_text(trace)
          parts = []
          parts << t('receiptSerial', serial: str(trace['serial'])) if str(trace['serial'])
          parts << t('receiptLot', lot: str(trace['lot_code'])) if str(trace['lot_code'])
          parts << t('receiptExpiry', date: Text.document_date(str(trace['expiry_on']))) if str(trace['expiry_on'])
          parts.join(' · ')
        end

        def store_from_snapshot(store)
          { name: str(store&.dig('name')), address: str(store&.dig('address')), phone: str(store&.dig('contact_phone')),
            email: str(store&.dig('customer_support_email')), url: str(store&.dig('url')),
            facebook: str(store&.dig('facebook')), instagram: str(store&.dig('instagram')), logo_url: nil }
        end

        def store_from_profile(name, profile)
          { name: str(name), address: str(profile&.dig('address')), phone: str(profile&.dig('contact_phone')),
            email: str(profile&.dig('customer_support_email')), url: str(profile&.dig('url')),
            facebook: str(profile&.dig('facebook')), instagram: str(profile&.dig('instagram')),
            logo_url: str(profile&.dig('logo_url')) }
        end

        def sale_line(line, currency, zone = Text::ZONE)
          discount = str(line['discount'])
          amount = str(line['net_amount']) || str(line['amount'])
          price = str(line['unit_price'])
          empty_line(str(line['name']) || '').merge(
            sku: str(line['sku']), quantity: Text.quantity(str(line['sale_quantity']) || line['quantity'].to_s),
            unit: str(line['sale_unit']), price: money(price, currency), price_cell: bare(price, currency),
            discount_note: non_zero?(discount) ? t('receiptLineDiscount', amount: money(discount, currency)) : nil,
            discount_cell: non_zero?(discount) ? bare(discount, currency) : '',
            amount: money(amount, currency), amount_cell: bare(amount, currency),
            conversion: str(line['conversion']),
            trace: rows(line['trace']).map { |trace| trace_text(trace) }.reject(&:empty?),
            notes: menu_notes(line) + timed_notes(obj(line['timed']), currency, zone)
          )
        end

        # Play time: the room with its time in and out, then each time band
        # ("21:30–22:40 · 70 phút × 200.000 ₫/giờ").
        def timed_notes(timed, currency, zone)
          return [] unless timed

          clock = ->(value) { str(value) ? Time.iso8601(str(value)).in_time_zone(zone).strftime('%H:%M') : '—' }
          notes = ["#{str(timed['resource'])} · #{clock.call(timed['started_at'])}–#{clock.call(timed['stopped_at'])}"]
          rows(timed['bands']).each do |band|
            label = str(band['label'])
            notes << ["#{clock.call(band['starts_at'])}–#{clock.call(band['ends_at'])}", label,
                      "#{band['minutes']} phút × #{money(str(band['price_per_hour']), currency)}/giờ"].compact.join(' · ')
          end
          notes
        end

        # A menu line's options ("+ Trân châu ×2"), combo contents ("- Khoai
        # tây") and note ("* Ít đá"), one detail row each.
        def menu_notes(line)
          notes = rows(line['modifiers']).filter_map { |row| menu_detail('+', str(row['name']), row['quantity']) }
          notes.concat(rows(line['components']).filter_map { |row| menu_detail('-', str(row['name']), row['quantity']) })
          notes << "* #{str(line['note'])}" if str(line['note'])
          notes
        end

        def menu_detail(mark, name, quantity)
          return unless name

          quantity.is_a?(Integer) && quantity > 1 ? "#{mark} #{name} ×#{quantity}" : "#{mark} #{name}"
        end

        def tax_table_rows(taxes, currency)
          rows(taxes).filter_map do |entry|
            amount = str(entry['amount'])
            next unless amount && non_zero?(amount)

            label = str(entry['label']) || t('receiptTax')
            rate = str(entry['rate'])
            row(nil, rate ? "#{label} (#{Text.rate(rate)})" : label, money(amount, currency))
          end
        end

        def taxes_summary(taxes, currency)
          tax_table_rows(taxes, currency).map { |entry| "#{entry[:label]}: #{entry[:value]}" }.join('; ')
        end

        def sale_totals(document, currency)
          totals = obj(document['totals']) || {}
          cash = ->(value) { money(str(value), currency) }
          result = [row('item_total', t('receiptItemTotal'), cash[totals['item_total']])]
          result << row('discount', t('receiptDiscount'), cash[totals['discount_total']]) if non_zero?(str(totals['discount_total']))
          breakdown = tax_table_rows(document['taxes'], currency)
          if breakdown.any?
            result.concat(breakdown)
          else
            result << row('tax', t('receiptTax'), cash[totals['additional_tax_total']]) if non_zero?(str(totals['additional_tax_total']))
            result << row('included_tax', t('receiptIncludedTax'), cash[totals['included_tax_total']]) if non_zero?(str(totals['included_tax_total']))
          end
          result << row('total', t('receiptTotal'), cash[totals['total']], strong: true)
        end

        def sale_payments(document, currency)
          cash = ->(value) { money(str(value), currency) }
          result = rows(document['receipts']).flat_map { |receipt| receipt_rows(receipt, cash) }
          result << row('paid_total', t('receiptPaidTotal'), cash[document['paid_total']], strong: true)
          credit = obj(document['credit'])
          return result unless credit

          result << row('debt', t('receiptDebt'), cash[credit['debt']], strong: true)
          result << row('due_on', t('receiptDueOn'), Text.document_date(str(credit['due_on']))) if str(credit['due_on'])
          result
        end

        def receipt_rows(receipt, cash)
          kind = str(receipt['method'])
          result = [row('methods', method_label(kind), cash[receipt['amount']])]
          if kind == 'cash'
            result << row('handed', t('receiptHanded'), cash[receipt['handed']])
            result << row('change', t('receiptChange'), cash[receipt['change']]) if non_zero?(str(receipt['change']))
          elsif str(receipt['reference'])
            result << row('reference', t('receiptReference'), str(receipt['reference']))
          end
          result
        end

        def present_text(value)
          value.is_a?(String) && Text.trim(value) != '' ? value : nil
        end

        # The pay-later QR, or nil when anything it needs is missing.
        def pay_qr(value)
          qr = obj(value)
          return nil unless qr

          amount = present_text(qr['amount'])
          note = present_text(qr['transfer_content'])
          account = present_text(qr['account_number'])
          payload = present_text(qr['payload'])
          return nil unless amount && note && account && payload

          { value: payload, caption: t('receiptPayQrCaption'),
            lines: [t('payLaterAmount', amount: money(amount, present_text(qr['currency']) || 'VND')),
                    [present_text(qr['bank_name']), account, present_text(qr['account_name']) || ''].select(&:present?).join(' · '),
                    t('payLaterNote', note: note)] }
        end

        def customer_rows(customer)
          value = customer ? [customer[:name], customer[:phone]].compact.join(' · ') : ''
          result = []
          result << row('customer', t('receiptCustomer'), value) unless value.empty?
          result << row('customer', t('receiptDeliveryAddress'), customer[:address], strong: true) if customer&.dig(:address)
          result
        end

        def delivery_meta_rows(delivery)
          return [] unless delivery

          [row(nil, t('receiptDelivery'), delivery[:deliverer] || t('receiptDeliveryYes'), strong: true)]
        end

        def with_delivery_fee(totals, delivery, currency)
          return totals unless delivery && non_zero?(delivery[:fee])

          fee = row(nil, t('receiptDeliveryFee'), money(delivery[:fee], currency))
          at = totals.index { |entry| entry[:field] == 'total' }
          at.nil? ? totals + [fee] : totals[0...at] + [fee] + totals[at..]
        end

        # A posted document from its server snapshot.
        def snapshot(receipt)
          document = receipt['document']
          currency = str(document['currency']) || 'VND'
          zone = str(document['timezone']) || Text::ZONE
          time = Text.document_time(str(document['at']) || receipt['issued_at'], zone)
          business_date = Text.business_date(str(document['business_date']))
          cashier = str(document['cashier'])
          customer = obj(document['customer'])
          meta = snapshot_meta(document, time, business_date, cashier, customer)
          parts = { lines: [], totals: [], payments: [], pay_qr: nil, notes: [] }
          case receipt['source_type']
          when 'sale' then sale_parts(document, currency, meta, parts)
          when 'return' then return_parts(document, currency, parts)
          when 'refund' then refund_parts(document, currency, parts)
          when 'shift_closure' then closure_parts(document, currency, zone, meta, parts)
          end
          parts[:notes] << t('receiptIssuedLate') if receipt['issued_late']
          branch = obj(document['branch'])
          einvoice = obj(receipt['einvoice'])
          parts.merge(
            document_type: SNAPSHOT_TYPES.fetch(receipt['source_type'], 'sale'),
            title: str(document['title']) || receipt['number'], number: receipt['number'], banner: nil,
            store: store_from_snapshot(obj(document['store'])),
            branch: { name: str(branch&.dig('name')), code: str(branch&.dig('code')),
                      return_window_days: branch&.dig('return_window_days').is_a?(Integer) ? branch['return_window_days'] : nil },
            register: str(document['register']), cashier: cashier, time: time, business_date: business_date,
            call_number: str(document['call_number']), guest_name: str(document['guest_name']),
            taxes_text: taxes_summary(document['taxes'], currency),
            customer_name: str(customer&.dig('name')), customer_phone: str(customer&.dig('phone')), customer_address: str(customer&.dig('address')),
            meta: meta, line_labels: line_labels, signature_labels: signature_labels, disclaimer: receipt['disclaimer'],
            **einvoice_fields(einvoice)
          )
        end

        # The sale's e-invoice as the receipt reads it now (ReceiptInfo):
        # lookup details once issued, the buyer link while it is open.
        def einvoice_fields(einvoice)
          buyer_url = str(einvoice&.dig('buyer_url'))
          { einvoice_lookup_code: str(einvoice&.dig('lookup_code')), einvoice_lookup_url: str(einvoice&.dig('lookup_url')),
            einvoice_buyer_url: buyer_url, einvoice_buyer_caption: buyer_url ? t('receiptEinvoiceBuyerCaption') : nil }
        end

        def snapshot_meta(document, time, business_date, cashier, customer)
          meta = [row('time', t('receiptTime'), time)]
          meta << row(nil, t('receiptBusinessDate'), business_date) unless business_date.empty?
          meta << row('cashier', t('receiptCashier'), cashier) if cashier
          meta << row('order_number', t('receiptOrderNumber'), str(document['order_number'])) if str(document['order_number'])
          meta << row('return_number', t('receiptReturnNumber'), str(document['return_number'])) if str(document['return_number'])
          meta.concat(customer_rows(customer && { name: str(customer['name']), phone: str(customer['phone']), address: str(customer['address']) }))
        end

        def sale_parts(document, currency, meta, parts)
          delivery_doc = obj(document['delivery'])
          delivery = delivery_doc && { deliverer: str(delivery_doc['deliverer']), fee: str(delivery_doc['fee']) }
          meta.concat(delivery_meta_rows(delivery))
          zone = str(document['timezone']) || Text::ZONE
          parts[:lines] = rows(document['lines']).map { |line| sale_line(line, currency, zone) }
          parts[:totals] = with_delivery_fee(sale_totals(document, currency), delivery, currency)
          parts[:payments] = sale_payments(document, currency)
          parts[:pay_qr] = pay_qr(obj(document['credit'])&.dig('pay_qr'))
          parts[:notes] << str(document['note']) if str(document['note'])
        end

        def return_parts(document, currency, parts)
          cash = ->(value) { money(str(value), currency) }
          parts[:lines] = rows(document['lines']).map do |line|
            empty_line(str(line['name']) || '').merge(
              sku: str(line['sku']), amount: cash[line['amount']], amount_cell: bare(str(line['amount']), currency),
              notes: [t('receiptReturnedQuantity', quantity: Text.quantity(line['quantity'])),
                      t(line['condition'] == 'damaged' ? 'receiptConditionDamaged' : 'receiptConditionResellable')]
            )
          end
          parts[:totals] = [row('total', t('receiptReturnValue'), cash[document['entitlement_total']], strong: true)]
          if document['entitlement_posted']
            parts[:totals] << row(nil, t('receiptCreditNote'), cash[document['credit_note_amount']]) if non_zero?(str(document['credit_note_amount']))
            parts[:totals] << row(nil, t('receiptRefundEntitlement'), cash[document['refund_entitlement']])
          else
            parts[:notes] << t('receiptReturnPending')
          end
          parts[:notes] << t('receiptReason', reason: str(document['reason'])) if str(document['reason'])
        end

        def refund_parts(document, currency, parts)
          label = str(document['method']) == 'cash' ? t('receiptRefundCash') : t('receiptRefundBank')
          parts[:payments] = [row(nil, label, money(str(document['amount']), currency), strong: true)]
          parts[:payments] << row('reference', t('receiptReference'), str(document['reference'])) if str(document['reference'])
        end

        def closure_parts(document, currency, zone, meta, parts)
          cash = ->(value) { money(str(value), currency) }
          meta << row(nil, t('receiptShiftOpened'), Text.document_time(str(document['opened_at']), zone))
          meta << row(nil, t('receiptCloser'), str(document['closer'])) if str(document['closer'])
          meta << row(nil, t('receiptApprover'), str(document['approver'])) if str(document['approver'])
          parts[:totals] = [
            row(nil, t('receiptOpeningFloat'), cash[document['opening_float']]), row(nil, t('receiptInflow'), cash[document['inflow_total']]),
            row(nil, t('receiptOutflow'), cash[document['outflow_total']]),
            row(nil, t('receiptExpected'), cash[document['expected']], strong: true),
            row(nil, t('receiptCounted'), cash[document['counted']], strong: true),
            row(nil, t('receiptVariance'), cash[document['variance']], strong: true)
          ]
          parts[:notes] << t('receiptReason', reason: str(document['reason'])) if str(document['reason'])
        end

        # A provisional bill of an open order.
        def prebill(workspace, place, now, time_zone)
          totals = workspace['totals']
          currency = totals&.dig('currency') || 'VND'
          time = Text.document_time(now.utc.iso8601(3), time_zone)
          customer = workspace_customer(workspace)
          delivery = workspace_delivery(workspace)
          {
            document_type: 'prebill', title: t('receiptPrebillTitle'), number: nil, banner: t('receiptPrebillBanner'),
            store: store_from_profile(place['storeName'], place['storeProfile']),
            branch: { name: str(place['branchName']), code: str(place['branchCode']), return_window_days: place['returnWindowDays'] },
            register: str(place['registerName']), cashier: nil, time: time,
            business_date: Text.business_date(workspace['business_date']),
            call_number: workspace['order_number']&.to_s, guest_name: str(workspace['guest_name']),
            taxes_text: taxes_summary(totals&.dig('taxes'), currency),
            customer_name: customer&.dig(:name), customer_phone: customer&.dig(:phone), customer_address: customer&.dig(:address),
            meta: [row('time', t('receiptTime'), time), *customer_rows(customer), *delivery_meta_rows(delivery)],
            lines: Array(workspace['line_items']).map { |line| prebill_line(line, currency, time_zone) },
            line_labels: line_labels, signature_labels: signature_labels,
            totals: with_delivery_fee(prebill_totals(totals, currency, workspace['drink_credit']), delivery, currency),
            payments: prebill_payments(workspace['financial'], currency), pay_qr: nil,
            notes: [Text.trim(workspace['note'].to_s), t('receiptPrebillNote')].reject(&:empty?),
            disclaimer: t('receiptDisclaimer')
          }
        end

        def workspace_customer(workspace)
          customer = workspace['customer']
          customer && { name: str(customer['name']), phone: str(customer['phone']), address: str(customer['address']) }
        end

        def workspace_delivery(workspace)
          delivery = workspace['delivery']
          delivery && { deliverer: str(delivery['deliverer']), fee: delivery['fee'] }
        end

        def prebill_line(line, currency, time_zone)
          price = line['unit_price'] || line['price']
          amount = line['item_net_amount'] || line['net_amount'] || line['amount']
          trace = Array(line['serial_codes']).map { |serial| t('receiptSerial', serial: serial) }
          trace << t('receiptLot', lot: line['lot_code']) if str(line['lot_code'])
          empty_line(line['name']).merge(
            sku: str(line['sku']), quantity: Text.quantity(line['sale_quantity'] || line['quantity']),
            unit: str(line['sale_unit']), price: money(price, currency), price_cell: bare(price, currency),
            amount: money(amount, currency), amount_cell: bare(amount, currency), trace: trace,
            notes: menu_notes(line) + timed_estimate(line, currency, time_zone)
          )
        end

        # A clock still running is not on the order yet: its line shows the
        # server's quote and the time it was read ("Tạm tính đến 22:40: …").
        def timed_estimate(line, currency, time_zone)
          session = obj(line['timed_session'])
          quote = obj(session&.dig('quote'))
          return [] unless line['kind'] == 'timed' && quote && quote['final'] != true && str(quote['as_of'])

          time = Time.iso8601(str(quote['as_of'])).in_time_zone(time_zone || Text::ZONE).strftime('%H:%M')
          [t('receiptTimedEstimate', time: time, amount: money(str(quote['amount']), currency))]
        end

        # A VIP table's minimum spend shows as its own row; the drink credit
        # of door tickets left unused follows the total.
        def prebill_totals(totals, currency, drink_credit = nil)
          return [] unless totals

          result = [row('item_total', t('receiptItemTotal'), money(totals['item_total'], currency))]
          result << row('discount', t('receiptDiscount'), money(totals['discount_total'], currency)) if non_zero?(totals['discount_total'])
          Array(totals['fees']).select { |fee| fee['kind'] == 'minimum_spend' && non_zero?(fee['amount']) }.each do |fee|
            result << row(nil, t('receiptMinimumSpend'), money(fee['amount'], currency))
          end
          result.concat(tax_table_rows(totals['taxes'], currency))
          result << row('total', t('receiptTotal'), money(totals['total'], currency), strong: true)
          result << row(nil, t('receiptDrinkCreditLeft'), money(drink_credit['remaining'], currency)) if drink_credit.is_a?(Hash) && drink_credit['remaining']
          result
        end

        def prebill_payments(financial, currency)
          return [] unless financial

          [row('paid_total', t('receiptPaidTotal'), money(financial['allocated'], currency)),
           row(nil, t('receiptRemaining'), money(financial['remaining'], currency), strong: true)]
        end
      end
    end
  end
end
