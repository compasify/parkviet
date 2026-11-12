# frozen_string_literal: true

# Pricing play time without the database: stretches of play cut at
# midnight and at band edges in the branch's time zone, priced by kind of
# day, rounded on the session's total and summed per line in whole dong.
RSpec.describe Spree::Pos::Timed::Quote do
  let(:zone) { ActiveSupport::TimeZone['Asia/Ho_Chi_Minh'] }

  # Weekdays: 100k an hour until 18:00, 150k after. Weekends: 200k all day.
  def weekday_weekend
    [
      { day_type: 'weekday', start_minute: 0, end_minute: 1080, price_per_hour: 100_000, label: 'Ngày' },
      { day_type: 'weekday', start_minute: 1080, end_minute: 1440, price_per_hour: 150_000, label: 'Tối' },
      { day_type: 'weekend', start_minute: 0, end_minute: 1440, price_per_hour: 200_000, label: 'Cuối tuần' }
    ]
  end

  def plan(block: 15, grace: 5, minimum: 0, rules: weekday_weekend)
    Spree::Pos::RatePlan.new(block_minutes: block, grace_minutes: grace, minimum_minutes: minimum).tap do |row|
      rules.each { |rule| row.rate_rules.build(rule) }
    end
  end

  def at(text) = zone.parse(text)

  def seg(id) = Struct.new(:id, :prefixed_id).new(id, "seg_#{id}")

  def stretch(from, to, on: plan, segment: seg(1))
    described_class::Stretch.new(segment: segment, starts_at: at(from), ends_at: at(to), plan: on)
  end

  def quote(*stretches, timezone: 'Asia/Ho_Chi_Minh', weekend: [6, 0], special: {})
    described_class.compute(stretches: stretches, timezone: timezone, weekend_days: weekend, special_days: special,
                            currency: 'VND', as_of: stretches.map(&:ends_at).max)
  end

  def holiday(date, surcharge: nil)
    { Date.iso8601(date) => Spree::Pos::SpecialDay.new(date: Date.iso8601(date), name: 'Lễ', holiday_surcharge_percent: surcharge) }
  end

  # 2026-11-12 is a Thursday; 14 and 15 are the weekend.
  cases = [
    { name: 'one hour in the day band', from: '2026-11-12 10:00', to: '2026-11-12 11:00', played: 60, billed: 60, amount: 100_000 },
    { name: 'two minutes over drop within grace', from: '2026-11-12 10:00', to: '2026-11-12 11:02', played: 62, billed: 60, amount: 100_000 },
    { name: 'exactly the grace drops', from: '2026-11-12 10:00', to: '2026-11-12 11:05', played: 65, billed: 60, amount: 100_000 },
    { name: 'past the grace rounds up a block', from: '2026-11-12 10:00', to: '2026-11-12 11:06', played: 66, billed: 75, amount: 125_000 },
    { name: 'a few minutes bill nothing', from: '2026-11-12 10:00', to: '2026-11-12 10:03', played: 3, billed: 0, amount: 0 },
    { name: 'seconds count toward the minute', from: '2026-11-12 10:00:30', to: '2026-11-12 11:00:20', played: 59, billed: 60, amount: 100_000 },
    { name: 'a band change splits the price', from: '2026-11-12 17:30', to: '2026-11-12 18:30', played: 60, billed: 60, amount: 125_000, lines: [30, 30] },
    { name: 'dropped minutes come off the last band', from: '2026-11-12 17:30', to: '2026-11-12 18:32', played: 62, billed: 60, amount: 125_000, lines: [30, 30] },
    { name: 'added minutes go on the last band', from: '2026-11-12 17:30', to: '2026-11-12 18:36', played: 66, billed: 75, amount: 162_500, lines: [30, 45] },
    { name: 'past midnight into a weekday morning', from: '2026-11-12 23:00', to: '2026-11-13 01:00', played: 120, billed: 120, amount: 250_000, lines: [60, 60] },
    { name: 'Friday night into Saturday', from: '2026-11-13 23:00', to: '2026-11-14 01:00', played: 120, billed: 120, amount: 350_000, days: %w[weekday weekend] },
    { name: 'a weekend afternoon', from: '2026-11-14 10:00', to: '2026-11-14 12:00', played: 120, billed: 120, amount: 400_000, days: %w[weekend] },
    { name: 'Sunday night into Monday', from: '2026-11-15 23:30', to: '2026-11-16 00:30', played: 60, billed: 60, amount: 150_000, days: %w[weekend weekday] },
    { name: 'a whole day across three bands', from: '2026-11-12 10:00', to: '2026-11-13 10:00', played: 1440, billed: 1440, amount: 2_700_000, lines: [480, 360, 600] },
    { name: 'a minimum lifts a short stay', from: '2026-11-12 10:00', to: '2026-11-12 10:20', played: 20, billed: 60, amount: 100_000, plan: { minimum: 60 } },
    { name: 'per-minute pricing rounds each line to the dong', from: '2026-11-12 10:00', to: '2026-11-12 11:01', played: 61, billed: 61, amount: 101_667, plan: { block: 1, grace: 0 } },
    { name: 'an hour block within its grace', from: '2026-11-12 10:00', to: '2026-11-12 11:10', played: 70, billed: 60, amount: 100_000, plan: { block: 60, grace: 10 } },
    { name: 'an hour block past its grace', from: '2026-11-12 10:00', to: '2026-11-12 11:11', played: 71, billed: 120, amount: 200_000, plan: { block: 60, grace: 10 } },
    { name: 'no time at all', from: '2026-11-12 10:00', to: '2026-11-12 10:00', played: 0, billed: 0, amount: 0, lines: [] },
    { name: 'a minute across a band edge rounds away', from: '2026-11-12 17:59:40', to: '2026-11-12 18:00:40', played: 1, billed: 0, amount: 0, lines: [] }
  ]

  cases.each do |row|
    it "prices #{row[:name]}" do
      result = quote(stretch(row[:from], row[:to], on: plan(**row.fetch(:plan, {}))))

      expect([result.played_minutes, result.billed_minutes, result.amount]).to eq([row[:played], row[:billed], BigDecimal(row[:amount].to_s)])
      expect(result.lines.map(&:minutes)).to eq(row[:lines]) if row.key?(:lines)
      expect(result.lines.map(&:day_type)).to eq(row[:days]) if row.key?(:days)
      expect(result.lines.sum(&:minutes)).to eq(result.billed_minutes)
      expect(result.lines.sum(BigDecimal('0'), &:amount)).to eq(result.amount)
    end
  end

  it 'prices a holiday at the weekend rules plus its surcharge' do
    result = quote(stretch('2026-11-12 10:00', '2026-11-12 11:00'), special: holiday('2026-11-12', surcharge: 20))

    expect(result.amount).to eq(240_000)
    expect(result.lines.map { |line| [line.day_type, line.surcharge_percent] }).to eq([['holiday', BigDecimal('20')]])
  end

  it 'rounds a surcharged line to the dong' do
    result = quote(stretch('2026-11-12 10:00', '2026-11-12 10:25'), special: holiday('2026-11-12', surcharge: 15))

    expect([result.billed_minutes, result.amount]).to eq([30, BigDecimal('115000')])
  end

  it 'prices a holiday by the plan holiday rules when it has them' do
    rules = weekday_weekend + [{ day_type: 'holiday', start_minute: 0, end_minute: 1440, price_per_hour: 300_000, label: 'Lễ' }]
    result = quote(stretch('2026-11-12 10:00', '2026-11-12 11:00', on: plan(rules: rules)), special: holiday('2026-11-12', surcharge: 50))

    expect(result.amount).to eq(300_000)
    expect(result.lines.first.surcharge_percent).to eq(0)
  end

  it 'reads the weekend from the branch days' do
    expect(quote(stretch('2026-11-14 10:00', '2026-11-14 11:00'), weekend: [0]).amount).to eq(100_000)
  end

  it 'cuts bands in the branch time zone' do
    evening = stretch('2026-11-12 18:30', '2026-11-12 19:30')

    expect(quote(evening).amount).to eq(150_000)
    # 18:30 in Ho Chi Minh City is 11:30 in UTC, still the day band there.
    expect(quote(evening, timezone: 'UTC').amount).to eq(100_000)
  end

  it 'prices each stretch on its own plan and rounds on the total' do
    vip = plan(rules: weekday_weekend.map { |rule| rule.merge(price_per_hour: rule[:price_per_hour] * 2) })
    first = stretch('2026-11-12 10:00', '2026-11-12 10:40', segment: seg(1))
    second = stretch('2026-11-12 10:40', '2026-11-12 11:20', on: vip, segment: seg(2))
    result = quote(first, second)

    # 80 minutes played, 5 over the block: within grace, dropped from the VIP room.
    expect([result.played_minutes, result.billed_minutes]).to eq([80, 75])
    expect(result.lines.map { |line| [line.minutes, line.amount] }).to eq([[40, BigDecimal('66667')], [35, BigDecimal('116667')]])
    expect(result.amount).to eq(183_334)
  end

  it 'reads a band past midnight as one line on the same kind of day' do
    rules = [
      { day_type: 'weekday', start_minute: 1080, end_minute: 360, price_per_hour: 150_000, label: 'Đêm' },
      { day_type: 'weekday', start_minute: 360, end_minute: 1080, price_per_hour: 100_000, label: 'Ngày' },
      { day_type: 'weekend', start_minute: 0, end_minute: 1440, price_per_hour: 200_000, label: 'Cuối tuần' }
    ]
    result = quote(stretch('2026-11-12 23:00', '2026-11-13 01:00', on: plan(rules: rules)))

    expect(result.lines.map { |line| [line.label, line.minutes] }).to eq([['Đêm', 120]])
    expect(result.amount).to eq(300_000)
  end

  it 'refuses a time no rule prices' do
    gap = plan(rules: [{ day_type: 'weekday', start_minute: 0, end_minute: 600, price_per_hour: 100_000 },
                       { day_type: 'weekend', start_minute: 0, end_minute: 1440, price_per_hour: 200_000 }])

    expect { quote(stretch('2026-11-12 10:00', '2026-11-12 11:00', on: gap)) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('rate_plan_gap') }
  end

  it 'rounds by the last stretch plan' do
    hourly = plan(block: 60, grace: 0)
    result = quote(stretch('2026-11-12 10:00', '2026-11-12 10:30', segment: seg(1)),
                   stretch('2026-11-12 10:30', '2026-11-12 10:50', on: hourly, segment: seg(2)))

    expect([result.played_minutes, result.billed_minutes]).to eq([50, 60])
    expect(result.lines.map(&:minutes)).to eq([30, 30])
  end

  describe '.round_minutes' do
    [[0, 0], [5, 0], [6, 15], [15, 15], [20, 15], [21, 30], [119, 120]].each do |played, billed|
      it "rounds #{played} minutes to #{billed}" do
        expect(described_class.round_minutes(played, plan)).to eq(billed)
      end
    end
  end
end
