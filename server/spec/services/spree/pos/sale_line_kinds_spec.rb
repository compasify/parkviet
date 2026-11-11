# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Pos::SaleLineKinds do
  it 'registers the six kinds and merges the retail and menu ones' do
    expect(described_class.keys).to contain_exactly('ordinary', 'measured', 'tracked', 'menu', 'timed', 'cover')
    %w[ordinary measured tracked menu].each { |kind| expect(described_class.mergeable?(kind)).to be(true) }
    %w[timed cover].each { |kind| expect(described_class.mergeable?(kind)).to be(false) }
  end

  it 'refuses a kind that was never registered' do
    expect { described_class.fetch!('banquet') }.to raise_error(Spree::Pos::Conflict) { |error|
      expect(error.reason).to eq('sale_line_kind_unknown')
    }
  end

  it 'refuses an available module that declares no route or workflow' do
    definition = Spree::Pos::Modules::Definition.new(
      key: 'demo.bare', group: 'demo', depends_on: [].freeze, status: 'available', entrypoints: [].freeze
    )
    expect { Spree::Pos::Modules.validate!('demo.bare' => definition) }.
      to raise_error(Spree::Pos::Modules::Invalid, /no route or workflow/)
  end
end
