# frozen_string_literal: true

RSpec.describe Spree::Pos::TargetPriceDiscount do
  def calculate(price: '100', quantity: '2', base: '200', target: '80', currency: 'VND')
    sale_line = Struct.new(:unit_price, :sale_quantity).new(BigDecimal(price), BigDecimal(quantity))
    described_class.call(sale_line: sale_line, base: BigDecimal(base), value: target, currency: currency)
  end

  it 'scales the per-sale-unit reduction and leaves original price untouched' do
    expect(calculate).to eq(40)
    expect(calculate(quantity: '3', base: '300')).to eq(60)
    expect(calculate(target: '100')).to eq(0)
    expect(calculate(target: '0')).to eq(200)
  end

  it 'keeps a better promotion instead of making the line negative or raising its price' do
    expect(calculate(base: '150')).to eq(0)
    expect(calculate(base: '170')).to eq(10)
    expect(calculate(base: '0')).to eq(0)
  end

  it 'rounds the measured target subtotal to whole VND rather than charging per gram' do
    expect(calculate(quantity: '1.25', base: '125', target: '90')).to eq(12)
    expect(calculate(quantity: '0.5', base: '50', target: '90')).to eq(5)
  end

  it 'rejects increases, fractional dong, malformed input and unsupported currencies' do
    %w[101 -1 1.1 NaN 1e2 1,000].each do |target|
      expect { calculate(target: target) }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
    end
    expect { calculate(currency: 'USD') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
    expect { calculate(base: '-1') }.to raise_error(Spree::Pos::DiscountCalculator::InvalidDiscount)
  end
end
