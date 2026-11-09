# frozen_string_literal: true

module Spree
  module Pos
    # The pay-later VietQR of a credit sale: a bank QR for what the customer
    # still owes, carrying `TN<order number>` ("trả nợ") as the transfer note.
    # It is a plain bank QR on the store's receiving account, not a counter
    # QR allocation, so it never expires and reserves nothing. The note is
    # deliberately not the counter prefix (`MMO<number>`): a counter QR of
    # the same order can never claim the transfer, and the bank webhook only
    # offers it to Collections::ReceiveTransfer after no counter QR matched.
    #
    # The QR is printed from the receipt snapshot, so its facts (account,
    # amount, note and the EMVCo payload) are copied in at issue time.
    module PayLater
      PREFIX = 'TN'
      CODE_PATTERN = /#{PREFIX}\s*(R\d+)/i
      # Receiving accounts whose bank reports every incoming transfer come
      # first: a PayOS account only reports its own payment links.
      PROVIDER_ORDER = %w[sepay manual payos].freeze
      CURRENCY = 'VND'

      module_function

      def transfer_content(order)
        SpreeVietqr::TransferContent.with_suffix("#{PREFIX}#{order.number}")
      end

      # The order number a transfer note pays, or nil.
      def order_number(content)
        content.to_s.match(CODE_PATTERN)&.[](1)&.upcase
      end

      # The account a pay-later QR of this branch pays into; nil while VietQR
      # is off at the branch or the store has no active receiving account.
      def receiving_account(store, branch)
        return nil unless defined?(SpreeVietqr)

        resolver = PaymentMethodResolver.new(store: store)
        row = resolver.available(branch: branch).find { |candidate| candidate.kind == 'vietqr' }
        core = row && resolver.core_for(row)
        return nil if core.nil?

        core.active_receiving_accounts.to_a.each_with_index.min_by do |account, index|
          [PROVIDER_ORDER.index(account.provider) || PROVIDER_ORDER.length, index]
        end&.first
      end

      # What a printed or shared pay-later QR says, or nil when there is
      # nothing to pay or no account to pay into.
      def details(order:, amount:, account:)
        amount = BigDecimal(amount.to_s)
        return nil if account.nil? || order.currency != CURRENCY || !amount.positive? || amount.frac.nonzero?

        content = transfer_content(order)
        whole = amount.to_i
        {
          'amount' => amount.to_s('F'), 'currency' => CURRENCY, 'order_number' => order.number,
          'transfer_content' => content, 'bank_bin' => account.bank_bin,
          'bank_name' => account.bank_name.presence || SpreeVietqr::PaymentInfo::BANK_NAMES[account.bank_bin],
          'account_number' => account.account_number, 'account_name' => account.account_name,
          'payload' => payload(bank_bin: account.bank_bin, account_number: account.account_number, amount: whole, content: content),
          'image_url' => SpreeVietqr::GenerateQr.new.call_for_topup(payment_method: account.payment_method, amount: whole,
                                                                    transfer_content: content, receiving_account: account)
        }
      end

      # The VietQR (NAPAS EMVCo) string banking apps scan: a transfer to an
      # account (QRIBFTTA) with the amount and the note.
      def payload(bank_bin:, account_number:, amount:, content:)
        beneficiary = [tlv('00', bank_bin), tlv('01', account_number)].join
        merchant = [tlv('00', 'A000000727'), tlv('01', beneficiary), tlv('02', 'QRIBFTTA')].join
        body = [
          tlv('00', '01'), tlv('01', '12'), tlv('38', merchant), tlv('53', '704'), tlv('54', amount.to_s),
          tlv('58', 'VN'), tlv('62', tlv('08', content)), '6304'
        ].join
        "#{body}#{crc16(body)}"
      end

      def tlv(id, value)
        "#{id}#{value.to_s.length.to_s.rjust(2, '0')}#{value}"
      end

      # CRC-16/CCITT-FALSE, as EMVCo requires.
      def crc16(data)
        crc = 0xFFFF
        data.each_byte do |byte|
          crc ^= byte << 8
          8.times { crc = crc.nobits?(0x8000) ? (crc << 1) & 0xFFFF : ((crc << 1) ^ 0x1021) & 0xFFFF }
        end
        format('%04X', crc)
      end
    end
  end
end
