# frozen_string_literal: true

# What boot registers for the F&B profiles that open first: every module they
# need has code, the registry the initializer built passes its own checks
# (dependencies registered and available, no cycle), and only profiles that
# still need planned modules stay coming soon (none of the shipped ones now).
RSpec.describe Spree::Pos::Modules do
  wave_one = %w[fnb.menu fnb.kitchen fnb.order_number fnb.cup_label fnb.recipes]

  it 'registers every first-wave F&B module as available with an entry point' do
    wave_one.each do |key|
      definition = described_class.find(key)
      expect(definition).to be_present, key
      expect(definition.status).to eq('available'), key
      expect(definition.entrypoints).not_to be_empty
    end
  end

  it 'registers resources, tables, pay-later, service charge and timed billing, and keeps relays planned' do
    %w[resources fnb.tables fnb.postpay fnb.service_charge timed_billing].each do |key|
      expect(described_class.find(key).status).to eq('available'), key
      expect(described_class.find(key).entrypoints).not_to be_empty, key
    end
    expect(described_class.find('fnb.tables').depends_on).to eq(['resources'])
    expect(described_class.find('timed_billing').depends_on).to eq(['resources', 'fnb.tables'])
    expect(described_class.find('resources.iot_relay').status).to eq('planned')
  end

  it 'passes the boot checks with the registry as registered' do
    definitions = described_class.all.index_by(&:key)
    expect(described_class.validate!(definitions)).to be(true)
    described_class.available.each do |definition|
      expect(definition.depends_on.map { |key| described_class.available?(key) }).to all(be(true)), definition.key
    end
  end

  it 'opens every F&B profile, karaoke and billiards included' do
    profiles = Spree::Pos::BusinessProfiles
    keys = %w[cafe_tra_sua quan_an cang_tin_tram_dung nha_hang bar_pub_club karaoke_bida]
    expect(keys.map { |key| profiles.fetch!(key).status }).to all(eq('available'))
  end
end
