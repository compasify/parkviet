# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_credit_helpers'

RSpec.describe Spree::Pos::Device, type: :model do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:device) do
    described_class.create!(store: store, branch: branch, name: 'Bếp', mode: 'kds', platform: 'android',
                            token_digest: described_class.digest(described_class.new_token))
  end

  describe 'staff session activity' do
    let(:sessions) { Spree::Pos::DeviceStaffSession }
    let(:token) { sessions.new_token }
    let(:last_active) { 5.minutes.ago.change(usec: 0) }
    let!(:session) do
      sessions.create!(device: device, staff: credit_staff(store, branch, PosCreditHelpers::CASHIER), token_digest: sessions.digest(token),
                       expires_at: 1.hour.from_now, last_active_at: last_active)
    end

    it 'counts an ordinary authentication as activity' do
      expect(sessions.authenticate(device, token)).to eq(session)
      expect(session.reload.last_active_at).to be > last_active
    end

    it 'finds the session without extending it when touch is off' do
      expect(sessions.authenticate(device, token, touch: false)).to eq(session)
      expect(session.reload.last_active_at).to eq(last_active)
    end

    it 'still refuses an idle session when touch is off' do
      session.update_columns(last_active_at: 31.minutes.ago)
      expect(sessions.authenticate(device, token, touch: false)).to be_nil
    end
  end

  it 'keeps the six modes and never treats the digest as the token' do
    expect(described_class::MODES).to eq(%w[waiter kds expo kiosk print_station owner bridge])
    token = described_class.new_token
    expect(described_class.digest(token)).not_to eq(token)
    expect(described_class.authenticate(token)).to be_nil
  end
end
