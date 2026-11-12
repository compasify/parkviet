# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # The prices a quote reads, in a fixed number of queries: the branch's
      # active plans and the versions segments were played on (with their
      # rules), its holidays around the time played, and on first use its
      # timed promotions and the minutes cards of its sessions.
      class RateBook
        attr_reader :special_days

        def initialize(branch, plan_ids: [], from: nil, to: nil)
          @branch = branch
          plans = RatePlan.where(branch_id: branch.id, status: 'active').or(RatePlan.where(id: plan_ids.uniq)).
                  includes(:rate_rules).to_a
          @plans = plans.index_by(&:id)
          @active = plans.select(&:active?).index_by(&:resource_type_code)
          zone = ActiveSupport::TimeZone[branch.timezone.to_s] || Time.zone
          first = (from || Time.current).in_time_zone(zone).to_date - 1
          last = (to || Time.current).in_time_zone(zone).to_date + 1
          @special_days = SpecialDay.where(branch_id: branch.id, date: first..last).index_by(&:date)
        end

        def plan(id)
          @plans[id]
        end

        # The branch's active timed promotions, read once.
        def promotions
          @promotions ||= TimedPromotion.active.where(branch_id: @branch.id).order(:id).to_a
        end

        # The lots of a minutes card as its ledger has them, one query per
        # card, read once. Only for quotes: stopping
        # reads them under the card's lock (StoredValue.lots).
        def card_lots(account_id)
          @card_lots ||= {}
          @card_lots.fetch(account_id) do
            rows = StoredValueEntry.where(stored_value_account_id: account_id).where.not(received_funds_id: nil).
                   group(:received_funds_id).order(:received_funds_id).pluck(:received_funds_id, Arel.sql('SUM(amount)'), Arel.sql('SUM(minutes)'))
            @card_lots[account_id] = rows.filter_map do |funds_id, money, minutes|
              next unless minutes.to_i.positive?

              StoredValue::Lot.new(funds: funds_id, minutes: minutes.to_i, money: BigDecimal(money.to_s))
            end
          end
        end

        def current_plan(resource)
          @active[RatePlan.type_code_of(resource)]
        end
      end
    end
  end
end
