# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_schema_helpers'

# A bar's bottle-keeping book over the API: keeping a guest's bottle with a
# photo, finding it by code or phone, pouring from it, correcting its level
# with an approval, its label, and the history that is never rewritten.
RSpec.describe 'POS bottle keeping', type: :request do
  include PosTableHelpers
  include PosSchemaHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store).tap { |row| set_pos_module(row, 'fnb.bottle_keep', true) } }
  let(:bartender) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:bottle) { menu_product!(store, branch, name: 'Hennessy VSOP', price: 2_500_000) }
  let(:photo) { Rack::Test::UploadedFile.new(StringIO.new("\x89PNG\r\n\x1A\n#{'x' * 64}"), 'image/png', original_filename: 'chai.png') }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def headers(user = bartender)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
    { 'Authorization' => "Bearer #{@tokens[user.id]}", 'Idempotency-Key' => SecureRandom.uuid }
  end

  def keep!(phone: '0901 234 567', level: 70)
    post '/api/v3/admin/pos/bottle_keeps', headers: headers, params: {
      branch_id: branch.prefixed_id, variant_id: bottle.prefixed_id, level_percent: level, guest_name: 'Anh Hùng', phone: phone,
      photo: photo
    }
    expect(response).to have_http_status(:created), response.body
    response.parsed_body['data']
  end

  it 'keeps a bottle with a photo under a new code for the branch’s days, and finds it by code or phone' do
    branch.update!(bottle_keep_days: 30)
    data = keep!
    expect_pos_schema!(response, 'BottleKeep')
    expect(data).to include('status' => 'kept', 'level_percent' => 70, 'phone' => '0901234567', 'guest_name' => 'Anh Hùng')
    expect(Date.iso8601(data['expires_on']) - Date.iso8601(data['kept_on'])).to eq(30)
    expect(data['code']).to match(/\A[A-Z2-9]{6}\z/)
    expect(data['photo_url']).to be_present
    expect(data['events'].map { |row| row['kind'] }).to eq(['open'])

    get '/api/v3/admin/pos/bottle_keeps', headers: headers(waiter), params: { branch_id: branch.prefixed_id, q: data['code'].downcase }
    expect(response).to have_http_status(:ok)
    expect_pos_schema!(response, 'BottleKeep')
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([data['id']])
    get '/api/v3/admin/pos/bottle_keeps', headers: headers(waiter), params: { branch_id: branch.prefixed_id, q: '+84 901 234' }
    expect(response.parsed_body['data'].map { |row| row['id'] }).to eq([data['id']])
  end

  it 'pours from the bottle for free, never raising the level, and finishes it at zero' do
    data = keep!
    path = "/api/v3/admin/pos/bottle_keeps/#{data['id']}/pour"

    post path, headers: headers(waiter), params: { level_percent: 40, ml: 120, photo: photo }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['data']).to include('level_percent' => 40, 'status' => 'kept')
    post path, headers: headers(waiter), params: { level_percent: 60 }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('bottle_level_raised')
    post path, headers: headers(waiter), params: { level_percent: 0 }
    expect(response.parsed_body['data']).to include('status' => 'finished', 'level_percent' => 0)
    expect(Spree::Order.where(store: store).sum(:total)).to eq(0)

    get "/api/v3/admin/pos/bottle_keeps/#{data['id']}", headers: headers(waiter)
    expect_pos_schema!(response, 'BottleKeep')
    expect(response.parsed_body.dig('data', 'events').map { |row| [row['kind'], row['level_before'], row['level_after'], row['ml']] }).
      to eq([['open', nil, 70, nil], ['pour', 70, 40, 120], ['pour', 40, 0, nil]])
  end

  it 'corrects the level only with an approval bound to the bottle’s version, keeping the old level in the history' do
    data = keep!
    path = "/api/v3/admin/pos/bottle_keeps/#{data['id']}/adjust"

    post path, headers: headers, as: :json, params: { level_percent: 90, note: 'Nhập sai', expected_revision: data['revision'] }
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'details')).to include('reason' => 'approval_required', 'action' => 'bottle_keep.adjust',
                                                                    'subject_id' => data['id'])

    post '/api/v3/admin/pos/approvals', headers: headers(manager), as: :json, params: {
      branch_id: branch.prefixed_id, requester_id: bartender.prefixed_id, bottle_keep_id: data['id'], action_name: 'bottle_keep.adjust',
      revision: data['revision'], expires_at: 10.minutes.from_now.iso8601
    }
    expect(response).to have_http_status(:created), response.body
    approval_id = response.parsed_body.dig('data', 'id')

    post path, headers: headers, as: :json, params: { level_percent: 90, note: 'Nhập sai', expected_revision: data['revision'],
                                                      approval_id: approval_id }
    expect(response).to have_http_status(:ok), response.body
    event = response.parsed_body.dig('data', 'events').last
    expect(event).to include('kind' => 'adjust', 'level_before' => 70, 'level_after' => 90, 'approval_id' => approval_id, 'note' => 'Nhập sai')

    post path, headers: headers, as: :json, params: { level_percent: 80, note: 'Lại', expected_revision: data['revision'],
                                                      approval_id: approval_id }
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('bottle_keep_changed')

    record = Spree::Pos::BottleKeepEvent.order(:id).last
    expect { record.update!(level_after: 10) }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { record.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it 'refuses a level approval granted on an order' do
    table_register!(branch, bartender)
    order = open_table(bartender, table!(area!(branch), name: 'Bàn 1'))
    post '/api/v3/admin/pos/approvals', headers: headers(manager), as: :json, params: {
      branch_id: branch.prefixed_id, requester_id: bartender.prefixed_id, workspace_id: order.workspace.prefixed_id,
      action_name: 'bottle_keep.adjust', revision: order.workspace.revision, expires_at: 10.minutes.from_now.iso8601
    }
    expect(response).to have_http_status(:conflict)
  end

  it 'prints the label as a receipt document and ends the bottle when the guest takes it home' do
    data = keep!
    post "/api/v3/admin/pos/bottle_keeps/#{data['id']}/label", headers: headers(waiter), as: :json
    expect(response).to have_http_status(:ok), response.body
    document = response.parsed_body.dig('data', 'document')
    expect(document['kind']).to eq('receipt')
    expect(document.to_json).to include(data['code'], 'Hennessy VSOP', 'Còn 70%')
    expect(document['header']).to include(hash_including('kind' => 'qr', 'value' => data['code']))

    post "/api/v3/admin/pos/bottle_keeps/#{data['id']}/return", headers: headers, as: :json, params: { note: 'Khách mang về' }
    expect(response.parsed_body['data']).to include('status' => 'returned')
  end

  it 'expires overdue bottles once a day and is refused where the book is off' do
    data = keep!
    Spree::Pos::BottleKeep.find_by_prefix_id!(data['id']).update_columns(kept_on: Date.current - 40, expires_on: Date.current - 2)
    Spree::Pos::BottleKeeps::ExpireJob.perform_now
    keep = Spree::Pos::BottleKeep.find_by_prefix_id!(data['id'])
    expect(keep.status).to eq('expired')
    expect(keep.events.order(:id).last).to have_attributes(kind: 'expire', actor_id: bartender.id)

    set_pos_module(branch, 'fnb.bottle_keep', false)
    post '/api/v3/admin/pos/bottle_keeps', headers: headers, params: { branch_id: branch.prefixed_id, variant_id: bottle.prefixed_id,
                                                                       level_percent: 50, guest_name: 'Chị Na' }
    expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('module_disabled')
  end

  it 'reports the bar night and lists the tips of the day' do
    reader = credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::REPORT_READ])
    keep!
    get '/api/v3/admin/pos/reports/bar', headers: headers(reader), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body.dig('meta', 'summary')).to include('bottles_kept' => 1, 'tips_in_revenue' => false, 'keeps_expiring' => 0)

    waiter
    get '/api/v3/admin/pos/tips', headers: headers(reader), params: { branch_id: branch.prefixed_id }
    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body['meta']).to include('held' => '0.0', 'tips_as_revenue' => false)
    expect(response.parsed_body.dig('meta', 'staff').map { |row| row['staff_id'] }).to include(reader.prefixed_id, waiter.prefixed_id)
  end
end
