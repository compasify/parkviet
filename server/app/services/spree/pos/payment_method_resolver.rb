# frozen_string_literal: true

module Spree
  module Pos
    # Resolves POS tender methods from the store's Admin payment-method
    # configuration. Cash always exists; bank_manual follows an active core
    # payment method, with a POS-specific mapping when one is configured.
    class PaymentMethodResolver
      CASH_CODE = 'cash'
      BANK_CODE = 'bank_transfer'

      def initialize(store:)
        @store = store
      end

      def available(branch: nil)
        rows = PosPaymentMethod.for_store(store).active_now.to_a
        result = []
        cash = rows.find { |row| row.kind == 'cash' } || default_cash
        result << cash if cash
        mapped_bank = rows.find { |row| row.kind == 'bank_manual' }
        result << mapped_bank if mapped_bank
        if mapped_bank.nil?
          core = core_bank_method
          result << (core ? transient_bank(core) : default_bank)
        end
        result.sort_by { |row| [row.position, row.id || 0] }
      end

      # Returns [PosPaymentMethod row (persisted or transient), core method].
      def resolve!(prefixed_id)
        if prefixed_id.to_s.start_with?('posmethod-')
          kind = prefixed_id.to_s.delete_prefix('posmethod-')
          candidate = available.find { |row| row.kind == kind }
          raise ActiveRecord::RecordNotFound if candidate.nil?

          return [candidate, core_for(candidate)]
        end
        row = PosPaymentMethod.locate(PosPaymentMethod.for_store(store), prefixed_id) if prefixed_id.present?
        if row
          raise Conflict, 'Payment method is disabled.' unless row.status == 'active'

          return [row, core_for(row)]
        end
        available.each do |candidate|
          next unless candidate.prefixed_id == prefixed_id.to_s

          return [candidate, core_for(candidate)]
        end
        raise ActiveRecord::RecordNotFound
      end

      def core_for(row)
        return Spree::PaymentMethod.find_by(id: row.payment_method_id) if row.payment_method_id

        case row.kind
        when 'cash'
          Spree::PaymentMethod.where(store_id: store.id, active: true, deleted_at: nil)
                              .where('type ILIKE ?', '%Check%').order(:position, :id).first ||
            Spree::PaymentMethod.where(store_id: store.id, active: true, deleted_at: nil).order(:position, :id).first
        when 'bank_manual'
          core_bank_method ||
            Spree::PaymentMethod.where(store_id: store.id, active: true, deleted_at: nil)
                                .where('type ILIKE ?', '%Check%').order(:position, :id).first ||
            Spree::PaymentMethod.where(store_id: store.id, active: true, deleted_at: nil).order(:position, :id).first
        end
      end

      private

      attr_reader :store

      def default_cash
        PosPaymentMethod.new(store: store, code: CASH_CODE, name: 'Cash', kind: 'cash', status: 'active', position: 0)
      end

      def default_bank
        PosPaymentMethod.new(store: store, code: BANK_CODE, name: 'Bank transfer', kind: 'bank_manual', status: 'active', position: 1)
      end

      def transient_bank(core)
        PosPaymentMethod.new(store: store, code: BANK_CODE, name: core.name.presence || 'Bank transfer',
                             kind: 'bank_manual', status: 'active', position: 1, payment_method_id: core.id,
                             payment_method_type: core.type)
      end

      def core_bank_method
        scope = Spree::PaymentMethod.where(store_id: store.id, active: true, deleted_at: nil)
        scope.where('name ILIKE ? OR type ILIKE ?', '%bank%', '%bank%')
             .or(scope.where('name ILIKE ? OR type ILIKE ?', '%transfer%', '%transfer%'))
             .order(:position, :id).first
      end
    end
  end
end
