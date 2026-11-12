# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# Module switches per branch: dependencies turn on together, a module that
# another needs stays on, every change is audited once, and a branch's own
# topology manager may switch its branch only.
RSpec.describe 'POS branch modules', type: :request, pos_modules: :default do
  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:branch) { create(:pos_branch, store: store) }
  let(:other_branch) { create(:pos_branch, store: store) }

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

  def switch(user, key, enabled, at: branch, reason: 'Bật theo nhu cầu')
    put "/api/v3/admin/pos/branches/#{at.prefixed_id}/modules/#{key}",
        headers: { 'Authorization' => "Bearer #{token_for(user)}" }, params: { enabled: enabled, reason: reason }, as: :json
    response.parsed_body
  end

  def changes
    Spree::Pos::AuditEntry.where(action: 'branch_module.change').order(:id).map { |row| row.metadata.slice('module', 'from', 'to') }
  end

  it 'turns on what a module needs and keeps a needed module on' do
    manager = staff_with(%w[write_pos_topology])
    data = switch(manager, 'retail.measured', true)['data']
    expect(response).to have_http_status(:ok)
    expect(data).to include('module' => 'retail.measured', 'enabled' => true, 'changed' => true, 'also_enabled' => ['retail.units'])
    expect(data['modules']).to eq('retail.units' => true, 'retail.measured' => true, 'retail.traceability' => false, 'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false, 'resources' => false, 'fnb.tables' => false, 'fnb.postpay' => false, 'fnb.service_charge' => false,
                                     'fnb.reservations' => false, 'fnb.bottle_keep' => false, 'fnb.pour_tracking' => false, 'fnb.meal_accounts' => false, 'fnb.vehicle_commission' => false, 'timed_billing' => false)
    expect(Spree::Pos::BranchModule.find_by!(branch: branch, module_key: 'retail.units')).
      to have_attributes(enabled: true, reason: 'Bật theo nhu cầu', changed_by_id: manager.id)
    expect(changes).to eq([{ 'module' => 'retail.units', 'from' => false, 'to' => true },
                           { 'module' => 'retail.measured', 'from' => false, 'to' => true }])
    expect(Spree::Pos::AuditEntry.where(action: 'branch_module.change').first.metadata).to include('required_by' => 'retail.measured')

    body = switch(manager, 'retail.units', false)
    expect(response).to have_http_status(:conflict)
    expect(body.dig('error', 'details')).to include('reason' => 'module_required_by', 'module' => 'retail.units',
                                                    'required_by' => ['retail.measured'])
    expect(Spree::Pos::ModulePolicy.enabled?(branch, 'retail.units')).to be(true)

    # The same value again changes and audits nothing.
    expect(switch(manager, 'retail.measured', true)['data']).to include('changed' => false, 'also_enabled' => [])
    expect(changes.size).to eq(2)

    switch(manager, 'retail.measured', false)
    switch(manager, 'retail.units', false)
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::ModulePolicy.for_branch(branch).values).to all(be(false))
    expect(changes.last(2)).to eq([{ 'module' => 'retail.measured', 'from' => true, 'to' => false },
                                   { 'module' => 'retail.units', 'from' => true, 'to' => false }])
    # Turning off what is already off writes no row.
    switch(manager, 'retail.traceability', false)
    expect(response).to have_http_status(:ok)
    expect(Spree::Pos::BranchModule.where(branch: branch, module_key: 'retail.traceability')).to be_empty

    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/modules", headers: { 'Authorization' => "Bearer #{token_for(manager)}" }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'modules')).to eq('retail.units' => false, 'retail.measured' => false, 'retail.traceability' => false,
                                                              'fnb.menu' => false, 'fnb.recipes' => false, 'fnb.kitchen' => false, 'fnb.order_number' => false, 'fnb.cup_label' => false, 'fnb.delivery_platforms' => false, 'resources' => false, 'fnb.tables' => false, 'fnb.postpay' => false, 'fnb.service_charge' => false,
                                     'fnb.reservations' => false, 'fnb.bottle_keep' => false, 'fnb.pour_tracking' => false, 'fnb.meal_accounts' => false, 'fnb.vehicle_commission' => false, 'timed_billing' => false)
    expect(response.parsed_body.dig('data', 'settings').map { |row| row['module'] }).to eq(%w[retail.measured retail.units])
  end

  it 'needs a known, available module, a boolean and a reason' do
    manager = staff_with(%w[write_pos_topology])
    expect(switch(manager, 'retail.teleport', true).dig('error', 'details', 'reason')).to eq('module_unknown')
    expect(switch(manager, with_planned_module('fnb.planned_example'), true).dig('error', 'details', 'reason')).to eq('module_unavailable')
    expect(switch(manager, 'retail.units', 'yes').dig('error', 'details', 'reason')).to eq('module_value_invalid')
    expect(switch(manager, 'retail.units', true, reason: ' ').dig('error', 'details', 'reason')).to eq('reason_required')
    expect(switch(manager, 'retail.units', true, reason: 'x' * 201).dig('error', 'details', 'reason')).to eq('reason_invalid')
    expect(response).to have_http_status(:conflict)
    expect(Spree::Pos::BranchModule.where(branch: branch)).to be_empty
    expect(changes).to be_empty
  end

  it 'lets a branch topology manager switch their own branch only' do
    lead = staff_with(%w[read_pos_orders])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: lead, capabilities: [Spree::Pos::Capabilities::MANAGE],
                                        status: 'active')
    Spree::Pos::StaffMembership.create!(store: store, branch: other_branch, staff: lead,
                                        capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active')

    switch(lead, 'retail.traceability', true)
    expect(response).to have_http_status(:ok)
    switch(lead, 'retail.traceability', false)
    expect(response).to have_http_status(:ok)
    get "/api/v3/admin/pos/branches/#{branch.prefixed_id}/modules", headers: { 'Authorization' => "Bearer #{token_for(lead)}" }
    expect(response).to have_http_status(:ok)

    switch(lead, 'retail.traceability', true, at: other_branch)
    expect(response).to have_http_status(:forbidden)
    get "/api/v3/admin/pos/branches/#{other_branch.prefixed_id}/modules", headers: { 'Authorization' => "Bearer #{token_for(lead)}" }
    expect(response).to have_http_status(:forbidden)
    expect(Spree::Pos::BranchModule.where(branch: other_branch)).to be_empty

    cashier = staff_with(%w[read_pos_orders write_pos_orders])
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: cashier, capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT],
                                        status: 'active')
    switch(cashier, 'retail.units', true)
    expect(response).to have_http_status(:forbidden)

    switch(staff_with(%w[read_orders]), 'retail.units', true)
    expect(response).to have_http_status(:forbidden)

    foreign_store = create(:store)
    foreign = create(:pos_branch, store: foreign_store)
    switch(staff_with(%w[write_pos_topology]), 'retail.units', true, at: foreign)
    expect(response).to have_http_status(:not_found)
    expect(Spree::Pos::BranchModule.where(branch: foreign)).to be_empty
  end
end
