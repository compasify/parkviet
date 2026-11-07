# frozen_string_literal: true

module Spree
  module Pos
    # First-expired-first-out lot choice for a base quantity at one stock
    # location. Only active lots that are not expired at the branch's date are
    # candidates; lots without an expiry go last; ties go to the earlier
    # receipt (lot id). Callers that write hold the candidate lot rows locked
    # (`lock: true`, in id order) so two counters cannot both take the last
    # units.
    class FefoAllocator
      Pick = Struct.new(:lot, :quantity, keyword_init: true)

      def self.candidates(variant, stock_location, today, lock: false)
        scope = InventoryLot.where(variant_id: variant.id, stock_location_id: stock_location.id, status: 'active').
                where('expiry_on IS NULL OR expiry_on >= ?', today)
        lots = lock ? scope.order(:id).lock.to_a : scope.to_a
        lots.sort_by { |lot| [lot.expiry_on ? 0 : 1, lot.expiry_on || Date.new(9999, 12, 31), lot.id] }
      end

      # Returns the picks covering `quantity`, or raises `trace_insufficient`.
      # `lot` restricts the choice to one lot the cashier picked.
      def self.call(variant:, stock_location:, quantity:, today:, workspace_id: nil, lock: false, lot: nil, now: Workspace.database_now)
        lots = candidates(variant, stock_location, today, lock: lock)
        if lot
          lots = lots.select { |candidate| candidate.id == lot.id }
          raise Conflict.new('The chosen lot cannot be sold (expired, quarantined or another location).', reason: 'trace_lot_invalid') if lots.empty?
        end
        left = quantity
        picks = []
        lots.each do |candidate|
          break if left.zero?

          free = candidate.available(now, except_workspace_id: workspace_id)
          next unless free.positive?

          take = [free, left].min
          picks << Pick.new(lot: candidate, quantity: take)
          left -= take
        end
        if left.positive?
          raise Conflict.new("Only #{quantity - left} of #{quantity} units are available in sellable lots.", reason: 'trace_insufficient')
        end

        picks
      end
    end
  end
end
