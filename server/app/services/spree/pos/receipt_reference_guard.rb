# frozen_string_literal: true

module Spree
  module Pos
    # A bank receipt whose reference and receiving account already belong to
    # another ReceivedFunds of the store is probably the same transfer recorded
    # twice. It is refused unless a resolver confirms it on purpose; that
    # confirmation is audited against the new receipt.
    module ReceiptReferenceGuard
      module_function

      def duplicates(store:, reference:, receiving_account:)
        return ReceivedFunds.none if reference.blank? || receiving_account.blank?

        ReceivedFunds.for_store(store).where(kind: 'bank_manual').
          where('LOWER(TRIM(reference)) = ? AND LOWER(TRIM(receiving_account)) = ?',
                reference.to_s.strip.downcase, receiving_account.to_s.strip.downcase)
      end

      # Idempotency payload part: present only when the caller confirms, so
      # commands without it keep their earlier digest.
      def payload_flag(confirm_duplicate)
        ActiveModel::Type::Boolean.new.cast(confirm_duplicate) ? { 'confirm_duplicate' => true } : {}
      end

      # Returns the prefixed ids of the earlier receipts the caller confirmed.
      def check!(store:, staff:, branch:, reference:, receiving_account:, confirm_duplicate:)
        ids = duplicates(store: store, reference: reference, receiving_account: receiving_account).order(:id).map(&:prefixed_id)
        return [] if ids.empty?

        confirmed = ActiveModel::Type::Boolean.new.cast(confirm_duplicate) &&
          AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::RESOLVE)
        raise Conflict.new('This bank reference was already recorded.', reason: 'duplicate_reference') unless confirmed

        ids
      end

      def audit!(store:, staff:, funds:, duplicate_ids:)
        return if duplicate_ids.empty?

        AuditEntry.record!(store: store, actor: staff, action: 'funds.duplicate_reference_confirmed', subject: funds,
                           metadata: { reference: funds.reference, duplicates: duplicate_ids })
      end
    end
  end
end
