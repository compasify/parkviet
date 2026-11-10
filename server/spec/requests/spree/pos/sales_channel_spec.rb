# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

RSpec.describe 'POS sales channel', type: :request, pos_channel: :manual do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:password) { 'secret123' }
  let(:editor_id) { SecureRandom.uuid }
  let(:branch) { create(:pos_branch, store: store) }
  let(:register) { create(:pos_register, branch: branch) }
  let(:user) do
    staff = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: store, permissions: %w[write_pos_orders write_pos_shifts write_pos_workspaces write_pos_topology])
    create(:role_user, user: staff, role: role)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: staff, status: 'active',
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT,
                     Spree::Pos::Capabilities::RESOLVE, Spree::Pos::Capabilities::MANAGE])
    staff
  end
  let(:headers) do
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    { 'Authorization' => "Bearer #{response.parsed_body.fetch('token')}" }
  end
  let(:channel) { PosChannelHelpers.channel_for(store) }
  let(:product) do
    row = create(:product, store: store, status: 'active', name: 'POS rice')
    row.default_variant.update!(barcode: '8931234567890')
    row.default_variant.set_price('VND', 100)
    Spree::Pos::BranchProduct.create!(branch: branch, product: row)
    row
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def publish(row = product, **attributes)
    Spree::ProductPublication.create!(product: row, channel: channel, **attributes)
  end

  def catalog(**params)
    # Rails tunnels JSON GET through POST and may mutate its headers with a
    # method override; never reuse that mutation for a later item command.
    get '/api/v3/admin/pos/catalog', headers: headers.dup, params: { branch_id: branch.prefixed_id }.merge(params), as: :json
  end

  def draft
    headers
    Spree::Pos::Shifts::Open.call(store: store, staff: user, register: register, opening_float: '0')
    result = Spree::Pos::Workspaces::Create.call(store: store, staff: user, register_id: register.prefixed_id,
      key: SecureRandom.uuid, editor_id: editor_id)
    Spree::Pos::Workspace.find_by_prefix_id!(result['id'])
  end

  def command(workspace, path, revision:, key: SecureRandom.uuid, **attributes)
    post "/api/v3/admin/pos/workspaces/#{workspace.prefixed_id}/#{path}",
      headers: headers.merge('Idempotency-Key' => key),
      params: { expected_revision: revision, lease_generation: workspace.lease_generation, editor_id: editor_id,
                idempotency_key: key }.merge(attributes), as: :json
  end

  def add(workspace, revision: 0, **attributes)
    command(workspace, 'items', revision: revision, variant_id: product.default_variant.prefixed_id, quantity: 1, **attributes)
  end

  def reason
    response.parsed_body.dig('error', 'details', 'reason')
  end

  def channel_price(amount)
    list = Spree::PriceList.create!(store: store, name: 'POS prices', status: 'active', match_policy: 'all')
    Spree::PriceRules::ChannelRule.create!(price_list: list, preferred_channel_ids: [channel.id])
    Spree::Price.create!(variant: product.default_variant, price_list: list, currency: 'VND', amount: amount)
  end

  it 'reports missing setup without blocking context and never uses another store channel' do
    foreign = create(:store)
    PosChannelHelpers.channel_for(foreign)
    get '/api/v3/admin/pos/context', headers: headers.dup, params: { branch_id: branch.prefixed_id }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['sales_channel']).to include('status' => 'missing', 'code' => 'pos', 'id' => nil)
    expect(response.parsed_body['branches']).not_to be_empty
    expect { Pos::CreateWalkInDraft.call(store: store, staff: user) }.to raise_error(Spree::Pos::Conflict) { |e| expect(e.reason).to eq('pos_channel_missing') }
    expect(store.orders).to be_empty
    catalog
    expect(response).to have_http_status(:conflict)
    expect(reason).to eq('pos_channel_missing')
  end

  it 'refuses inactive setup and attributes new drafts to the server-owned POS channel' do
    channel.update!(active: false)
    expect { Pos::CreateWalkInDraft.call(store: store, staff: user) }.to raise_error(Spree::Pos::Conflict) { |e| expect(e.reason).to eq('pos_channel_inactive') }
    channel.update!(active: true)
    workspace = draft
    expect(workspace.order.channel_id).to eq(channel.id)
    expect(workspace.order.store_id).to eq(store.id)
    expect(store.channels.find_by(code: 'online')).not_to eq(channel)
  end

  it 'intersects publication windows, product state and branch assortment for browse and exact barcode' do
    publication = publish(published_at: 1.hour.from_now)
    catalog
    expect(response.parsed_body.fetch('data')).to be_empty
    publication.update!(published_at: 1.hour.ago, unpublished_at: Time.current)
    catalog(q: product.default_variant.barcode, barcode: 'true')
    expect(response.parsed_body.fetch('data')).to be_empty
    publication.update!(unpublished_at: nil)
    catalog(q: product.default_variant.barcode, barcode: 'true')
    expect(response.parsed_body.fetch('data').map { |row| row['id'] }).to eq([product.default_variant.prefixed_id])
    product.update!(status: 'draft')
    catalog
    expect(response.parsed_body.fetch('data')).to be_empty
    product.update!(status: 'active')
    Spree::Pos::BranchProduct.where(branch: branch, product: product).delete_all
    catalog
    expect(response.parsed_body.fetch('data')).to be_empty
  end

  it 'does not accept Online-only publication or direct-ID and channel-header bypasses' do
    channel
    Spree::ProductPublication.find_or_create_by!(product: product, channel: store.channels.find_by!(code: 'online'))
    catalog(q: product.default_variant.barcode, barcode: 'true')
    expect(response.parsed_body.fetch('data')).to be_empty
    workspace = draft
    add(workspace)
    expect(response).to have_http_status(:not_found)
    expect(workspace.order.line_items).to be_empty
    get '/api/v3/admin/pos/catalog', headers: headers.merge('X-Spree-Channel' => 'online'),
      params: { branch_id: branch.prefixed_id, q: '' }, as: :json
    expect(response.parsed_body.fetch('data')).to be_empty
  end

  it 'restricts branch-assortment choices and rejects unpublished assignment without auto-publishing' do
    channel
    product
    path = "/api/v3/admin/pos/branches/#{branch.prefixed_id}/products"
    get path, headers: headers, as: :json
    expect(response.parsed_body.fetch('data')).to be_empty
    Spree::Pos::BranchProduct.where(branch: branch, product: product).delete_all
    post path, headers: headers, params: { product_id: product.prefixed_id }, as: :json
    expect(response).to have_http_status(:not_found)
    expect(product.product_publications.where(channel: channel)).to be_empty
    publish
    get path, headers: headers, as: :json
    expect(response.parsed_body.fetch('data').sole).to include('id' => product.prefixed_id, 'assigned' => false)
    post path, headers: headers, params: { product_id: product.prefixed_id }, as: :json
    expect(response).to have_http_status(:created)
    channel.update!(active: false)
    delete "#{path}/#{product.prefixed_id}", headers: headers, as: :json
    expect(response).to have_http_status(:no_content)
  end

  it 'blocks new additions and quantity increases after unpublication while allowing removal and cancellation' do
    publication = publish
    workspace = draft
    add(workspace, quantity: 2)
    expect(response).to have_http_status(:ok)
    sale_id = response.parsed_body.dig('data', 'line_items', 0, 'sale_line_id')
    publication.destroy!
    add(workspace, revision: 1)
    expect(response).to have_http_status(:conflict)
    expect(reason).to eq('pos_product_unavailable')
    command(workspace, "items/#{sale_id}/update", revision: 1, quantity: 3)
    expect(response).to have_http_status(:conflict)
    command(workspace, "items/#{sale_id}/update", revision: 1, quantity: 1)
    expect(response).to have_http_status(:ok)
    channel.update!(active: false)
    command(workspace, "items/#{sale_id}/remove", revision: 2)
    expect(response).to have_http_status(:ok)
    command(workspace, 'cancel', revision: 3)
    expect(response).to have_http_status(:ok)
  end

  it 'keeps legacy drafts on their original channel and refuses extending them' do
    publish
    workspace = draft
    online = store.channels.find_by!(code: 'online')
    workspace.order.update!(channel: online)
    add(workspace)
    expect(response).to have_http_status(:conflict)
    expect(reason).to eq('pos_channel_mismatch')
    expect(workspace.order.reload.channel_id).to eq(online.id)
    command(workspace, 'cancel', revision: 0)
    expect(response).to have_http_status(:ok)
    expect(workspace.order.reload.channel_id).to eq(online.id)
  end

  it 'uses channel prices for catalog and additions instead of base or ambient Online prices' do
    publish
    channel_price(80)
    Spree::Current.channel = store.channels.find_by!(code: 'online')
    catalog
    expect(response.parsed_body.fetch('data').sole['price']).to eq('80.0')
    workspace = draft
    add(workspace)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('80.0')
    expect(response.parsed_body.dig('data', 'line_items', 0, 'list_price')).to eq('80.0')
    expect(product.default_variant.price_in('VND').amount).to eq(100)
  end

  it 'evaluates automatic promotions against the order POS channel, not the ambient request channel' do
    publish
    promotion = create(:promotion, store: store, code: nil, kind: 'automatic', name: 'POS campaign')
    rule = Spree::Promotion::Rules::Channel.create!(promotion: promotion, preferred_channel_ids: [channel.id])
    Spree::Promotion::Actions::CreateItemAdjustments.create!(promotion: promotion,
      calculator: Spree::Calculator::PercentOnLineItem.new(preferred_percent: 20))
    workspace = draft
    add(workspace)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('80.0')
    rule.update!(preferred_channel_ids: [store.channels.find_by!(code: 'online').id])
    add(workspace, revision: 1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'totals', 'total')).to eq('200.0')
    expect(workspace.order.reload.channel_id).to eq(channel.id)
  end

  it 'rejects the first tender after a product is unpublished without committing a snapshot' do
    publication = publish
    workspace = draft
    add(workspace)
    publication.destroy!
    command(workspace, 'tender_attempts', revision: 1, payment_method_id: 'cash', amount: '100')
    expect(response).to have_http_status(:conflict)
    expect(reason).to eq('pos_product_unavailable')
    expect(Spree::Pos::TenderAttempt.where(workspace: workspace)).to be_empty
  end
end
