# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # The prices a quote reads, in a fixed number of queries: the branch's
      # active plans and the versions segments were played on (with their
      # rules), and its holidays around the time played.
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

        def current_plan(resource)
          @active[RatePlan.type_code_of(resource)]
        end
      end
    end
  end
end
