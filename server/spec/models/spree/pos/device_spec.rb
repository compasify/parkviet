# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Pos::Device, type: :model do
  it 'keeps the six modes and never treats the digest as the token' do
    expect(described_class::MODES).to eq(%w[waiter kds expo kiosk print_station owner bridge])
    token = described_class.new_token
    expect(described_class.digest(token)).not_to eq(token)
    expect(described_class.authenticate(token)).to be_nil
  end
end
