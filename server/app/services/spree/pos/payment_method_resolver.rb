# frozen_string_literal: true

module Spree
  module Pos
    # Resolves POS tender methods from the store's Admin payment-method
    # configuration. Cash always exists; bank_manual follows an active core
    # payment method, with a POS-specific mapping when one is configured.
    # VietQR is offered when the store has an active VietQR payment method
    # with a receiving account (set up in the dashboard) and the branch has
    # the `vietqr` feature on.
    class PaymentMethodResolver
      CASH_CODE = 'cash'
      BANK_CODE = 'bank_transfer'
      VIETQR_CODE = 'vietqr'
      VIETQR_TYPE = 'Spree::PaymentMethod::Vietqr'

      def initialize(store:)
        @store = store
      end

      # Every active configured row, plus a built-in cash or bank row for a
      # kind the store has never configured (a disabled row of that kind
      # turns the built-in one off too). With a branch, only the methods
      # it offers (see #offered_at?).
      def available(branch: nil)
        rows = PosPaymentMethod.for_store(store).order(:position, :id).to_a
        kinds = rows.map(&:kind).uniq
        result = rows.select { |row| row.status == 'active' && %w[cash bank_manual].include?(row.kind) }
        result << default_cash unless kinds.include?('cash')
        unless kinds.include?('bank_manual')
          core = core_bank_method
          result << (core ? transient_bank(core) : default_bank)
        end
        result.concat(vietqr_rows(rows, branch))
        result = result.select { |row| offered_at?(row, branch) } if branch
        result.sort_by { |row| [row.position, row.id || 0] }
      end

      # Returns [PosPaymentMethod row (persisted or transient), core method].
      # With a branch, a method the branch does not offer is refused.
      def resolve!(prefixed_id, branch: nil)
        if prefixed_id.to_s.start_with?('posmethod-')
          kind = prefixed_id.to_s.delete_prefix('posmethod-')
          candidate = available.find { |row| row.kind == kind }
          raise ActiveRecord::RecordNotFound if candidate.nil?

          return [offered!(candidate, branch), core_for(candidate)]
        end
        row = PosPaymentMethod.locate(PosPaymentMethod.for_store(store), prefixed_id) if prefixed_id.present?
        if row
          raise Conflict, 'Payment method is disabled.' unless row.status == 'active'

          return [offered!(row, branch), core_for(row)]
        end
        available.each do |candidate|
          next unless candidate.prefixed_id == prefixed_id.to_s

          return [offered!(candidate, branch), core_for(candidate)]
        end
        raise ActiveRecord::RecordNotFound
      end

      # A branch without a selection offers every method; one with a
      # selection offers only the selected rows.
      def offered_at?(row, branch)
        selected = selected_ids(branch)
        selected.empty? || (row.id.present? && selected.include?(row.id))
      end

      # Saves the built-in rows the store currently gets, so they can be
      # renamed, ordered, disabled and chosen per branch. Returns every row.
      def materialize!
        available.each do |row|
          next if row.persisted?

          PosPaymentMethod.create!(store: store, code: row.code, name: row.name, kind: row.kind, status: 'active',
                                   position: row.position, payment_method_id: row.payment_method_id,
                                   payment_method_type: row.payment_method_type)
        rescue ActiveRecord::RecordNotUnique
          next
        end
        PosPaymentMethod.for_store(store).order(:position, :id).to_a
      end

      # The core method a row may settle on: a manual one for cash and bank
      # transfers, a VietQR one with a receiving account for VietQR.
      def core_choice(kind, prefixed_id)
        method = Spree::PaymentMethod.find_by_prefix_id(prefixed_id.to_s)
        return nil if method.nil?

        scope = kind == 'vietqr' ? vietqr_methods : manual_methods
        scope.find_by(id: method.id)
      end

      # POS money is attested by staff, so the core Payment must sit on a manual
      # method of this store: one that needs no card/gateway source. A gateway
      # method would make the completed Payment look like a captured charge.
      def core_for(row)
        return vietqr_for(row) if row.kind == 'vietqr'
        return manual_methods.find_by(id: row.payment_method_id) if row.payment_method_id

        case row.kind
        when 'cash'
          manual_methods.where('type ILIKE ?', '%Check%').first
        when 'bank_manual'
          core_bank_method || manual_methods.where('type ILIKE ?', '%Check%').first
        end
      end

      # The VietQR core method a vietqr row settles on; nil when it is gone or
      # has no receiving account left.
      def vietqr_for(row)
        scope = vietqr_methods
        row.payment_method_id ? scope.find_by(id: row.payment_method_id) : scope.first
      end

      private

      attr_reader :store

      # Staff-attested methods only: VietQR is confirmed by the bank, so it is
      # never the fallback for cash or a manual transfer.
      def manual_methods
        ids = Spree::PaymentMethod.where(store_id: store.id, active: true, deleted_at: nil).where.not(type: VIETQR_TYPE).
              select { |method| manual?(method) }.map(&:id)
        Spree::PaymentMethod.where(id: ids).order(:position, :id)
      end

      def vietqr_methods
        return Spree::PaymentMethod.none unless defined?(Spree::PaymentMethod::Vietqr)

        Spree::PaymentMethod::Vietqr.where(store_id: store.id, active: true, deleted_at: nil).
          where(id: SpreeVietqr::ReceivingAccount.active.select(:payment_method_id)).order(:position, :id)
      end

      def vietqr_rows(rows, branch)
        return [] if branch && !FeaturePolicy.enabled?(branch, :vietqr)

        mapped = rows.select { |row| row.kind == 'vietqr' }
        return mapped.select { |row| row.status == 'active' && vietqr_for(row) } if mapped.any?

        core = vietqr_methods.first
        return [] if core.nil?

        [PosPaymentMethod.new(store: store, code: VIETQR_CODE, name: core.name.presence || 'VietQR', kind: 'vietqr',
                              status: 'active', position: 2, payment_method_id: core.id, payment_method_type: core.type)]
      end

      def selected_ids(branch)
        return [] if branch.nil?

        @selected_ids ||= {}
        @selected_ids[branch.id] ||= BranchPaymentMethod.where(branch_id: branch.id).pluck(:pos_payment_method_id)
      end

      def offered!(row, branch)
        return row if branch.nil? || offered_at?(row, branch)

        raise Conflict.new('This branch does not offer this payment method.', reason: 'payment_method_not_offered')
      end

      def manual?(method)
        !method.source_required?
      rescue NotImplementedError
        false
      end

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
        scope = manual_methods
        scope.where('name ILIKE ? OR type ILIKE ?', '%bank%', '%bank%').
          or(scope.where('name ILIKE ? OR type ILIKE ?', '%transfer%', '%transfer%')).
          order(:position, :id).first
      end
    end
  end
end
