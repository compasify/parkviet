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
      profile_key: 'nha_thuoc', wholesale: true, interests: ['karaoke_bida'],
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
    expect(profile).to have_attributes(profile_key: 'nha_thuoc', profile_version: 2, wholesale: true, interests: ['karaoke_bida'],
                                       changed_by_id: owner.id)
    expect(profile.onboarded_at).to be_present
    branch = Spree::Pos::Branch.find_by!(store: store, code: 'q1')
    # The profile's defaults fill what the request left out.
    expect(branch).to have_attributes(profile_key: 'nha_thuoc', profile_version: 2, return_window_days: 7, lot_selection: 'fefo',
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
    expect(data['modules']).to eq('retail.units' => true, 'retail.measured' => false, 'retail.traceability' => true, 'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false, 'resources' => false, 'fnb.tables' => false, 'fnb.postpay' => false, 'fnb.service_charge' => false,
                                     'fnb.reservations' => false, 'fnb.bottle_keep' => false, 'fnb.pour_tracking' => false, 'fnb.meal_accounts' => false, 'fnb.vehicle_commission' => false)
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
    expect(reason_of(setup!(owner, body(profile_key: 'karaoke_bida')))).to eq('profile_unavailable')
    expect(response).to have_http_status(:conflict)
    expect(reason_of(setup!(owner, body(profile_key: 'tiem_vang')))).to eq('profile_unknown')
    expect(reason_of(setup!(owner, body(interests: ['thoi_trang'])))).to eq('interest_invalid')
    expect(reason_of(setup!(owner, body(features: ['teleport'])))).to eq('feature_unknown')
    expect(Spree::Pos::StoreProfile.where(store: store)).to be_empty
    expect(Spree::Pos::Branch.for_store(store)).to be_empty

    expect(reason_of(setup!(owner, body(interests: %w[karaoke_bida nha_hang])))).to eq('interest_invalid')
    setup!(owner, body(interests: %w[karaoke_bida]))
    expect(response).to have_http_status(:created)
    expect(Spree::Pos::StoreProfile.find_by!(store: store).interests).to eq(%w[karaoke_bida])
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

  describe 'the F&B shop setup step' do
    let(:fnb_setup) do
      { stations: [{ name: 'Bếp', kind: 'prep' }, { name: 'Bar', kind: 'bar' }],
        tax_categories: { food: 'vat_food', alcohol: 'vat_special' }, kitchen_send_trigger: 'manual' }
    end

    def cafe(**overrides)
      body(**{ profile_key: 'cafe_tra_sua', wholesale: false, interests: [], features: [],
               branch: { name: 'Cà phê Q1', code: 'cafe-q1', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: location.prefixed_id },
               fnb_setup: fnb_setup }.merge(overrides))
    end

    it 'creates the stations, the menu tax defaults and the send trigger once, audited' do
      owner = staff_with(%w[write_pos_topology])
      key = SecureRandom.uuid
      data = setup!(owner, cafe, key: key)['data']
      expect(response).to have_http_status(:created)

      branch = Spree::Pos::Branch.find_by!(store: store, code: 'cafe-q1')
      expect(branch).to have_attributes(profile_key: 'cafe_tra_sua', kitchen_send_trigger: 'manual')
      expect(Spree::Pos::BranchModule.where(branch: branch, enabled: true).pluck(:module_key)).
        to include('fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.cup_label', 'fnb.recipes', 'fnb.delivery_platforms')
      stations = Spree::Pos::KitchenStation.where(branch: branch).order(:position)
      expect(stations.pluck(:name, :kind, :is_default)).to eq([['Bếp', 'prep', true], ['Bar', 'bar', false]])
      food = Spree::TaxCategory.find_by!(store_id: store.id, tax_code: 'vat_food')
      alcohol = Spree::TaxCategory.find_by!(store_id: store.id, tax_code: 'vat_special')
      profile = Spree::Pos::StoreProfile.find_by!(store: store)
      expect(profile).to have_attributes(food_tax_category_id: food.id, alcohol_tax_category_id: alcohol.id)

      expect(data['fnb_setup']).to include('kitchen_send_trigger' => 'manual',
                                           'tax_defaults' => { 'food' => food.prefixed_id, 'alcohol' => alcohol.prefixed_id })
      expect(data['fnb_setup']['stations'].pluck('id')).to eq(stations.map(&:prefixed_id))
      expect(data['store_profile']['tax_defaults']).to eq('food' => food.prefixed_id, 'alcohol' => alcohol.prefixed_id)
      audit = Spree::Pos::AuditEntry.find_by!(store: store, action: 'onboarding.fnb_setup')
      expect(audit.metadata).to include('stations' => stations.map(&:prefixed_id), 'kitchen_send_trigger' => 'manual',
                                        'tax_categories' => { 'food' => 'vat_food', 'alcohol' => 'vat_special' })
      expect(Spree::Pos::AuditEntry.where(store: store, action: 'kitchen_station.create').count).to eq(2)

      first_body = response.parsed_body
      setup!(owner, cafe, key: key)
      expect(response.parsed_body).to eq(first_body)
      expect(Spree::Pos::KitchenStation.where(branch: branch).count).to eq(2)
      expect(Spree::Pos::AuditEntry.where(store: store, action: 'onboarding.fnb_setup').count).to eq(1)
    end

    it 'keeps the profile trigger without the step, and a canteen gets one station' do
      owner = staff_with(%w[write_pos_topology])
      data = setup!(owner, cafe(profile_key: 'cang_tin_tram_dung', features: [],
                                fnb_setup: { stations: [{ name: 'Bếp', kind: 'prep' }] }))['data']
      expect(response).to have_http_status(:created)
      branch = Spree::Pos::Branch.find_by_prefix_id!(data.dig('branch', 'id'))
      expect(branch.kitchen_send_trigger).to eq('on_complete')
      expect(Spree::Pos::KitchenStation.where(branch: branch).pluck(:name)).to eq(['Bếp'])
      expect(Spree::Pos::StoreProfile.find_by!(store: store).food_tax_category_id).to be_nil
    end

    it 'gives new menu items the food tax default' do
      owner = staff_with(%w[write_pos_topology write_pos_orders])
      setup!(owner, cafe)
      product = create(:product, store: store)
      post '/api/v3/admin/pos/menu_items', headers: { 'Authorization' => "Bearer #{token_for(owner)}", 'Idempotency-Key' => SecureRandom.uuid },
                                           params: { product_id: product.prefixed_id, kind: 'single' }, as: :json
      expect(response).to have_http_status(:created)
      food = Spree::Pos::StoreProfile.find_by!(store: store).food_tax_category
      expect(product.reload.tax_category).to eq(food)
      get '/api/v3/admin/pos/menu_items', headers: { 'Authorization' => "Bearer #{token_for(owner)}" }
      expect(response.parsed_body.dig('meta', 'tax_defaults', 'food')).to eq(food.prefixed_id)
    end

    it 'skips the step for retail profiles and refuses a malformed step' do
      owner = staff_with(%w[write_pos_topology])
      expect(reason_of(setup!(owner, body(fnb_setup: fnb_setup)))).to eq('fnb_setup_invalid')
      expect(reason_of(setup!(owner, cafe(fnb_setup: fnb_setup.merge(stations: [{ name: 'Pass', kind: 'expo' }]))))).to eq('fnb_setup_invalid')
      expect(reason_of(setup!(owner, cafe(fnb_setup: fnb_setup.merge(stations: [{ name: 'Bếp', kind: 'prep' }, { name: 'bếp', kind: 'bar' }]))))).
        to eq('fnb_setup_invalid')
      expect(reason_of(setup!(owner, cafe(fnb_setup: fnb_setup.merge(tax_categories: { food: 'vat_zero', alcohol: 'vat_special' }))))).
        to eq('fnb_setup_invalid')
      expect(reason_of(setup!(owner, cafe(fnb_setup: fnb_setup.merge(kitchen_send_trigger: 'later'))))).to eq('fnb_setup_invalid')
      expect(response).to have_http_status(:conflict)
      expect(Spree::Pos::StoreProfile.where(store: store)).to be_empty

      setup!(owner, body)
      expect(response).to have_http_status(:created)
      expect(Spree::Pos::AuditEntry.where(store: store, action: 'onboarding.fnb_setup')).to be_empty
      expect(response.parsed_body.dig('data', 'fnb_setup')).to be_nil
      expect(response.parsed_body.dig('data', 'table_service')).to be_nil
    end
  end

  describe 'table service' do
    let(:fnb_setup) do
      { stations: [{ name: 'Bếp', kind: 'prep' }, { name: 'Quầy pha chế', kind: 'bar' }],
        tax_categories: { food: 'vat_food', alcohol: 'vat_special' } }
    end

    def shop(profile_key, **overrides)
      body(**{ profile_key: profile_key, wholesale: false, interests: [], features: [],
               branch: { name: 'Quán Q1', code: 'quan-q1', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: location.prefixed_id },
               fnb_setup: fnb_setup }.merge(overrides))
    end

    it 'turns the optional table modules on for an eatery that serves tables, books table orders on the register, routes drinks to the bar' do
      owner = staff_with(%w[write_pos_topology])
      key = SecureRandom.uuid
      data = setup!(owner, shop('quan_an', answers: { has_tables: true }), key: key)['data']
      expect(response).to have_http_status(:created)

      branch = Spree::Pos::Branch.find_by!(store: store, code: 'quan-q1')
      register = Spree::Pos::Register.find_by!(branch: branch)
      expect(branch.table_register).to eq(register)
      expect(data['modules']).to include('resources' => true, 'fnb.tables' => true, 'fnb.postpay' => true, 'fnb.service_charge' => true,
                                         'fnb.menu' => true)
      switched = Spree::Pos::AuditEntry.where(store: store, action: 'branch_module.change').map { |row| row.metadata['module'] }
      expect(switched).to eq(%w[resources fnb.tables fnb.postpay fnb.service_charge])
      stations = Spree::Pos::KitchenStation.where(branch: branch).order(:position)
      expect(stations.pluck(:name)).to eq(['Bếp', 'Quầy pha chế'])
      route = Spree::Pos::StationRoute.find_by!(branch: branch)
      expect(route).to have_attributes(kitchen_category: 'do_uong', kitchen_station_id: stations.last.id)
      expect(data['table_service']).to include('table_register_id' => register.prefixed_id,
                                               'modules_enabled' => %w[resources fnb.tables fnb.postpay fnb.service_charge],
                                               'stations' => [])
      expect(data['table_service']['routes'].pluck('kitchen_category')).to eq(['do_uong'])
      expect(Spree::Pos::AuditEntry.where(store: store, action: 'station_route.create').count).to eq(1)

      first_body = response.parsed_body
      setup!(owner, shop('quan_an', answers: { has_tables: true }), key: key)
      expect(response.parsed_body).to eq(first_body)
      expect(Spree::Pos::StationRoute.where(branch: branch).count).to eq(1)
    end

    it 'keeps an eatery without tables as wave one set it up' do
      owner = staff_with(%w[write_pos_topology])
      data = setup!(owner, shop('quan_an', answers: { has_tables: false }))['data']
      expect(response).to have_http_status(:created)
      expect(data['modules']).to include('fnb.tables' => false, 'resources' => false, 'fnb.menu' => true)
      expect(data['table_service']).to be_nil
      branch = Spree::Pos::Branch.find_by_prefix_id!(data.dig('branch', 'id'))
      expect(branch.table_register).to be_nil
      expect(Spree::Pos::StationRoute.where(branch: branch)).to be_empty
    end

    it 'sets a restaurant up with tables, the suggested service charge and the default kitchen without the shop step' do
      owner = staff_with(%w[write_pos_topology])
      data = setup!(owner, shop('nha_hang', fnb_setup: nil))['data']
      expect(response).to have_http_status(:created)
      branch = Spree::Pos::Branch.find_by_prefix_id!(data.dig('branch', 'id'))
      expect(branch).to have_attributes(profile_key: 'nha_hang', kitchen_send_trigger: 'manual', service_charge_rate: 5)
      expect(branch.table_register).to be_present
      expect(Spree::Pos::KitchenStation.where(branch: branch).order(:position).pluck(:name, :kind, :is_default)).
        to eq([['Bếp', 'prep', true], ['Bar', 'bar', false]])
      expect(data['table_service']['stations'].pluck('name')).to eq(%w[Bếp Bar])
      expect(data['modules']).to include('fnb.tables' => true, 'fnb.service_charge' => true)
    end

    it 'needs a register for table orders and refuses a tables answer the profile cannot take' do
      owner = staff_with(%w[write_pos_topology])
      expect(reason_of(setup!(owner, shop('bar_pub_club', register: nil)))).to eq('table_register_missing')
      expect(reason_of(setup!(owner, shop('quan_an', register: nil, answers: { has_tables: true })))).to eq('table_register_missing')
      expect(reason_of(setup!(owner, shop('cafe_tra_sua', answers: { has_tables: true })))).to eq('answers_invalid')
      expect(reason_of(setup!(owner, shop('quan_an', answers: { has_tables: 'often' })))).to eq('answers_invalid')
      expect(response).to have_http_status(:conflict)
      expect(Spree::Pos::Branch.for_store(store)).to be_empty
    end
  end
end
