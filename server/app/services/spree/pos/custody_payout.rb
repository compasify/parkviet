# frozen_string_literal: true

module Spree
  module Pos
    # Where a cash payout (liability payout or refund) physically comes from.
    #
    # Cash in a drawer is paid from the confirmer's open drawer and writes a
    # negative CashMovement there. Held cash (custody `held`, recorded without
    # a drawer movement) is not in any drawer unless a reconciliation put it
    # into one (`new_physical_inflow`) or into a later opening float
    # (`in_opening_float`), so paying it "from the drawer" would take money
    # out of a drawer that never received it. Such a payout is refused with
    # `held_custody` unless the confirmer says it is paid from custody, with a
    # custody reference: then it is a custody-only outflow (evidence only, no
    # drawer movement).
    module CustodyPayout
      SOURCES = %w[drawer custody].freeze
      IN_DRAWER = %w[new_physical_inflow in_opening_float].freeze

      module_function

      # True when the payout leaves a drawer; false for a custody-only outflow.
      def drawer?(funds, paid_from, reference)
        source = paid_from.to_s.presence || 'drawer'
        raise Conflict.new('Payout source is invalid.', reason: 'paid_from_invalid') unless SOURCES.include?(source)

        in_drawer = funds.custody == 'drawer' ||
          CashReconciliation.exists?(received_funds_id: funds.id, outcome: IN_DRAWER)
        if source == 'drawer'
          raise Conflict.new('This cash is held outside the drawer; pay it from custody.', reason: 'held_custody') unless in_drawer

          return true
        end
        raise Conflict.new('Drawer cash is paid from the drawer.', reason: 'not_held') if in_drawer
        raise Conflict.new('A custody payout needs the custody reference.', reason: 'evidence_required') if reference.to_s.strip.blank?

        false
      end

      def metadata(drawer)
        { 'paid_from' => drawer ? 'drawer' : 'custody' }
      end
    end
  end
end
