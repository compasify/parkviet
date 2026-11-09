# frozen_string_literal: true

module SpreeVietqr
  # A verified bank transfer that matched no counter QR allocation is offered
  # to Spree::Pos::Collections::ReceiveTransfer, which books it against a debt
  # when its note is a pay-later code (Spree::Pos::PayLater). This uses the
  # gem's own seam for unmatched transfers (`confirm_topup`, called only after
  # MatchTransaction found nothing), so counter-QR matching is untouched.
  # The gem is a git submodule; it is decorated here rather than edited.
  module ProcessWebhookDecorator
    private

    def confirm_topup(transaction, event)
      super || Spree::Pos::Collections::ReceiveTransfer.call(transaction: transaction, webhook_event: event,
                                                             payment_method: @payment_method)
    end
  end

  ProcessWebhook.prepend(ProcessWebhookDecorator)

  # Staff retrying an unmatched event (after opening a shift, say) gets the
  # same pay-later booking as a fresh webhook.
  module RetryWebhookEventDecorator
    def call
      return true if super
      return false unless @event.status == 'unmatched'

      provider = Providers::Registry.resolve(@event.provider).new(payment_method: @payment_method,
                                                                  receiving_account: @event.receiving_account)
      transaction = provider.parse_transaction(@event.raw_payload.with_indifferent_access)
      Spree::Pos::Collections::ReceiveTransfer.call(transaction: transaction, webhook_event: @event, payment_method: @payment_method)
    rescue StandardError => e
      @event.mark_status!('error', error: e.message)
      false
    end
  end

  RetryWebhookEvent.prepend(RetryWebhookEventDecorator)
end
