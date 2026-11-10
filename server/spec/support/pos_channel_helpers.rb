# frozen_string_literal: true

# Existing POS scenarios start with a configured selling surface, just as they
# start with enabled features/modules. Channel-policy specs opt out so missing,
# inactive, unpublished and scheduled states are exercised without auto-setup.
module PosChannelHelpers
  mattr_accessor :configure_on_create, default: true

  def self.channel_for(store)
    store.channels.find_or_create_by!(code: 'pos') { |channel| channel.name = 'Point of Sale'; channel.active = true }
  end
end

Spree::Pos::Branch.after_create do
  PosChannelHelpers.channel_for(store) if PosChannelHelpers.configure_on_create
end
Spree::Pos::BranchProduct.after_create do
  if PosChannelHelpers.configure_on_create
    Spree::ProductPublication.find_or_create_by!(product: product, channel: PosChannelHelpers.channel_for(branch.store))
  end
end

RSpec.configure do |config|
  config.around do |example|
    PosChannelHelpers.configure_on_create = example.metadata[:pos_channel] != :manual
    example.run
  ensure
    PosChannelHelpers.configure_on_create = true
  end
end
