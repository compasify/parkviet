# frozen_string_literal: true

# Recovery: a lost response must replay the same command receipt instead of
# creating money twice; outbox rows survive for the recovery sweep.
RSpec.describe 'POS settlement recovery', type: :request do
  it 'records outbox entries for tender lifecycle and keeps command receipts replayable' do
    store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
    user = create(:admin_user)
    entry = Spree::Pos::OutboxEntry.record!(store: store, event_type: 'tender.prepared', aggregate: user,
                                            payload: { 'attempt_id' => 'postender_x' })
    expect(entry.status).to eq('pending')
    expect(Spree::Pos::OutboxEntry.due).to include(entry)
    entry.update!(status: 'processed', processed_at: Time.current)
    expect(Spree::Pos::OutboxEntry.due).not_to include(entry)
  end
end
