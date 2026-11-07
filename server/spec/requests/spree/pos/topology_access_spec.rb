# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'

# Guessed IDs, membership re-checks, disable/recovery history and
# action-bound approvals for branch, register and shift administration.
RSpec.describe 'POS topology access', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { Spree::Store.default }
  let(:password) { 'secret123' }
  let(:manager) { staff_with(%w[write_pos_topology read_pos_orders]) }
  let(:cashier) { staff_with(%w[read_pos_orders write_pos_orders write_pos_workspaces write_pos_shifts]) }
  let(:branch) { branch_for(store, 'main') }
  let(:register) { Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quay 1', code: 'q1', status: 'active') }
  let!(:cashier_membership) do
    Spree::Pos::StaffMembership.create!(
      store: store, branch: branch, staff: cashier,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active'
    )
  end

  def login_as(user)
    post '/api/v3/admin/auth/login', params: { email: user.email, password: password }, as: :json
    response.parsed_body.fetch('token')
  end

  def headers_for(user)
    { 'Authorization' => "Bearer #{login_as(user)}" }
  end

  def staff_with(permissions, target_store = store)
    user = create(:admin_user, :without_admin_role, password: password)
    role = create(:role, resource: target_store, permissions: permissions)
    create(:role_user, user: user, role: role)
    user
  end

  def branch_for(target_store, code)
    Spree::Pos::Branch.create!(
      store: target_store,
      stock_location: create(:stock_location, store: target_store, backorderable_default: false),
      name: "Branch #{code}", code: code, timezone: 'Asia/Ho_Chi_Minh', status: 'active'
    )
  end

  def open_workspace(key)
    Spree::Pos::Shifts::Open.call(store: store, staff: cashier, register: register, opening_float: '0') unless
      Spree::Pos::Shift.open_now.exists?(register_id: register.id)
    result = Spree::Pos::Workspaces::Create.call(
      store: store, staff: cashier, register_id: register.prefixed_id, key: key, editor_id: SecureRandom.uuid
    )
    Spree::Pos::Workspace.find_by_prefix_id!(result['id'])
  end

  describe 'records of another store' do
    let(:other) { create(:store) }
    let(:foreign_branch) { branch_for(other, 'far') }
    let(:foreign_register) { Spree::Pos::Register.create!(store: other, branch: foreign_branch, name: 'Far', code: 'far', status: 'active') }
    let(:foreign_staff) { staff_with(%w[read_pos_orders], other) }
    let(:foreign_membership) do
      Spree::Pos::StaffMembership.create!(store: other, branch: foreign_branch, staff: foreign_staff, capabilities: [], status: 'active')
    end

    it 'answers guessed IDs as not found and changes nothing' do
      headers = headers_for(manager)

      [
        "/api/v3/admin/pos/branches/#{foreign_branch.prefixed_id}",
        "/api/v3/admin/pos/registers/#{foreign_register.prefixed_id}",
        "/api/v3/admin/pos/memberships/#{foreign_membership.prefixed_id}"
      ].each do |path|
        get path, headers: headers, as: :json
        expect(response).to have_http_status(:not_found), path
        patch path, headers: headers, params: { name: 'Taken', capabilities: [] }, as: :json
        expect(response).to have_http_status(:not_found), path
        post "#{path}/disable", headers: headers, as: :json
        expect(response).to have_http_status(:not_found), path
      end

      expect(foreign_branch.reload).to have_attributes(name: 'Branch far', status: 'active')
      expect(foreign_register.reload).to have_attributes(name: 'Far', status: 'active')
      expect(foreign_membership.reload.status).to eq('active')
      expect(Spree::Pos::AuditEntry.where(store_id: other.id)).not_to exist
    end

    it 'rejects incidental IDs from another store or branch' do
      headers = headers_for(manager)

      post '/api/v3/admin/pos/registers', headers: headers,
                                          params: { branch_id: foreign_branch.prefixed_id, name: 'X', code: 'x1' }, as: :json
      expect(response).to have_http_status(:not_found)

      membership_params = { branch_id: branch.prefixed_id, staff_id: foreign_staff.prefixed_id, capabilities: [] }
      post '/api/v3/admin/pos/memberships', headers: headers, params: membership_params, as: :json
      expect(response).to have_http_status(:not_found)
      expect(Spree::Pos::StaffMembership.where(staff: foreign_staff, store: store)).not_to exist

      get '/api/v3/admin/pos/context', headers: headers_for(cashier),
                                       params: { branch_id: branch.prefixed_id, register_id: foreign_register.prefixed_id }, as: :json
      expect(response).to have_http_status(:not_found)

      other_branch = branch_for(store, 'side')
      mismatched = { branch_id: other_branch.prefixed_id, register_id: register.prefixed_id, opening_float: '0' }
      post '/api/v3/admin/pos/shifts', headers: headers_for(cashier), params: mismatched, as: :json
      expect(response).to have_http_status(:forbidden)

      post '/api/v3/admin/pos/shifts', headers: headers_for(cashier),
                                       params: { register_id: foreign_register.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:not_found)
      expect(Spree::Pos::Shift.count).to eq(0)
    end
  end

  describe 'membership on every mutation' do
    it 'stops a cashier as soon as the membership is disabled or the capability is removed' do
      second = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quay 2', code: 'q2', status: 'active')
      third = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quay 3', code: 'q3', status: 'active')
      cashier_headers = headers_for(cashier)

      post '/api/v3/admin/pos/shifts', headers: cashier_headers, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:created)

      patch "/api/v3/admin/pos/memberships/#{cashier_membership.prefixed_id}", headers: headers_for(manager), params: { capabilities: [] }, as: :json
      expect(response).to have_http_status(:ok)
      post '/api/v3/admin/pos/shifts', headers: cashier_headers, params: { register_id: second.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:forbidden)

      cashier_membership.update!(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT])
      post "/api/v3/admin/pos/memberships/#{cashier_membership.prefixed_id}/disable", headers: headers_for(manager), as: :json
      expect(response).to have_http_status(:ok)
      post '/api/v3/admin/pos/shifts', headers: cashier_headers, params: { register_id: third.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:forbidden)

      expect(Spree::Pos::Shift.where(register_id: [second.id, third.id])).not_to exist
    end

    it 'refuses a shift on a disabled register or branch' do
      cashier_headers = headers_for(cashier)
      register.update!(status: 'disabled', disabled_at: Time.current)
      post '/api/v3/admin/pos/shifts', headers: cashier_headers, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:forbidden)

      register.update!(status: 'active', disabled_at: nil)
      branch.update!(status: 'disabled', disabled_at: Time.current)
      post '/api/v3/admin/pos/shifts', headers: cashier_headers, params: { register_id: register.prefixed_id, opening_float: '0' }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(Spree::Pos::Shift.count).to eq(0)
    end
  end

  describe 'disable and recovery history' do
    it 'keeps the first disable time and one audit entry when disabled twice' do
      headers = headers_for(manager)
      post "/api/v3/admin/pos/registers/#{register.prefixed_id}/disable", headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      first_time = register.reload.disabled_at

      travel 1.minute do
        post "/api/v3/admin/pos/registers/#{register.prefixed_id}/disable", headers: headers, as: :json
      end
      expect(response).to have_http_status(:ok)
      expect(register.reload.disabled_at).to eq(first_time)
      expect(Spree::Pos::AuditEntry.where(subject_type: register.class.name, subject_id: register.id, action: 'disable').count).to eq(1)
    end

    it 'lets only a member with the recovery capability re-enable, and records who did it' do
      post "/api/v3/admin/pos/branches/#{branch.prefixed_id}/disable", headers: headers_for(manager), as: :json
      expect(response).to have_http_status(:ok)

      post "/api/v3/admin/pos/branches/#{branch.prefixed_id}/enable", headers: headers_for(manager), as: :json
      expect(response).to have_http_status(:forbidden)
      expect(branch.reload.status).to eq('disabled')

      recoverer = staff_with(%w[write_pos_topology])
      Spree::Pos::StaffMembership.create!(
        store: store, branch: branch, staff: recoverer,
        capabilities: [Spree::Pos::Capabilities::RECOVER], status: 'active'
      )
      post "/api/v3/admin/pos/branches/#{branch.prefixed_id}/enable", headers: headers_for(recoverer), as: :json
      expect(response).to have_http_status(:ok)
      expect(branch.reload.status).to eq('active')
      entries = Spree::Pos::AuditEntry.where(subject_type: branch.class.name, subject_id: branch.id).order(:id)
      expect(entries.map { |entry| [entry.action, entry.actor_id] }).to eq([['disable', manager.id], ['enable', recoverer.id]])
    end

    it 'keeps a used register in its branch' do
      headers = headers_for(manager)
      side = branch_for(store, 'side')
      spare = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Spare', code: 'spare', status: 'active')

      patch "/api/v3/admin/pos/registers/#{spare.prefixed_id}", headers: headers, params: { branch_id: side.prefixed_id }, as: :json
      expect(response).to have_http_status(:ok)
      expect(spare.reload.branch).to eq(side)

      Spree::Pos::Shifts::Open.call(store: store, staff: cashier, register: register, opening_float: '0')
      patch "/api/v3/admin/pos/registers/#{register.prefixed_id}", headers: headers, params: { branch_id: side.prefixed_id }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(register.reload.branch).to eq(branch)
      expect(Spree::Pos::Shift.find_by!(register_id: register.id).branch).to eq(branch)
    end
  end

  describe 'context changes and existing drafts' do
    it 'does not move open drafts to another stock location' do
      headers = headers_for(manager)
      original = branch.stock_location
      replacement = create(:stock_location, store: store, backorderable_default: false)
      workspace = open_workspace('draft-location')

      patch "/api/v3/admin/pos/branches/#{branch.prefixed_id}", headers: headers, params: { stock_location_id: replacement.prefixed_id }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(branch.reload.stock_location).to eq(original)

      workspace.update_columns(operational_status: 'canceled')
      patch "/api/v3/admin/pos/branches/#{branch.prefixed_id}", headers: headers, params: { stock_location_id: replacement.prefixed_id }, as: :json
      expect(response).to have_http_status(:ok)
      expect(branch.reload.stock_location).to eq(replacement)
    end

    it 'keeps an existing draft on its branch and register' do
      workspace = open_workspace('draft-source')
      side = branch_for(store, 'side')

      expect(workspace.update(branch_id: side.id)).to be(false)
      expect(workspace.reload.branch).to eq(branch)
      expect(workspace.register).to eq(register)
    end
  end

  describe 'approvals' do
    let(:approver) { staff_with(%w[write_pos_topology]) }
    let!(:approver_membership) do
      Spree::Pos::StaffMembership.create!(
        store: store, branch: branch, staff: approver,
        capabilities: [Spree::Pos::Capabilities::APPROVE], status: 'active'
      )
    end
    let(:workspace) { open_workspace('approval-workspace') }

    def grant(headers, expires_at: 10.minutes.from_now, as_staff: cashier)
      post '/api/v3/admin/pos/approvals', headers: headers, params: {
        branch_id: branch.prefixed_id, workspace_id: workspace.prefixed_id, requester_id: as_staff.prefixed_id,
        action_name: 'pos.discount', amount: '5', revision: workspace.revision.to_s, expires_at: expires_at.iso8601
      }, as: :json
    end

    def consume(approval)
      approval.consume!(
        action: 'pos.discount', amount: BigDecimal('5'), currency: store.default_currency,
        revision: workspace.revision.to_s, subject: workspace, requester: cashier
      )
    end

    it 'refuses an approval that is already expired or outlives the technical window' do
      headers = headers_for(approver)
      grant(headers, expires_at: 1.minute.ago)
      expect(response).to have_http_status(:unprocessable_content)
      grant(headers, expires_at: Spree::Pos::Approval::MAX_TTL.from_now + 1.minute)
      expect(response).to have_http_status(:unprocessable_content)
      expect(Spree::Pos::Approval.count).to eq(0)
    end

    it 'refuses a grant from staff without the approve capability' do
      grant(headers_for(manager))
      expect(response).to have_http_status(:forbidden)
      expect(Spree::Pos::Approval.count).to eq(0)
    end

    it 'stops an approval at expiry' do
      grant(headers_for(approver), expires_at: 2.minutes.from_now)
      approval = Spree::Pos::Approval.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))

      # Expiry is judged on database time, so move the deadline rather than the app clock.
      approval.update_columns(expires_at: Spree::Pos::Workspace.database_now - 1.second)
      expect { consume(approval) }.to raise_error(Spree::Pos::Conflict)
      expect(approval.reload.status).to eq('active')
    end

    it 'revokes an active approval with audit and never rewrites a consumed one' do
      headers = headers_for(approver)
      grant(headers)
      revoked = Spree::Pos::Approval.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
      post "/api/v3/admin/pos/approvals/#{revoked.prefixed_id}/revoke", headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect { consume(revoked) }.to raise_error(Spree::Pos::Conflict)
      actions = Spree::Pos::AuditEntry.where(subject_type: revoked.class.name, subject_id: revoked.id).order(:id).pluck(:action)
      expect(actions).to eq(%w[approval.grant approval.revoke])

      grant(headers)
      used = Spree::Pos::Approval.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
      consume(used)
      post "/api/v3/admin/pos/approvals/#{used.prefixed_id}/revoke", headers: headers, as: :json
      expect(response).to have_http_status(:conflict)
      expect(used.reload).to have_attributes(status: 'consumed', revoked_at: nil)
      expect(Spree::Pos::AuditEntry.where(subject_type: used.class.name, subject_id: used.id, action: 'approval.revoke')).not_to exist
    end

    it 'stops an approval once the approver loses the capability' do
      grant(headers_for(approver))
      approval = Spree::Pos::Approval.find_by_prefix_id!(response.parsed_body.dig('data', 'id'))
      approver_membership.update!(capabilities: [])

      expect { consume(approval) }.to raise_error(Spree::Pos::Conflict)
      expect(approval.reload.status).to eq('active')
    end
  end
end
