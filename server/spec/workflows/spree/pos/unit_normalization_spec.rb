# frozen_string_literal: true

RSpec.describe Spree::Pos::UnitNormalizer do
  def unit(sale:, base:, price: nil, numerator: 1, denominator: 1)
    store = Spree::Store.default
    Spree::Pos::UnitDefinition.ensure_defaults!(store)
    sale_unit = Spree::Pos::UnitDefinition.find_by!(store: store, code: sale)
    base_unit = Spree::Pos::UnitDefinition.find_by!(store: store, code: base)
    OpenStruct.new(sale_unit: sale_unit, base_unit: base_unit, price_unit: price ? Spree::Pos::UnitDefinition.find_by!(store: store, code: price) : sale_unit, ratio_numerator: numerator, ratio_denominator: denominator)
  end

  it 'converts exact Vietnamese decimal quantities to integer base units' do
    expect(described_class.call(sale_quantity: '1.25', variant_unit: unit(sale: 'kg', base: 'g'))).to eq(1250)
    expect(described_class.call(sale_quantity: '0.5', variant_unit: unit(sale: 'l', base: 'ml'))).to eq(500)
    expect(described_class.call(sale_quantity: '2', variant_unit: unit(sale: 'item', base: 'item'))).to eq(2)
  end

  it 'converts whole cases exactly but rejects fractional cases (discrete count unit, sale_precision 0)' do
    expect(described_class.call(sale_quantity: '1', variant_unit: unit(sale: 'case', base: 'chai', numerator: 24))).to eq(24)
    expect(described_class.call(sale_quantity: '2', variant_unit: unit(sale: 'case', base: 'chai', numerator: 24))).to eq(48)
    # 0.5 case = 12 bottles mathematically, but `case` has sale_precision 0:
    # half a case must be sold as 12 `chai`, never entered as a fractional case.
    expect { described_class.call(sale_quantity: '0.5', variant_unit: unit(sale: 'case', base: 'chai', numerator: 24)) }
      .to raise_error(Spree::Pos::Conflict)
  end

  it 'rejects non-representable precision instead of rounding' do
    expect { described_class.call(sale_quantity: '1.2345', variant_unit: unit(sale: 'kg', base: 'g')) }.to raise_error(Spree::Pos::Conflict)
    expect { described_class.call(sale_quantity: '0.0001', variant_unit: unit(sale: 'kg', base: 'g')) }.to raise_error(Spree::Pos::Conflict)
    expect { described_class.call(sale_quantity: 'abc', variant_unit: unit(sale: 'kg', base: 'g')) }.to raise_error(Spree::Pos::Conflict)
    expect { described_class.call(sale_quantity: '0', variant_unit: unit(sale: 'kg', base: 'g')) }.to raise_error(Spree::Pos::Conflict)
  end

  it 'derives exact per-base prices and rejects unrepresentable ones' do
    expect(described_class.unit_price_per_base(price: BigDecimal('40000'), variant_unit: unit(sale: 'kg', base: 'g', price: 'kg'))).to eq(BigDecimal('40'))
    # 10000 / (3 * 1000) = 10/3 VND per gram: not exactly representable at scale 4,
    # so it must be rejected rather than silently rounded.
    expect { described_class.unit_price_per_base(price: BigDecimal('10000'), variant_unit: unit(sale: 'kg', base: 'g', price: 'kg', numerator: 3)) }
      .to raise_error(Spree::Pos::Conflict)
    # Ratio 3 sale-units = 1 price-unit: 9000 * 3 = 27000 per kg = exactly 27 per gram.
    expect(described_class.unit_price_per_base(price: BigDecimal('9000'), variant_unit: unit(sale: 'kg', base: 'g', price: 'kg', denominator: 3))).to eq(BigDecimal('27'))
  end
end
