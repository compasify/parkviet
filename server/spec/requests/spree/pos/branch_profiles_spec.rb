# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_trace_helpers'

# Changing a branch's industry profile: the preview is a diff that changes
# nothing, the change applies only what was picked (D7), guards against a
# concurrent change, and the store's main profile only sets the default of
# new branches.
RSpec.describe 'POS branch profiles', type: :request, pos_modules: :default do
  include PosTraceHelpers

  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:manager) { staff_with(%w[write_pos_topology]) }
  let(:branch) do
    create(:pos_branch, store: store, lot_selection: 'cashier_pick', return_window_days: 30).tap do |row|
      %w[retail.units retail.measured retail.traceability].each do |key|
        Spree::Pos::BranchModule.create!(store: store, branch: row, module_key: key, enabled: true, reason: 'backfill')
      end
    end
  end

  def staff_with(permissions, target_store = store)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: target_store, permissions: permissions)
    create(:role_user, user: user, role: role)
    user
  end

  def call(user, verb, path, body = {})
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
      response.parsed_body.fetch('token')
    end
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{@tokens[user.id]}" }, params: body, as: :json)
    response.parsed_body
  end

  def preview(user, profile_key, at: branch)
    call(user, :post, "branches/#{at.prefixed_id}/profile/preview", profile_key: profile_key)
  end

  def apply(user, profile_key, expected: 'khac', at: branch, **body)
    call(user, :put, "branches/#{at.prefixed_id}/profile",
         { profile_key: profile_key, expected_profile_key: expected, reason: 'Chuyển sang nhà thuốc' }.merge(body))
  end

  def tracked_product
    product = create(:product, store: store, status: 'active')
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    track_variant!(store, product.default_variant, 'serial')
    enroll_serials!(branch, product.default_variant, %w[S1 S2], opened_by: manager)
    product
  end

  it 'previews the diff of a profile change without changing anything' do
    tracked_product
    data = preview(manager, 'nha_thuoc')['data']
    expect(response).to have_http_status(:ok)
    expect(data).to include('branch_id' => branch.prefixed_id, 'from' => 'khac', 'to' => 'nha_thuoc', 'profile_version' => 1)
    expect(data['modules']).to eq('enable' => [], 'disable' => ['retail.measured'],
                                  'in_use' => { 'retail.measured' => { 'measured_variants' => 0, 'labelled_variants' => 0, 'label_formats' => 0 } })
    # return_window_days 30 differs from 7, lot_selection cashier_pick from fefo.
    expect(data['defaults']).to contain_exactly({ 'field' => 'return_window_days', 'current' => 30, 'profile' => 7 },
                                                { 'field' => 'lot_selection', 'current' => 'cashier_pick', 'profile' => 'fefo' })
    # `chai` is a default unit the store already has.
    expect(data['sample_units']).to contain_exactly('vien', 'vi', 'hop')
    expect(data['recommended_features']).to eq([]) # every feature is on in specs

    thoi_trang = preview(manager, 'thoi_trang')['data']
    expect(thoi_trang['modules']['disable']).to eq(%w[retail.units retail.measured retail.traceability])
    expect(thoi_trang['modules']['in_use']['retail.traceability']).to eq('tracked_variants' => 1, 'open_lots' => 0, 'serials_in_stock' => 2)
    expect(thoi_trang['modules']['in_use']['retail.units']).to eq('converted_variants' => 0)

    expect(preview(manager, 'karaoke_bida').dig('error', 'details', 'reason')).to eq('profile_unavailable')
    expect(preview(manager, 'tiem_vang').dig('error', 'details', 'reason')).to eq('profile_unknown')
    expect(branch.reload).to have_attributes(profile_key: 'khac', lot_selection: 'cashier_pick', return_window_days: 30)
    expect(Spree::Pos::UnitDefinition.for_store(store).where(code: 'vien')).to be_empty
    expect(Spree::Pos::AuditEntry.where(action: %w[branch_profile.change branch_module.change])).to be_empty

    preview(staff_with(%w[read_pos_topology]), 'nha_thuoc')
    expect(response).to have_http_status(:ok)
    preview(staff_with(%w[read_pos_orders]), 'nha_thuoc')
    expect(response).to have_http_status(:forbidden)
  end

  it 'applies only the picked defaults and, when asked, the profile modules' do
    tracked_product
    data = apply(manager, 'nha_thuoc', apply_modules: true, apply_defaults: ['lot_selection'])['data']
    expect(response).to have_http_status(:ok)
    expect(branch.reload).to have_attributes(profile_key: 'nha_thuoc', profile_version: 1, lot_selection: 'fefo', return_window_days: 30)
    expect(data['modules']).to eq('retail.units' => true, 'retail.measured' => false, 'retail.traceability' => true, 'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false)
    expect(data['applied']).to eq(
      'modules' => { 'enabled' => [], 'disabled' => ['retail.measured'] },
      'defaults' => [{ 'field' => 'lot_selection', 'from' => 'cashier_pick', 'to' => 'fefo' }],
      'sample_units' => %w[vien vi hop]
    )
    expect(Spree::Pos::UnitDefinition.for_store(store).pluck(:code)).to include('vien', 'vi', 'hop', 'chai')
    audit = Spree::Pos::AuditEntry.find_by!(action: 'branch_profile.change')
    expect(audit.metadata).to include('from' => 'khac', 'to' => 'nha_thuoc', 'reason' => 'Chuyển sang nhà thuốc',
                                      'modules' => { 'enabled' => [], 'disabled' => ['retail.measured'] })
    expect(Spree::Pos::AuditEntry.where(action: 'branch_module.change').map { |row| row.metadata.slice('module', 'to', 'profile_key') }).
      to eq([{ 'module' => 'retail.measured', 'to' => false, 'profile_key' => 'nha_thuoc' }])

    # Another change based on the old profile is refused; nothing moves.
    body = apply(manager, 'thoi_trang', expected: 'khac', apply_modules: true)
    expect(response).to have_http_status(:conflict)
    expect(body.dig('error', 'details')).to include('reason' => 'profile_conflict', 'current_profile_key' => 'nha_thuoc')
    expect(branch.reload.profile_key).to eq('nha_thuoc')

    # Without apply_modules the modules stay as they are, even for a profile with none.
    data = apply(manager, 'thoi_trang', expected: 'nha_thuoc')['data']
    expect(data['modules']).to eq('retail.units' => true, 'retail.measured' => false, 'retail.traceability' => true, 'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false)
    expect(data['applied']).to include('modules' => { 'enabled' => [], 'disabled' => [] }, 'defaults' => [])
    expect(branch.reload).to have_attributes(profile_key: 'thoi_trang', return_window_days: 30)

    # Turning modules off for a profile never touches the SKU configured with them.
    apply(manager, 'thoi_trang', expected: 'thoi_trang', apply_modules: true)
    expect(Spree::Pos::ModulePolicy.for_branch(branch).values).to all(be(false))
    expect(Spree::Pos::VariantUnit.where(store: store, tracked_mode: 'serial').count).to eq(1)
    expect(Spree::Pos::SerialUnit.where(status: 'in_stock').count).to eq(2)

    data = apply(manager, 'tap_hoa_sieu_thi', expected: 'thoi_trang', apply_modules: true)['data']
    expect(data['applied']['modules']).to eq('enabled' => %w[retail.units retail.measured retail.traceability], 'disabled' => [])
  end

  it 'refuses unknown defaults, coming-soon profiles, a missing reason and non-managers' do
    expect(apply(manager, 'nha_thuoc', apply_defaults: ['variance_threshold']).dig('error', 'details', 'reason')).to eq('default_invalid')
    expect(apply(manager, 'nha_thuoc', apply_defaults: ['name']).dig('error', 'details', 'reason')).to eq('default_invalid')
    expect(apply(manager, 'bar_pub_club').dig('error', 'details', 'reason')).to eq('profile_unavailable')
    expect(apply(manager, 'nha_thuoc', reason: '').dig('error', 'details', 'reason')).to eq('reason_required')
    expect(apply(manager, 'nha_thuoc', expected: nil).dig('error', 'details', 'reason')).to eq('profile_conflict')
    expect(branch.reload.profile_key).to eq('khac')

    lead = staff_with(%w[read_pos_orders read_pos_topology])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: lead, capabilities: [Spree::Pos::Capabilities::MANAGE],
                                        status: 'active')
    apply(lead, 'nha_thuoc')
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('error', 'details', 'required_permission')).to eq('write_pos_topology')
    foreign = create(:pos_branch, store: create(:store))
    apply(manager, 'nha_thuoc', at: foreign)
    expect(response).to have_http_status(:not_found)
    expect(Spree::Pos::AuditEntry.where(action: 'branch_profile.change')).to be_empty
  end

  describe 'PUT store_profile' do
    it 'changes the default of new branches only, audited when something changes' do
      branch
      Spree::Pos::StoreProfile.create!(store: store, profile_key: 'khac', onboarded_at: 1.day.ago)
      modules_before = Spree::Pos::ModulePolicy.for_branch(branch)
      data = call(manager, :put, 'store_profile', profile_key: 'nha_thuoc', wholesale: true, interests: ['bar_pub_club'], reason: 'Đổi ngành')['data']
      expect(response).to have_http_status(:ok)
      expect(data).to include('profile_key' => 'nha_thuoc', 'wholesale' => true, 'interests' => ['bar_pub_club'], 'changed_by_id' => manager.prefixed_id)
      expect(branch.reload.profile_key).to eq('khac')
      expect(Spree::Pos::ModulePolicy.for_branch(branch)).to eq(modules_before)
      audit = Spree::Pos::AuditEntry.find_by!(action: 'store_profile.change')
      expect(audit.metadata).to include('from' => include('profile_key' => 'khac'), 'to' => include('profile_key' => 'nha_thuoc'),
                                        'reason' => 'Đổi ngành')

      call(manager, :put, 'store_profile', profile_key: 'nha_thuoc', reason: 'Lặp lại')
      expect(response).to have_http_status(:ok)
      expect(Spree::Pos::AuditEntry.where(action: 'store_profile.change').count).to eq(1)

      location = create(:stock_location, store: store, backorderable_default: false)
      created = call(manager, :post, 'branches', name: 'Mới', code: 'moi', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: location.prefixed_id)
      expect(created['data']).to include('profile_key' => 'nha_thuoc', 'return_window_days' => 7, 'lot_selection' => 'fefo')

      expect(call(manager, :put, 'store_profile', profile_key: 'karaoke_bida', reason: 'x').dig('error', 'details', 'reason')).
        to eq('profile_unavailable')
      expect(call(manager, :put, 'store_profile', profile_key: 'khac', interests: ['khac'], reason: 'x').dig('error', 'details', 'reason')).
        to eq('interest_invalid')
      expect(call(manager, :put, 'store_profile', profile_key: 'khac').dig('error', 'details', 'reason')).to eq('reason_required')
      call(staff_with(%w[read_pos_topology]), :put, 'store_profile', profile_key: 'khac', reason: 'x')
      expect(response).to have_http_status(:forbidden)
      expect(Spree::Pos::StoreProfile.find_by!(store: store).profile_key).to eq('nha_thuoc')
    end

    it 'sends a store that was never set up to onboarding, and gives a running store without one its profile' do
      expect(call(manager, :put, 'store_profile', profile_key: 'khac', reason: 'x').dig('error', 'details', 'reason')).to eq('onboarding_required')
      expect(Spree::Pos::StoreProfile.where(store: store)).to be_empty

      branch
      data = call(manager, :put, 'store_profile', profile_key: 'me_be', reason: 'Bổ sung')['data']
      expect(response).to have_http_status(:ok)
      expect(data).to include('profile_key' => 'me_be', 'wholesale' => false, 'interests' => [])
      expect(data['onboarded_at']).to be_present
      expect(Spree::Pos::AuditEntry.find_by!(action: 'store_profile.change').metadata).to include('from' => nil)
    end

    it 'clears every interest with an empty list or null and keeps them when the field is left out' do
      branch
      Spree::Pos::StoreProfile.create!(store: store, profile_key: 'khac', interests: %w[bar_pub_club karaoke_bida], onboarded_at: 1.day.ago)

      data = call(manager, :put, 'store_profile', profile_key: 'khac', reason: 'Giữ nguyên')['data']
      expect(data['interests']).to eq(%w[bar_pub_club karaoke_bida])

      # JSON `[]` must reach the workflow as an empty list, not as nil (left out).
      data = call(manager, :put, 'store_profile', profile_key: 'khac', interests: [], reason: 'Bỏ hết')['data']
      expect(response).to have_http_status(:ok)
      expect(data['interests']).to eq([])
      expect(Spree::Pos::StoreProfile.find_by!(store: store).interests).to eq([])
      audit = Spree::Pos::AuditEntry.where(action: 'store_profile.change').order(:id).last
      expect(audit.metadata).to include('from' => include('interests' => %w[bar_pub_club karaoke_bida]), 'to' => include('interests' => []),
                                        'reason' => 'Bỏ hết')

      # An explicit `null` clears too (the key is there); only leaving it out keeps them.
      call(manager, :put, 'store_profile', profile_key: 'khac', interests: %w[bar_pub_club], reason: 'Lại')
      data = call(manager, :put, 'store_profile', profile_key: 'khac', interests: nil, reason: 'Null')['data']
      expect(data['interests']).to eq([])
    end
  end
end
