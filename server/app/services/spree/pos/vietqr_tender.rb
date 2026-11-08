# frozen_string_literal: true

module Spree
  module Pos
    # The VietQR side of a POS tender. Preparing a VietQR attempt opens a
    # pending core Payment and reserves a receiving account for it (the QR the
    # customer scans). The bank webhook, matched by spree_vietqr, completes
    # that Payment; the cashier then confirms the attempt with the webhook as
    # evidence, or attests the transfer by hand when no webhook arrives.
    # Canceling releases the QR and voids the Payment, unless the money has
    # already landed.
    module VietqrTender
      SNAPSHOT_KEY = 'vietqr_payment_id'
      EVIDENCE_KINDS = %w[vietqr_webhook vietqr_manual].freeze

      module_function

      # @return [Spree::Payment] the pending payment the QR is issued for
      def open!(attempt:, order:, core_method:)
        payment = order.payments.create!(payment_method: core_method, amount: attempt.amount, status: 'pending')
        SpreeVietqr::AllocatePaymentAccount.new(payment_method: core_method, order: order, payment: payment).call
        attempt.update!(snapshot: attempt.snapshot.merge(SNAPSHOT_KEY => payment.id))
        payment
      rescue ActiveRecord::RecordNotFound => e
        raise Conflict.new("VietQR is not available: #{e.message}", reason: 'vietqr_unavailable')
      rescue SpreeVietqr::PayosApiError => e
        raise Conflict.new(e.message, reason: 'vietqr_provider_error')
      end

      def payment_for(attempt)
        id = attempt.snapshot.to_h[SNAPSHOT_KEY]
        id && Spree::Payment.find_by(id: id)
      end

      # Core payments held by VietQR attempts that are still open, which are
      # pending by design and must not block another tender of the sale.
      def open_payment_ids(workspace)
        TenderAttempt.where(workspace_id: workspace.id, status: TenderAttempt::UNRESOLVED).
          filter_map { |attempt| attempt.snapshot.to_h[SNAPSHOT_KEY] }
      end

      def allocation_for(attempt)
        payment = payment_for(attempt)
        return nil if payment.nil?

        SpreeVietqr::PaymentAllocation.where(payment: payment).where.not(status: 'released').ordered_recently.first
      end

      # QR and bank details while waiting, or the confirmed state.
      def summary(attempt, request_base_url: nil)
        payment = payment_for(attempt)
        return nil if payment.nil?

        data = SpreeVietqr::OrderPaymentSummary.call(order: payment.order, payment: payment, request_base_url: request_base_url)
        data&.merge(attempt_id: attempt.prefixed_id, attempt_status: attempt.status)
      end

      # What a customer display shows: read-only, it never reserves an account.
      def display(attempt)
        allocation = allocation_for(attempt)
        return nil if allocation.nil? || !allocation.allocated?

        {
          qr_url: SpreeVietqr::GenerateQr.new.call(payment_method: allocation.payment_method, order: allocation.order, allocation: allocation),
          bank_name: allocation.receiving_account&.bank_name.presence || SpreeVietqr::PaymentInfo::BANK_NAMES[allocation.bank_bin],
          account_number: allocation.account_number,
          account_name: allocation.account_name,
          transfer_note: allocation.transfer_content
        }
      end

      # Settles the attempt's payment and returns what the receipt records.
      # `vietqr_webhook` needs the bank webhook to have completed the payment;
      # `vietqr_manual` is the cashier's attestation of a transfer they saw.
      #
      # @return [Hash] payment:, reference:, receiving_account:
      def confirm!(attempt:, evidence_kind:, reference:, receiving_account:)
        raise Conflict.new('VietQR evidence is required.', reason: 'vietqr_evidence_required') unless EVIDENCE_KINDS.include?(evidence_kind.to_s)

        payment = payment_for(attempt)
        allocation = allocation_for(attempt)
        raise Conflict.new('The VietQR payment of this tender is gone; cancel and prepare again.', reason: 'vietqr_missing') if payment.nil? || allocation.nil?
        raise Conflict, 'VietQR amount does not match the tender.' if payment.amount != attempt.amount

        if evidence_kind.to_s == 'vietqr_webhook'
          unless allocation.confirmed? && payment.status == 'completed'
            raise Conflict.new('The bank has not confirmed this transfer yet.', reason: 'vietqr_not_received')
          end

          event = allocation.webhook_event
          return { payment: payment, reference: bank_reference(event, allocation), receiving_account: allocation.account_number }
        end

        if reference.blank? || receiving_account.blank?
          raise Conflict.new('Bank transfer evidence is required.', reason: 'vietqr_evidence_required')
        end

        unless allocation.confirmed?
          confirmed = SpreeVietqr::ConfirmPayment.new(payment_method: allocation.payment_method).call(allocation: allocation)
          raise Conflict.new('The VietQR payment could not be confirmed.', reason: 'vietqr_confirm_failed') unless confirmed
        end
        raise Conflict.new('The VietQR payment could not be confirmed.', reason: 'vietqr_confirm_failed') unless payment.reload.status == 'completed'

        { payment: payment, reference: reference, receiving_account: receiving_account }
      end

      # Releases the QR and voids the payment. Money that already arrived
      # cannot be canceled away: the cashier confirms it instead.
      def cancel!(attempt)
        allocation = allocation_for(attempt)
        if allocation&.confirmed?
          raise Conflict.new('The bank already confirmed this transfer; confirm the tender instead.', reason: 'vietqr_already_received')
        end

        SpreeVietqr::ReleasePaymentAllocation.new.call(allocation: allocation, reason: 'pos_tender_canceled') if allocation
        payment = payment_for(attempt)
        payment.void! if payment&.can_void?
      end

      def bank_reference(event, allocation)
        payload = event&.raw_payload.to_h
        payload['referenceCode'].presence || payload.dig('data', 'reference').presence ||
          event&.provider_transaction_id.presence || allocation.transfer_content
      end
    end
  end
end
