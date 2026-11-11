# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Takes a booking's deposit: one actual receipt (ReceivedFunds) on the
      # collector's own open shift, with no order. It is money kept for the
      # guest, not revenue: it stays available on the funds until it is
      # applied to the order the party eats (ApplyDeposit), paid back
      # (RefundDeposit) or kept as a holding fee (ForfeitDeposit). Booked
      # like a debt collection: cash enters the drawer, a transfer needs its
      # reference and receiving account.
      module TakeDeposit
        ACTION = 'reservation.take_deposit'

        module_function

        def call(store:, staff:, key:, reservation_id:, kind:, amount:, handed_amount: nil, reference: nil,
                 receiving_account: nil, confirm_duplicate: nil)
          kept = Record.money(amount.to_s)
          handed = handed_amount.present? ? Record.money(handed_amount.to_s) : kept
          payload = {
            'command' => ACTION, 'reservation_id' => reservation_id.to_s, 'kind' => kind.to_s,
            'amount' => kept&.to_s('F'), 'handed_amount' => handed&.to_s('F'),
            'reference' => reference.to_s.presence, 'receiving_account' => receiving_account.to_s.presence
          }.merge(ReceiptReferenceGuard.payload_flag(confirm_duplicate))
          reservation = Guard.reservation!(store, reservation_id)
          branch = reservation.branch
          # Taking money is a cashier's job (pos.payment.collect).
          authorize = lambda do
            raise CanCan::AccessDenied if branch.disabled?
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::PAYMENT)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            ModulePolicy.require!(branch, Guard::MODULE)
            currency = store.default_currency
            money = Collections::Receive.validate!(kind.to_s, kept, handed, currency, reference, receiving_account)
            shift = Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: staff.id)
            raise Conflict.new('Open your own shift before taking a deposit.', reason: 'shift_required') if shift.nil?

            ShiftBarrier.hold!(shift)
            reservation.lock!
            unless %w[booked seated].include?(reservation.status)
              raise Conflict.new('This booking is no longer open.', reason: 'reservation_not_booked', details: { status: reservation.status })
            end

            duplicate_ids = if kind.to_s == 'bank_manual'
                              ReceiptReferenceGuard.check!(store: store, staff: staff, branch: branch, reference: reference,
                                                           receiving_account: receiving_account, confirm_duplicate: confirm_duplicate)
                            else
                              []
                            end
            funds = ReceivedFunds.create!(
              store: store, branch: branch, register: shift.register, shift: shift, actor: staff, kind: kind.to_s,
              status: 'received', handed_amount: money[:handed], applied_amount: kept, change_amount: money[:change],
              received_net: kept, currency: currency, reference: reference.presence,
              receiving_account: receiving_account.presence, custody: 'drawer', received_at: Time.current
            )
            if kind.to_s == 'cash'
              CashMovement.create!(store: store, branch: branch, register: shift.register, shift: shift, received_funds: funds,
                                   actor: staff, kind: 'receipt', amount: kept, currency: currency,
                                   source_type: funds.class.name, source_id: funds.id)
            end
            ReceiptReferenceGuard.audit!(store: store, staff: staff, funds: funds, duplicate_ids: duplicate_ids)
            deposit = reservation.deposits.create!(received_funds: funds, amount: kept, currency: currency, status: 'held', actor: staff)
            reservation.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: reservation,
                               metadata: { deposit_id: deposit.prefixed_id, funds_id: funds.prefixed_id, amount: kept.to_s('F'),
                                           kind: kind.to_s, change: money[:change].to_s('F') })
            OutboxEntry.record!(store: store, event_type: 'reservation.deposit_taken', aggregate: deposit,
                                payload: { 'deposit_id' => deposit.prefixed_id, 'funds_id' => funds.prefixed_id })
            reservation.reload.to_pos
          end
        end
      end
    end
  end
end
