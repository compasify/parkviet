# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # The price of a session's play time up to `now`, without writing
      # anything. Each play segment is cut at every midnight and every time
      # band of the branch's time zone and priced by its kind of day:
      # a holiday of the branch (the plan's holiday rules, or its weekend
      # rules plus the day's surcharge), a weekend day of the branch, or a
      # weekday. A closed segment is priced on the plan version it was
      # played on; the open one on the room's current plan.
      #
      # Rounding is on the session's total, never per piece:
      # - minutes played are the whole minutes of all play time together,
      #   each piece getting the minutes its seconds complete;
      # - a remainder up to the grace minutes is dropped, a longer one goes
      #   up to the next block; then the minimum applies (all by the last
      #   segment's plan);
      # - the minutes rounding adds or drops are priced at the last piece.
      # Each line's amount is its minutes at the hourly price (plus the
      # surcharge), rounded to the currency; the total is the lines' sum.
      #
      # Then, on the billed minutes in play order:
      # - a prepaid package covers its first minutes at the package price
      #   (billed at least the package, even when played less);
      # - a promotion's free minutes come off the end, at no price;
      # - a minutes card pays the next minutes after the package at the
      #   card's own price per minute, as far as it has minutes;
      # - the rest is priced by the rate plan as above.
      # Package, card and bonus each read as one line of their own.
      class Quote
        Piece = Struct.new(:segment, :starts_at, :ends_at, :day_type, :rule, :price_per_hour, :surcharge_percent, :seconds,
                           :minutes, keyword_init: true)
        Line = Data.define(:segment, :starts_at, :ends_at, :day_type, :rule_id, :label, :price_per_hour, :surcharge_percent,
                           :minutes, :amount, :kind, :promotion) do
          def initialize(kind: 'rate', promotion: nil, **)
            super
          end

          def to_pos
            { segment_id: segment.prefixed_id, starts_at: starts_at.iso8601, ends_at: ends_at.iso8601, day_type: day_type,
              label: label, price_per_hour: price_per_hour.to_s('F'), surcharge_percent: surcharge_percent.to_s('F'),
              minutes: minutes, amount: amount.to_s('F'), kind: kind, promotion_id: promotion&.prefixed_id }
          end
        end
        Result = Data.define(:lines, :played_minutes, :billed_minutes, :amount, :currency, :as_of, :rate_plan, :card_minutes) do
          def initialize(card_minutes: 0, **)
            super
          end

          def to_pos
            { as_of: as_of.iso8601, final: false, played_minutes: played_minutes, billed_minutes: billed_minutes,
              card_minutes: card_minutes, amount: amount.to_s('F'), lines: lines.map(&:to_pos) }
          end
        end
        # A prepaid package as sold: its minutes and price.
        Package = Data.define(:name, :minutes, :price)
        # A play segment as the quote reads it: when it ran and on which plan.
        Stretch = Data.define(:segment, :starts_at, :ends_at, :plan)

        # Reads the plans and holidays the session needs (RateBook) and prices
        # it. `card_lots` are the minutes card's lots when the caller holds
        # them locked (stopping); otherwise the book reads them.
        def self.call(session, now:, book: nil, card_lots: nil)
          segments = session.timed_segments.to_a
          book ||= RateBook.new(session.branch, plan_ids: segments.map(&:rate_plan_id).compact,
                                                from: session.started_at, to: now)
          stretches = segments.select(&:play?).filter_map do |segment|
            ends_at = segment.ended_at || now
            next if ends_at < segment.started_at

            plan = segment.open? ? (book.current_plan(segment.resource) || book.plan(segment.rate_plan_id)) : book.plan(segment.rate_plan_id)
            raise Conflict.new('This room has no rate plan.', reason: 'rate_plan_missing') if plan.nil?

            Stretch.new(segment: segment, starts_at: segment.started_at, ends_at: ends_at, plan: plan)
          end
          package = session.package? ? Package.new(name: session.package_name, minutes: session.prepaid_minutes, price: session.package_price) : nil
          lots = card_lots || (session.stored_value_account_id && book.card_lots(session.stored_value_account_id))
          promotions = book.promotions.select do |promotion|
            promotion.applies?(session.resource, session.started_at, session.branch.timezone, package: package.present?)
          end
          compute(stretches: stretches, timezone: session.branch.timezone, weekend_days: session.branch.weekend_days,
                  special_days: book.special_days, currency: session.currency, as_of: now, package: package, card_lots: lots,
                  promotions: promotions)
        end

        # The pure pricing: stretches (segment, start, end, plan) in, priced lines out.
        # `special_days` maps a Date to its SpecialDay.
        def self.compute(stretches:, timezone:, weekend_days:, special_days:, currency:, as_of:, package: nil, card_lots: nil,
                         promotions: [])
          zone = ActiveSupport::TimeZone[timezone.to_s] || Time.zone
          weekend = Array(weekend_days).map(&:to_i)
          ordered = stretches.sort_by { |row| [row.starts_at, row.segment.id.to_i] }
          pieces = ordered.flat_map { |stretch| cut(stretch, zone, weekend, special_days) }
          if pieces.empty? && ordered.any?
            first = ordered.first
            pieces = [piece_at(first, first.starts_at, first.starts_at, zone, weekend, special_days)]
          end
          return Result.new(lines: [], played_minutes: 0, billed_minutes: 0, amount: BigDecimal('0'), currency: currency, as_of: as_of, rate_plan: nil) if pieces.empty?

          assign_minutes!(pieces)
          played = pieces.sum(&:minutes)
          plan = ordered.last.plan
          billed = round_minutes(played, plan)
          billed = [billed, package.minutes].max if package
          adjust!(pieces, billed - played)
          prepaid = package ? package.minutes : 0
          promotion = promotions.max_by { |row| [row.bonus_for(billed, prepaid), -row.id.to_i] }
          bonus = promotion ? promotion.bonus_for(billed, prepaid) : 0
          promotion = nil if bonus.zero?
          takes, card = card_lots ? StoredValue.minutes_cost(card_lots, billed - prepaid - bonus, currency) : [[], 0]
          parts = carve(pieces, [['package', prepaid], ['card', card], ['rate', billed - prepaid - card - bonus], ['bonus', bonus]])
          lines = []
          lines << whole_line(parts['package'], 'package', package.price, package.name) if package && parts['package'].any?
          lines << whole_line(parts['card'], 'card', takes.sum(BigDecimal('0'), &:amount), nil) if parts['card'].any?
          lines.concat(merge(parts['rate']).select { |row| row.minutes.positive? }.map { |row| line(row, currency) })
          lines << whole_line(parts['bonus'], 'bonus', BigDecimal('0'), nil, promotion: promotion) if parts['bonus'].any?
          Result.new(lines: lines, played_minutes: played, billed_minutes: billed, amount: lines.sum(BigDecimal('0'), &:amount),
                     currency: currency, as_of: as_of, rate_plan: plan, card_minutes: card)
        end

        # Splits the pieces' minutes, in play order, into the budget of each
        # kind of line: { kind => [pieces] }, a piece cut at the minute where
        # a budget ends (its time shared out by those minutes).
        def self.carve(pieces, budgets)
          parts = budgets.to_h { |kind, _| [kind, []] }
          queue = budgets.map(&:dup).reject { |_, minutes| minutes <= 0 }
          pieces.each do |piece|
            left = piece.minutes
            at = piece.starts_at
            span = piece.ends_at - piece.starts_at
            while left.positive? && queue.any?
              kind, budget = queue.first
              take = [left, budget].min
              ends = take == left ? piece.ends_at : [at + (span * take / piece.minutes), piece.ends_at].min
              parts[kind] << piece.dup.tap do |row|
                row.minutes = take
                row.starts_at = at
                row.ends_at = ends
              end
              at = ends
              left -= take
              queue.first[1] -= take
              queue.shift if queue.first[1].zero?
            end
          end
          parts
        end

        # One line for all minutes of a package, a card or a bonus.
        def self.whole_line(rows, kind, amount, label, promotion: nil)
          minutes = rows.sum(&:minutes)
          first = rows.first
          price = minutes.zero? ? BigDecimal('0') : (amount * 60 / minutes).round(4)
          Line.new(segment: first.segment, starts_at: first.starts_at, ends_at: rows.last.ends_at, day_type: first.day_type,
                   rule_id: nil, label: label.to_s.first(40).presence, price_per_hour: price, surcharge_percent: BigDecimal('0'),
                   minutes: minutes, amount: amount, kind: kind, promotion: promotion)
        end

        # For example 62 minutes, block 15, grace 5 -> 60; 66 -> 75; then the minimum.
        def self.round_minutes(played, plan)
          block = plan.block_minutes
          whole, rest = played.divmod(block)
          rounded = rest <= plan.grace_minutes ? whole * block : (whole + 1) * block
          [rounded, plan.minimum_minutes.to_i].max
        end

        # Cuts one stretch at every midnight and band edge of the branch's time zone.
        def self.cut(stretch, zone, weekend, special_days)
          pieces = []
          at = stretch.starts_at
          while at < stretch.ends_at
            piece = piece_at(stretch, at, stretch.ends_at, zone, weekend, special_days)
            pieces << piece
            at = piece.ends_at
          end
          pieces
        end

        def self.piece_at(stretch, at, limit, zone, weekend, special_days)
          local = at.in_time_zone(zone)
          day_start = local.beginning_of_day
          minute = ((local - day_start) / 60).floor
          day_type, rules, surcharge = day_rules(stretch.plan, local.to_date, local.wday, weekend, special_days)
          rule = rules.detect { |row| row.covers?(minute) }
          raise Conflict.new('The rate plan does not price this time.', reason: 'rate_plan_gap') if rule.nil?

          next_midnight = (local.to_date + 1).in_time_zone(zone)
          band_end = rule.end_minute > minute ? day_start + rule.end_minute.minutes : next_midnight
          ends_at = [limit, band_end, next_midnight].min
          Piece.new(segment: stretch.segment, starts_at: at, ends_at: ends_at, day_type: day_type, rule: rule,
                    price_per_hour: BigDecimal(rule.price_per_hour.to_s), surcharge_percent: surcharge,
                    seconds: ends_at.to_r - at.to_r, minutes: 0)
        end

        # [kind of day, its rules, surcharge percent]
        def self.day_rules(plan, date, wday, weekend, special_days)
          rules = plan.rate_rules.to_a
          special = special_days[date]
          if special
            holiday = rules.select { |row| row.day_type == 'holiday' }
            return ['holiday', holiday, BigDecimal('0')] if holiday.any?

            return ['holiday', rules.select { |row| row.day_type == 'weekend' }, BigDecimal((special.holiday_surcharge_percent || 0).to_s)]
          end
          type = weekend.include?(wday) ? 'weekend' : 'weekday'
          [type, rules.select { |row| row.day_type == type }, BigDecimal('0')]
        end

        # Each piece gets the whole minutes its seconds complete, counted
        # over the session, so the pieces add up to the minutes played.
        def self.assign_minutes!(pieces)
          total = Rational(0)
          pieces.each do |piece|
            before = (total / 60).floor
            total += piece.seconds
            piece.minutes = (total / 60).floor - before
          end
        end

        # Minutes rounding adds go on the last piece; minutes it drops come
        # off the last pieces first.
        def self.adjust!(pieces, delta)
          if delta >= 0
            pieces.last.minutes += delta
            return
          end
          left = -delta
          pieces.reverse_each do |piece|
            take = [piece.minutes, left].min
            piece.minutes -= take
            left -= take
            break if left.zero?
          end
        end

        # Neighbouring pieces of one segment at the same price read as one line.
        def self.merge(pieces)
          pieces.each_with_object([]) do |piece, rows|
            last = rows.last
            if last && last.segment.equal?(piece.segment) && last.rule.equal?(piece.rule) && last.day_type == piece.day_type &&
               last.surcharge_percent == piece.surcharge_percent && last.ends_at == piece.starts_at
              last.ends_at = piece.ends_at
              last.minutes += piece.minutes
              last.seconds += piece.seconds
            else
              rows << piece.dup
            end
          end
        end

        def self.line(piece, currency)
          raw = BigDecimal(piece.minutes) * piece.price_per_hour / 60 * (1 + (piece.surcharge_percent / 100))
          Line.new(segment: piece.segment, starts_at: piece.starts_at, ends_at: piece.ends_at, day_type: piece.day_type,
                   rule_id: piece.rule.id, label: piece.rule.label, price_per_hour: piece.price_per_hour,
                   surcharge_percent: piece.surcharge_percent, minutes: piece.minutes, amount: money(raw, currency))
        end

        def self.money(value, currency)
          BigDecimal(Spree::Money::Rounding.to_currency(value, currency).to_s)
        end
      end
    end
  end
end
