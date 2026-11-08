# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# First-run setup: one idempotent command creates the store profile, the
# first branch with its profile's modules, defaults and sample units, a
# register, a full membership for the person setting up and only the risky
# features they ticked. Branch rows here come from the workflow alone, and
# features start at the product default (off).
RSpec.describe 'POS onboarding', type: :request, pos_modules: :default, pos_features: :default do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:location) { create(:stock_location, store: store, backorderable_default: false) }

  def staff_with(permissions, target_store = store)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: target_store, permissions: permissions)
    create(:role_user, user: user, role: role)
    user
  end

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def setup!(user, body, key: SecureRandom.uuid)
    post '/api/v3/admin/pos/onboarding', headers: { 'Authorization' => "Bearer #{token_for(user)}", 'Idempotency-Key' => key },
                                         params: body, as: :json
    response.parsed_body
  end

  def body(**overrides)
    {
      profile_key: 'nha_thuoc', wholesale: true, interests: ['cafe_tra_sua'],
      branch: { name: 'Nhà thuốc Q1', code: 'q1', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: location.prefixed_id },
      register: { name: 'Quầy 1' }, grant_self: true, features: %w[traceability returns]
    }.merge(overrides)
  end

  def reason_of(payload)
    payload.dig('error', 'details', 'reason')
  end

  it 'sets the store up in one command and replays the same body for the same key' do
    owner = staff_with(%w[write_pos_topology])
    key = SecureRandom.uuid
    data = setup!(owner, body, key: key)['data']
    expect(response).to have_http_status(:created)

    profile = Spree::Pos::StoreProfile.find_by!(store: store)
    expect(profile).to have_attributes(profile_key: 'nha_thuoc', profile_version: 1, wholesale: true, interests: ['cafe_tra_sua'],
                                       changed_by_id: owner.id)
    expect(profile.onboarded_at).to be_present
    branch = Spree::Pos::Branch.find_by!(store: store, code: 'q1')
    # The profile's defaults fill what the request left out.
    expect(branch).to have_attributes(profile_key: 'nha_thuoc', profile_version: 1, return_window_days: 7, lot_selection: 'fefo',
                                      status: 'active', stock_location_id: location.id)
    expect(Spree::Pos::BranchModule.where(branch: branch).pluck(:module_key, :enabled, :reason)).
      to contain_exactly(['retail.units', true, 'profile:nha_thuoc'], ['retail.traceability', true, 'profile:nha_thuoc'])
    expect(Spree::Pos::UnitDefinition.for_store(store).pluck(:code)).to include('vien', 'vi', 'hop', 'chai')
    register = Spree::Pos::Register.find_by!(branch: branch)
    expect(register).to have_attributes(name: 'Quầy 1', code: 'q1-1', status: 'active')
    membership = Spree::Pos::StaffMembership.find_by!(branch: branch, staff: owner)
    expect(membership.capabilities).to match_array(Spree::Pos::Capabilities::ASSIGNABLE)

    # Only the ticked features, each with its own audit and the profile reason.
    expect(Spree::Pos::FeaturePolicy.store_defaults(store).select { |_, on| on }.keys).to contain_exactly('traceability', 'returns')
    changes = Spree::Pos::AuditEntry.where(store: store, action: 'feature_flag.change')
    expect(changes.map { |row| row.metadata.slice('feature', 'to', 'reason') }).to contain_exactly(
      { 'feature' => 'traceability', 'to' => true, 'reason' => 'Thiết lập theo ngành: nha_thuoc' },
      { 'feature' => 'returns', 'to' => true, 'reason' => 'Thiết lập theo ngành: nha_thuoc' }
    )
    created = Spree::Pos::AuditEntry.find_by!(action: 'branch.create', subject_id: branch.id)
    expect(created.metadata).to include('profile_key' => 'nha_thuoc', 'modules' => %w[retail.units retail.traceability])
    expect(Spree::Pos::AuditEntry.where(action: %w[store_profile.change register.create membership.create]).pluck(:action)).
      to contain_exactly('store_profile.change', 'register.create', 'membership.create')

    expect(data['store_profile']).to include('id' => profile.prefixed_id, 'profile_key' => 'nha_thuoc')
    expect(data['branch']).to include('id' => branch.prefixed_id, 'profile_key' => 'nha_thuoc')
    expect(data['register']).to include('id' => register.prefixed_id)
    expect(data['membership']).to include('id' => membership.prefixed_id)
    expect(data['modules']).to eq('retail.units' => true, 'retail.measured' => false, 'retail.traceability' => true)
    expect(data['features']).to include('traceability' => true, 'returns' => true, 'credit' => false, 'refunds' => false)

    first_body = response.parsed_body
    setup!(owner, body, key: key)
    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to eq(first_body)
    expect(Spree::Pos::Branch.for_store(store).count).to eq(1)
    expect(Spree::Pos::Register.for_store(store).count).to eq(1)
    expect(Spree::Pos::StoreProfile.where(store: store).count).to eq(1)

    setup!(owner, body(wholesale: false), key: key)
    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body.dig('error', 'message')).to eq('Idempotency key was reused with a different payload.')

    expect(reason_of(setup!(owner, body(branch: body[:branch].merge(code: 'q2'))))).to eq('already_onboarded')
    expect(response).to have_http_status(:conflict)
    get '/api/v3/admin/pos/context', headers: { 'Authorization' => "Bearer #{token_for(owner)}" }
    expect(response.parsed_body['onboarding']).to eq('required' => false, 'can_setup' => true)
  end

  it 'writes nothing when a step fails, and keeps optional parts optional' do
    owner = staff_with(%w[write_pos_topology])
    # The branch is created before the register: a register code another store row holds rolls everything back.
    Spree::Pos::Register.create!(store: store, branch: create(:pos_branch, store: store, status: 'disabled'), name: 'X', code: 'taken',
                                 status: 'active')
    setup!(owner, body(register: { name: 'Quầy 1', code: 'taken' }))
    expect(response).to have_http_status(:unprocessable_content)
    expect(Spree::Pos::StoreProfile.where(store: store)).to be_empty
    expect(Spree::Pos::Branch.for_store(store).where(code: 'q1')).to be_empty
    expect(Spree::Pos::FeatureFlag.for_store(store)).to be_empty

    data = setup!(owner, body(profile_key: 'thoi_trang', interests: [], register: nil, grant_self: false, features: []))['data']
    expect(response).to have_http_status(:created)
    expect(data['register']).to be_nil
    expect(data['membership']).to be_nil
    expect(data['modules'].values).to all(be(false))
    branch = Spree::Pos::Branch.find_by_prefix_id!(data.dig('branch', 'id'))
    expect(Spree::Pos::BranchModule.where(branch: branch)).to be_empty
    expect(Spree::Pos::StaffMembership.where(branch: branch)).to be_empty
    expect(Spree::Pos::FeatureFlag.for_store(store)).to be_empty
  end

  it 'refuses coming-soon profiles as the industry and accepts them only as interests' do
    owner = staff_with(%w[write_pos_topology])
    expect(reason_of(setup!(owner, body(profile_key: 'cafe_tra_sua')))).to eq('profile_unavailable')
    expect(response).to have_http_status(:conflict)
    expect(reason_of(setup!(owner, body(profile_key: 'tiem_vang')))).to eq('profile_unknown')
    expect(reason_of(setup!(owner, body(interests: ['thoi_trang'])))).to eq('interest_invalid')
    expect(reason_of(setup!(owner, body(features: ['teleport'])))).to eq('feature_unknown')
    expect(Spree::Pos::StoreProfile.where(store: store)).to be_empty
    expect(Spree::Pos::Branch.for_store(store)).to be_empty

    setup!(owner, body(interests: %w[cafe_tra_sua quan_an]))
    expect(response).to have_http_status(:created)
    expect(Spree::Pos::StoreProfile.find_by!(store: store).interests).to eq(%w[cafe_tra_sua quan_an])
  end

  it 'is only for store topology managers, and only before the store runs' do
    setup!(staff_with(%w[read_pos_topology read_pos_orders]), body)
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('write_pos_topology')
    setup!(staff_with(%w[write_pos_topology], create(:store)), body)
    expect(response.status).to be_in([401, 403, 404])

    owner = staff_with(%w[write_pos_topology])
    post '/api/v3/admin/pos/onboarding', headers: { 'Authorization' => "Bearer #{token_for(owner)}" }, params: body, as: :json
    expect(response).to have_http_status(:unprocessable_content)

    # A store already selling (an active branch, no store profile) never goes through the setup.
    create(:pos_branch, store: store)
    expect(reason_of(setup!(owner, body))).to eq('already_onboarded')
    expect(Spree::Pos::StoreProfile.where(store: store)).to be_empty
  end
end
