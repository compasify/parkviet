# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Pos::BusinessDay, type: :model do
  let(:store) { create(:store) }
  let(:location) { create(:stock_location, store: store) }
  let(:branch) do
    Spree::Pos::Branch.create!(
      store: store, stock_location: location, name: 'Day', code: "d#{SecureRandom.hex(3)}",
      timezone: 'Asia/Ho_Chi_Minh', status: 'active'
    )
  end
  let(:zone) { ActiveSupport::TimeZone['Asia/Ho_Chi_Minh'] }

  it 'keeps a time before 04:00 on the previous date and starts the new day at 04:00' do
    expect(described_class.for(branch, zone.local(2026, 11, 5, 23, 59))).to eq(Date.new(2026, 11, 5))
    expect(described_class.for(branch, zone.local(2026, 11, 6, 0, 0))).to eq(Date.new(2026, 11, 5))
    expect(described_class.for(branch, zone.local(2026, 11, 6, 3, 59))).to eq(Date.new(2026, 11, 5))
    expect(described_class.for(branch, zone.local(2026, 11, 6, 4, 0))).to eq(Date.new(2026, 11, 6))
  end

  it 'takes the business clock from the database, whatever the app clock says' do
    allow(Spree::Pos::Workspace).to receive(:business_now).and_call_original
    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(zone.local(2026, 11, 6, 1, 0))
    expect(Spree::Pos::Workspace.business_now).to eq(zone.local(2026, 11, 6, 1, 0))
  end

  it 'uses the branch timezone, so the same instant can be a different business date' do
    instant = Time.utc(2026, 11, 5, 22, 0)
    expect(described_class.for(branch, instant)).to eq(Date.new(2026, 11, 6))
    branch.update!(timezone: 'UTC')
    expect(described_class.for(branch, instant)).to eq(Date.new(2026, 11, 5))
  end
end
