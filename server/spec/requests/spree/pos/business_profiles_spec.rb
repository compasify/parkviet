# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# Read side of industry profiles: the catalog every POS session reads, the
# store profile topology staff read, and what the context adds (modules,
# branch profile, first-run setup).
RSpec.describe 'POS business profiles', type: :request do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }

  def staff_with(permissions, target_store = store)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: target_store, permissions: permissions)
    create(:role_user, user: user, role: role)
    user
  end

  def get_pos(user, path, params = {})
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
      response.parsed_body.fetch('token')
    end
    get "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{@tokens[user.id]}" }, params: params
    response.parsed_body
  end

  def branch_for(target_store, code: "b#{SecureRandom.hex(3)}", status: 'active')
    location = create(:stock_location, store: target_store, backorderable_default: false)
    Spree::Pos::Branch.create!(store: target_store, stock_location: location, name: code, code: code,
                               timezone: 'Asia/Ho_Chi_Minh', status: status)
  end

  describe 'GET business_profiles' do
    it 'serves the catalog to any POS session, including cashiers without topology rights' do
      data = get_pos(staff_with(%w[read_pos_orders]), 'business_profiles')['data']
      expect(response).to have_http_status(:ok)
      expect(data['version']).to eq(1)
      expect(data['profiles'].size).to eq(19)
      expect(data['profiles'].map { |row| row['status'] }.tally).to eq('available' => 13, 'coming_soon' => 6)
      expect(data['profiles'].select { |row| row['group'] == 'fnb' }.map { |row| row['status'] }).to all(eq('coming_soon'))
      pharmacy = data['profiles'].find { |row| row['key'] == 'nha_thuoc' }
      expect(pharmacy).to eq(
        'key' => 'nha_thuoc', 'group' => 'retail', 'order' => 6, 'status' => 'available',
        'modules' => %w[retail.units retail.traceability], 'branch_defaults' => { 'return_window_days' => 7, 'lot_selection' => 'fefo' },
        'display' => { 'catalog_view' => 'list' }, 'recommended_features' => %w[traceability returns refunds],
        'sample_units' => %w[vien vi hop chai]
      )
      expect(data['modules']).to include(
        { 'key' => 'retail.measured', 'group' => 'retail', 'status' => 'available', 'depends_on' => ['retail.units'] },
        { 'key' => 'timed_billing', 'group' => 'fnb', 'status' => 'planned', 'depends_on' => [] }
      )

      get_pos(staff_with(%w[write_pos_topology]), 'business_profiles')
      expect(response).to have_http_status(:ok)
    end

    it 'refuses staff without a POS permission' do
      get_pos(staff_with(%w[read_orders]), 'business_profiles')
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET store_profile' do
    it 'returns null before the setup and the store row after, to topology staff only' do
      reader = staff_with(%w[read_pos_topology])
      expect(get_pos(reader, 'store_profile')).to eq('data' => nil)
      expect(response).to have_http_status(:ok)

      other_store = create(:store)
      foreign = Spree::Pos::StoreProfile.create!(store: other_store, profile_key: 'thoi_trang', onboarded_at: Time.current)
      expect(get_pos(reader, 'store_profile')).to eq('data' => nil)
      expect(response.body).not_to include(foreign.prefixed_id)

      writer = staff_with(%w[write_pos_topology])
      own = Spree::Pos::StoreProfile.create!(store: store, profile_key: 'nha_thuoc', interests: ['cafe_tra_sua'],
                                             onboarded_at: Time.current, changed_by: writer)
      data = get_pos(writer, 'store_profile')['data']
      expect(data).to include('id' => own.prefixed_id, 'profile_key' => 'nha_thuoc', 'profile_version' => 1, 'wholesale' => false,
                              'interests' => ['cafe_tra_sua'], 'changed_by_id' => writer.prefixed_id)
      expect(data['onboarded_at']).to be_present
      expect(get_pos(reader, 'store_profile').dig('data', 'id')).to eq(own.prefixed_id)
    end

    it 'refuses cashiers and staff of another store' do
      get_pos(staff_with(%w[read_pos_orders write_pos_orders]), 'store_profile')
      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('read_pos_topology')

      other_store = create(:store)
      Spree::Pos::StoreProfile.create!(store: store, profile_key: 'khac')
      outsider = staff_with(%w[read_pos_topology write_pos_topology], other_store)
      body = get_pos(outsider, 'store_profile')
      expect(response.status).to be_in([401, 403, 404])
      expect(body.to_json).not_to include('posstoreprof_')
    end
  end

  describe 'GET context' do
    it 'asks for the first-run setup only while the store has neither a store profile nor an active branch' do
      writer = staff_with(%w[write_pos_topology])
      reader = staff_with(%w[read_pos_topology])
      cashier = staff_with(%w[read_pos_orders])

      context = get_pos(writer, 'context')
      expect(context['onboarding']).to eq('required' => true, 'can_setup' => true)
      expect(context['modules']).to eq({})
      expect(context['profile']).to be_nil
      expect(get_pos(reader, 'context')['onboarding']).to eq('required' => true, 'can_setup' => false)
      expect(get_pos(cashier, 'context')['onboarding']).to eq('required' => true, 'can_setup' => false)

      disabled = branch_for(store, status: 'disabled')
      expect(get_pos(writer, 'context').dig('onboarding', 'required')).to be(true)
      disabled.update!(status: 'active')
      expect(get_pos(writer, 'context').dig('onboarding', 'required')).to be(false)
      disabled.update!(status: 'disabled')
      Spree::Pos::StoreProfile.create!(store: store, profile_key: 'khac')
      expect(get_pos(writer, 'context').dig('onboarding', 'required')).to be(false)
    end

    it 'shows the modules and profile of the selected branch', pos_modules: :default do
      writer = staff_with(%w[write_pos_topology])
      branch = branch_for(store)
      Spree::Pos::BranchModule.create!(store: store, branch: branch, module_key: 'retail.units', enabled: true, reason: 'spec')

      context = get_pos(writer, 'context', branch_id: branch.prefixed_id)
      expect(response).to have_http_status(:ok)
      expect(context['modules']).to eq('retail.units' => true, 'retail.measured' => false, 'retail.traceability' => false)
      expect(context['profile']).to eq('key' => 'khac', 'version' => 1, 'display' => { 'catalog_view' => 'cards' })
      expect(context['branches'].find { |row| row['id'] == branch.prefixed_id }).
        to include('profile_key' => 'khac', 'profile_version' => 1)

      branch.update!(profile_key: 'nha_thuoc')
      expect(get_pos(writer, 'context', branch_id: branch.prefixed_id)['profile']).
        to eq('key' => 'nha_thuoc', 'version' => 1, 'display' => { 'catalog_view' => 'list' })
      # A key the catalog no longer lists is reported as it is, with no hints.
      branch.update!(profile_key: 'retired_profile')
      expect(get_pos(writer, 'context', branch_id: branch.prefixed_id)['profile']).
        to eq('key' => 'retired_profile', 'version' => 1, 'display' => {})
      expect(get_pos(writer, "branches/#{branch.prefixed_id}")['data']).to include('profile_key' => 'retired_profile')
    end

    # Settled question 4 of plan.md: a branch with traceability off still
    # receives stock for SKUs tracked before, so the client needs to know the
    # store still has such SKUs. Store-wide, whatever the branch modules say.
    it 'tells whether the store still has tracked SKUs, whatever the branch modules say', pos_modules: :default do
      writer = staff_with(%w[write_pos_topology])
      branch = branch_for(store)
      usage = -> { get_pos(writer, 'context', branch_id: branch.prefixed_id)['module_usage'] }
      expect(usage.call).to eq('retail.traceability' => false)
      expect(get_pos(writer, 'context')['module_usage']).to eq('retail.traceability' => false)

      unit_for = lambda do |target_store, mode, status: 'active'|
        product = create(:product, store: target_store)
        Spree::Pos::UnitDefinition.ensure_defaults!(target_store)
        unit = Spree::Pos::UnitDefinition.find_by!(store: target_store, code: 'item')
        Spree::Pos::VariantUnit.create!(store: target_store, variant: product.default_variant, sale_unit: unit, base_unit: unit,
                                        price_unit: unit, ratio_numerator: 1, ratio_denominator: 1, tracked_mode: mode,
                                        status: status, version: 1)
      end
      unit_for.call(store, 'none')
      unit_for.call(store, 'lot', status: 'inactive')
      unit_for.call(create(:store), 'serial')
      expect(usage.call).to eq('retail.traceability' => false)

      tracked = unit_for.call(store, 'serial')
      expect(Spree::Pos::ModulePolicy.enabled?(branch, 'retail.traceability')).to be(false)
      expect(usage.call).to eq('retail.traceability' => true)
      expect(get_pos(writer, 'context')['module_usage']).to eq('retail.traceability' => true)

      # A deleted variant no longer counts.
      tracked.variant.update_column(:deleted_at, Time.current)
      expect(usage.call).to eq('retail.traceability' => false)
    end

    # Plan phase 5: `modules` costs one query for the selected branch, and the
    # context does not grow with branches, modules or tracked SKUs.
    it 'reads modules, module usage, profile and onboarding in a fixed number of queries' do
      writer = staff_with(%w[write_pos_topology])
      branch = branch_for(store)
      Spree::Pos::StoreProfile.create!(store: store, profile_key: 'khac', onboarded_at: Time.current)
      get_pos(writer, 'context', branch_id: branch.prefixed_id) # sign in and warm up
      measure = lambda do
        queries = []
        counter = lambda do |*, payload|
          next if payload[:name] == 'SCHEMA' || payload[:sql].start_with?('BEGIN', 'COMMIT', 'SAVEPOINT', 'RELEASE')

          queries << payload[:sql]
        end
        ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
          get_pos(writer, 'context', branch_id: branch.prefixed_id)
        end
        expect(response).to have_http_status(:ok)
        { total: queries.size,
          # Branch#to_pos reads each listed branch's stock location (up to
          # 100 branches); older than the profiles and not counted here.
          locations: queries.count { |sql| sql.include?('FROM "spree_stock_locations"') },
          modules: queries.count { |sql| sql.include?('spree_pos_branch_modules') },
          usage: queries.count { |sql| sql.include?('spree_pos_variant_units') },
          onboarding: queries.count { |sql| sql.include?('spree_pos_store_profiles') } }
      end
      one = measure.call

      # Five more branches with every module on, and tracked SKUs.
      5.times { branch_for(store) }
      Spree::Pos::UnitDefinition.ensure_defaults!(store)
      unit = Spree::Pos::UnitDefinition.find_by!(store: store, code: 'item')
      3.times do
        variant = create(:product, store: store).default_variant
        Spree::Pos::VariantUnit.create!(store: store, variant: variant, sale_unit: unit, base_unit: unit, price_unit: unit,
                                        ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'serial', status: 'active', version: 1)
      end
      many = measure.call

      expect(one).to include(modules: 1, usage: 1, onboarding: 1)
      expect(many).to include(modules: 1, usage: 1, onboarding: 1)
      expect(many[:total] - many[:locations]).to eq(one[:total] - one[:locations])
    end
  end
end
