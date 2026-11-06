# frozen_string_literal: true

RSpec.describe Spree::Pos::DiscountCalculator do
  def calculate(bases:, value:, type:)
    described_class.call(bases: bases, value: value, value_type: type, currency: 'VND')
  end

  it 'recalculates percentages using the current post-promotion bases' do
    expect(calculate(bases: %w[100 100], value: '10', type: 'percent')).to eq([BigDecimal('10'), BigDecimal('10')])
    expect(calculate(bases: %w[200], value: '10', type: 'percent')).to eq([BigDecimal('20')])
  end

  it 'splits fixed VND using the core largest-remainder allocator without losing a dong' do
    shares = calculate(bases: %w[100 100 100], value: '10', type: 'flat')
    expect(shares).to eq([BigDecimal('4'), BigDecimal('3'), BigDecimal('3')])
    expect(shares.sum).to eq(10)
  end

  it 'uses Spree currency rounding for percentage totals before allocating whole VND' do
    bases = %w[5 5]
    shares = calculate(bases: bases, value: '5', type: 'percent')
    expected = Spree::Money::Rounding.to_currency(BigDecimal('0.5'), 'VND')
    expect(shares.sum).to eq(expected)
    expect(shares).to all(satisfy { |share| share.frac.zero? })
  end

  it 'rejects a fixed discount larger than its current eligible base instead of clamping' do
    expect { calculate(bases: %w[50 20], value: '71', type: 'flat') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
  end

  it 'keeps zero-base lines at zero and never discounts beyond a line base' do
    expect(calculate(bases: %w[0 2 1], value: '3', type: 'flat')).to eq([0, 2, 1])
    expect(calculate(bases: %w[0 100], value: '100', type: 'percent')).to eq([0, 100])
    expect(calculate(bases: %w[0 0], value: '10', type: 'percent')).to eq([0, 0])
    expect(calculate(bases: [], value: '10', type: 'percent')).to eq([])
    expect { calculate(bases: [], value: '10', type: 'flat') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
  end

  it 'rejects malformed or unrepresentable values instead of coercing or rounding them' do
    %w[-1 0 1e2 1,5 1.1].each do |value|
      expect { calculate(bases: %w[100], value: value, type: 'flat') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
    end
    expect { calculate(bases: %w[100], value: '100.01', type: 'percent') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
    expect { calculate(bases: %w[0], value: '1', type: 'flat') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
    expect { calculate(bases: [Float::NAN], value: '1', type: 'flat') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
    expect { calculate(bases: %w[100], value: '1' * 65, type: 'percent') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
  end

  it 'conserves a fixed discount across varied line distributions' do
    random = Random.new(705)
    100.times do
      bases = Array.new(8) { random.rand(0..1_000) }
      next if bases.sum.zero?

      amount = random.rand(1..bases.sum)
      shares = calculate(bases: bases, value: amount.to_s, type: 'flat')
      expect(shares.sum).to eq(amount)
      expect(shares.zip(bases)).to all(satisfy { |share, base| share >= 0 && share <= base })
    end
  end
end
