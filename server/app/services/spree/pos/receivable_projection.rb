# frozen_string_literal: true

module Spree
  module Pos
    # Receivable view built only from the immutable ledger:
    #   balance = debt - credit_notes - collected + reversed
    # It never reads core `amount_due` or `payment_status`, which describe
    # payments, not what a customer still owes after returns.
    class ReceivableProjection
      AGING = [['current', nil, 0], ['days_1_30', 1, 30], ['days_31_60', 31, 60], ['days_61_90', 61, 90],
               ['days_over_90', 91, nil]].freeze

      def initialize(scope, today:)
        @scope = scope
        @today = today
      end

      attr_reader :today

      # One row per credit-sale order. `status` filters server-side:
      # open (balance > 0), overdue (open and past due), settled, all.
      def order_rows(status: 'open')
        table = ReceivableEntry.arel_table.name
        signed = ReceivableEntry::SIGNED_SQL
        relation = scope.group("#{table}.order_id", "#{table}.credit_account_id", "#{table}.branch_id", "#{table}.workspace_id").
                   select("#{table}.order_id", "#{table}.credit_account_id", "#{table}.branch_id", "#{table}.workspace_id",
                          sum_kind('debit', 'debt'), sum_kind('credit_note', 'credit_notes'),
                          sum_kind('collection', 'collected'), sum_kind('collection_reversal', 'reversed'),
                          "SUM(#{signed}) AS balance", "MAX(#{table}.due_on) AS due_on")
        case status.to_s
        when 'open' then relation.having("SUM(#{signed}) > 0")
        when 'overdue' then relation.having("SUM(#{signed}) > 0 AND MAX(#{table}.due_on) < ?", today)
        when 'settled' then relation.having("SUM(#{signed}) <= 0")
        else relation
        end
      end

      def summary(rows)
        totals = Hash.new { |hash, key| hash[key] = BigDecimal('0') }
        rows.each do |row|
          balance = BigDecimal(row.balance.to_s)
          totals['balance'] += balance
          totals['overdue'] += balance if overdue?(row)
          totals[bucket(row)] += balance
        end
        AGING.map(&:first).push('balance', 'overdue').index_with { |key| totals[key].to_s('F') }
      end

      def overdue?(row)
        BigDecimal(row.balance.to_s).positive? && row.due_on.present? && row.due_on < today
      end

      def days_overdue(row)
        overdue?(row) ? (today - row.due_on).to_i : 0
      end

      def bucket(row)
        days = days_overdue(row)
        AGING.find { |(_, from, to)| (from.nil? || days >= from) && (to.nil? || days <= to) }.first
      end

      # `lookups` holds rows preloaded by id: orders, accounts, workspaces, and
      # per-order sums of sale receipts and refunds of collected payments.
      def serialize(row, lookups, mask:)
        order = lookups[:orders].fetch(row.order_id)
        account = lookups[:accounts].fetch(row.credit_account_id)
        collected = BigDecimal(row.collected.to_s) - BigDecimal(row.reversed.to_s)
        {
          order_id: order.prefixed_id, order_number: order.number,
          workspace_id: lookups[:workspaces].fetch(row.workspace_id).prefixed_id,
          credit_account_id: account.prefixed_id, customer: customer(account.customer_profile, mask),
          currency: account.currency, original_total: money(order.total), paid_at_sale: money(lookups[:sale_receipts][order.id]),
          debt: money(row.debt), credit_notes: money(row.credit_notes), collected: money(collected),
          refunds: money(lookups[:refunds][order.id]), balance: money(row.balance), due_on: row.due_on&.iso8601,
          overdue: overdue?(row), days_overdue: days_overdue(row), aging: bucket(row),
          placed_at: order.completed_at&.iso8601
        }
      end

      def self.customer(profile, mask)
        { id: profile.prefixed_id, name: profile.name, phone: mask ? masked(profile.phone) : profile.phone }
      end

      def self.masked(phone)
        return if phone.blank?

        visible = phone.to_s[-3..] || phone.to_s
        ('•' * [phone.to_s.length - visible.length, 0].max) + visible
      end

      private

      attr_reader :scope

      def customer(profile, mask) = self.class.customer(profile, mask)

      def sum_kind(kind, name)
        "COALESCE(SUM(CASE WHEN spree_pos_receivable_entries.kind = '#{kind}' THEN spree_pos_receivable_entries.amount END), 0) AS #{name}"
      end

      def money(value)
        BigDecimal((value || 0).to_s).to_s('F')
      end
    end
  end
end
