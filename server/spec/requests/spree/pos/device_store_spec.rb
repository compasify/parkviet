# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_credit_helpers'
require_relative '../../../support/pos_owner_helpers'

RSpec.describe 'A staff device of a store other than the default', type: :request do
  include PosCreditHelpers
  include PosOwnerHelpers

  let(:other_store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(other_store) }
  let(:staff) { credit_staff(other_store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT]) }

  def device_headers
    _device, token = pair_owner_device!(branch)
    owner_headers(branch, staff, token)
  end

  it 'reaches its own store without naming it' do
    expect(Spree::Store.default).not_to eq(other_store)

    get '/api/v3/admin/pos/context/branches', headers: device_headers, as: :json

    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.fetch('data').pluck('id')).to eq([branch.prefixed_id])
  end

  it 'is refused when it names another store' do
    headers = device_headers.merge('X-Spree-Store-Id' => Spree::Store.default.prefixed_id)

    get '/api/v3/admin/pos/context/branches', headers: headers, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body.dig('error', 'code')).to eq('device_unauthorized')
  end
end
