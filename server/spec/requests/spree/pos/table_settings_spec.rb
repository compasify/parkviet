# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_kitchen_helpers'
require_relative '../../../support/pos_schema_helpers'

# A branch manager without store permissions sets the table service up: the
# settings bring the store's tax categories, so the service charge's can be
# chosen without the store's tax admin.
RSpec.describe 'POS table settings API', type: :request do
  include PosKitchenHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::MANAGE]) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def bearer(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end

  it 'lists the store tax categories and saves the one the service charge uses' do
    service = Spree::TaxCategory.create!(name: 'Dịch vụ 8%', tax_code: 'vat_service', store_id: store.id)
    other = Spree::TaxCategory.create!(name: 'Other store', tax_code: 'vat_other', store_id: create(:store).id)

    get '/api/v3/admin/pos/table_settings', headers: bearer(manager), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'TableSettings')
    ids = response.parsed_body.dig('data', 'tax_categories').pluck('id')
    expect(ids).to include(service.prefixed_id)
    expect(ids).not_to include(other.prefixed_id)
    expect(response.parsed_body.dig('data', 'tax_categories').find { |row| row['id'] == service.prefixed_id }).
      to eq('id' => service.prefixed_id, 'name' => 'Dịch vụ 8%', 'tax_code' => 'vat_service', 'is_default' => false)

    put '/api/v3/admin/pos/table_settings', headers: bearer(manager).merge('Idempotency-Key' => SecureRandom.uuid),
                                            params: { branch_id: branch.prefixed_id, service_charge_rate: '5',
                                                      service_charge_tax_category_id: service.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'service_charge_tax_category_id')).to eq(service.prefixed_id)
    expect(branch.reload.service_charge_tax_category).to eq(service)
    audit = Spree::Pos::AuditEntry.find_by!(action: 'table_settings.update')
    expect(audit.metadata['after']).not_to have_key('tax_categories')
  end

  it 'leaves the long-seated alert off until a branch sets its minutes, and turns it off again' do
    expect(branch.seated_alert_minutes).to be_nil
    update = lambda do |value|
      put '/api/v3/admin/pos/table_settings', headers: bearer(manager).merge('Idempotency-Key' => SecureRandom.uuid),
                                              params: { branch_id: branch.prefixed_id, seated_alert_minutes: value }, as: :json
    end

    update.call(180)
    expect(response).to have_http_status(:ok), response.body
    expect_pos_schema!(response, 'TableSettings')
    expect(response.parsed_body.dig('data', 'seated_alert_minutes')).to eq(180)
    get '/api/v3/admin/pos/context', headers: bearer(manager), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['branches'].find { |row| row['id'] == branch.prefixed_id }).to include('seated_alert_minutes' => 180)

    [5, 601, 'abc'].each do |value|
      update.call(value)
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('seated_alert_minutes_invalid')
    end
    expect(branch.reload.seated_alert_minutes).to eq(180)

    update.call(nil)
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('data', 'seated_alert_minutes')).to be_nil
    expect(branch.reload.seated_alert_minutes).to be_nil
  end
end
