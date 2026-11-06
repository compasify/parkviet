# frozen_string_literal: true

RSpec.describe Spree::Pos::CommandExecutor do
  let(:store) { Spree::Store.default }
  let(:staff) { create(:admin_user, :without_admin_role) }
  let(:authorize) { -> {} }

  it 'replays the same digest and conflicts when the payload changes' do
    payload = { 'flag' => false, 'nested' => { 'b' => 1, 'a' => nil } }
    first = described_class.call(store: store, actor: staff, key: 'k1', payload: payload, authorize: authorize) { { 'ok' => true } }
    expect(described_class.call(store: store, actor: staff, key: 'k1', payload: { flag: false, nested: { a: nil, b: 1 } }, authorize: authorize) {
      raise 'replay must not run the command'
    }).to eq(first)

    expect {
      described_class.call(store: store, actor: staff, key: 'k1', payload: { 'flag' => true }, authorize: authorize) { { 'ok' => false } }
    }.to raise_error(Spree::Pos::Conflict)
    expect(Spree::Pos::CommandReceipt.where(actor: staff, idempotency_key: 'k1').count).to eq(1)
  end

  it 'checks current authorization before returning a receipt' do
    described_class.call(store: store, actor: staff, key: 'revoked', payload: {}, authorize: authorize) { { 'ok' => true } }
    expect {
      described_class.call(store: store, actor: staff, key: 'revoked', payload: {}, authorize: -> { raise CanCan::AccessDenied }) { nil }
    }.to raise_error(CanCan::AccessDenied)
  end

  it 'does not treat a false flag as missing' do
    false_digest = Spree::Pos::CommandReceipt.digest_for('flag' => false)
    true_digest = Spree::Pos::CommandReceipt.digest_for('flag' => true)
    symbol_digest = Spree::Pos::CommandReceipt.digest_for(flag: false)

    expect(false_digest).to eq(symbol_digest)
    expect(false_digest).not_to eq(true_digest)
  end
end
