# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Money actually received (ReceivedFunds) by when it arrived. Booked
      # time is separate: late evidence keeps its actual received time and is
      # booked when attested. Sale tenders, debt collections and unsolicited
      # receipts are kept apart; held cash is shown but is not drawer cash.
      class Receipts < Base
        ENUMS = { 'kind' => ReceivedFunds::KINDS, 'source' => %w[sale collection unsolicited] }.freeze
        COLUMNS = %w[funds_id received_at booked_at kind source custody status received_net handed_amount change_amount
                     currency order_number reference shift_id register cashier].freeze

        def relation
          base.order(received_at: :desc, id: :desc)
        end

        def rows(records)
          ActiveRecord::Associations::Preloader.new(
            records: records, associations: [:register, :shift, :actor, :collection, { workspace: :order }]
          ).call
          records.map do |funds|
            { funds_id: funds.prefixed_id, received_at: local(funds.received_at), booked_at: local(funds.created_at),
              kind: funds.kind, source: source_of(funds), custody: funds.custody, status: funds.status,
              received_net: money(funds.received_net), handed_amount: money(funds.handed_amount),
              change_amount: money(funds.change_amount), currency: funds.currency,
              order_number: funds.workspace&.order&.number, reference: funds.reference,
              shift_id: funds.shift.prefixed_id, register: funds.register&.code, cashier: StaffName.call(funds.actor) }
          end
        end

        def summary
          totals = { 'total' => base.sum(:received_net) }
          base.group(:kind).sum(:received_net).each { |kind, sum| totals[kind] = sum }
          totals['sale'] = base.where.not(tender_attempt_id: nil).sum(:received_net)
          totals['collection'] = base.where(id: Collection.select(:received_funds_id)).sum(:received_net)
          totals['unsolicited'] = totals['total'] - totals['sale'] - totals['collection']
          totals['held'] = base.where(custody: 'held').sum(:received_net)
          totals.transform_values { |value| money(value) }.merge('count' => base.count)
        end

        private

        def base
          relation = ReceivedFunds.where(branch_id: branch.id).where(shift_id: scope.shifts.select(:id))
          # Blind count: no cash totals of one's own uncounted open shift.
          relation = relation.where.not(kind: 'cash', shift_id: scope.blind_shift_ids) unless scope.full?
          relation = relation.where(register_id: filters.register.id) if filters.register
          relation = relation.where(shift_id: filters.shift.id) if filters.shift
          relation = relation.where(actor_id: filters.cashier.id) if filters.cashier
          relation = relation.where(kind: filters['kind']) if filters['kind']
          relation = by_source(relation, filters['source']) if filters['source']
          within_range(relation, 'spree_pos_received_funds.received_at')
        end

        def by_source(relation, source)
          collections = Collection.select(:received_funds_id)
          case source
          when 'sale' then relation.where.not(tender_attempt_id: nil)
          when 'collection' then relation.where(id: collections)
          else relation.where(tender_attempt_id: nil).where.not(id: collections)
          end
        end

        def source_of(funds)
          if funds.tender_attempt_id then 'sale'
          elsif funds.collection then 'collection'
          else
            'unsolicited'
          end
        end
      end
    end
  end
end
