# frozen_string_literal: true

require 'rails_helper'
require 'websocket/driver'
require_relative '../../../support/pos_credit_helpers'

RSpec.shared_context 'with realtime branches' do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:other_branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:device_token) { Spree::Pos::Device.new_token }
  let(:session_token) { Spree::Pos::DeviceStaffSession.new_token }
  let!(:device) do
    Spree::Pos::Device.create!(store: store, branch: branch, name: 'Waiter', mode: 'waiter', platform: 'android',
                               token_digest: Spree::Pos::Device.digest(device_token))
  end

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def open_staff_session(staff = cashier)
    Spree::Pos::DeviceStaffSession.create!(device: device, staff: staff, token_digest: Spree::Pos::DeviceStaffSession.digest(session_token),
                                           expires_at: 12.hours.from_now, last_active_at: Time.current)
  end

  def jwt_for(user, **overrides)
    claims = { user_id: user.id, user_type: 'admin', jti: SecureRandom.uuid, iss: 'spree', aud: 'admin_api',
               exp: 5.minutes.from_now.to_i }.merge(overrides)
    JWT.encode(claims, Spree::Pos::StaffTokenReader.new.send(:jwt_secret), 'HS256')
  end
end

RSpec.describe Spree::Pos::ApplicationCable::Connection, type: :channel do
  include_context 'with realtime branches'

  it 'is the configured connection class and has a single identifier' do
    expect(ActionCable.server.config.connection_class.call).to eq(described_class)
    expect(described_class.identifiers.to_a).to eq([:device_id])
  end

  describe 'staff with the Admin API JWT' do
    it 'connects with no device identifier, so it has no internal channel' do
      connect '/cable', params: { token: jwt_for(cashier) }

      expect(connection.kind).to eq(:staff)
      expect(connection.staff).to eq(cashier)
      expect(connection.device_id).to be_nil
      expect(connection.connection_identifier).to be_blank
    end

    it 'refuses a missing, malformed or wrongly signed token' do
      expect { connect '/cable' }.to have_rejected_connection
      expect { connect '/cable', params: { token: 'not-a-jwt' } }.to have_rejected_connection
      forged = JWT.encode({ user_id: cashier.id, user_type: 'admin', iss: 'spree', aud: 'admin_api', exp: 5.minutes.from_now.to_i }, 'wrong', 'HS256')
      expect { connect '/cable', params: { token: forged } }.to have_rejected_connection
    end

    it 'refuses an expired token' do
      expect { connect '/cable', params: { token: jwt_for(cashier, exp: 1.minute.ago.to_i) } }.to have_rejected_connection
    end

    it 'refuses a token for another audience' do
      expect { connect '/cable', params: { token: jwt_for(cashier, aud: 'store_api') } }.to have_rejected_connection
    end

    it 'refuses a customer token' do
      customer = create(:user)
      expect { connect '/cable', params: { token: jwt_for(customer, user_type: 'customer') } }.to have_rejected_connection
    end

    it 'refuses a deactivated account' do
      token = jwt_for(cashier)
      allow_any_instance_of(Spree.admin_user_class).to receive(:deactivated?).and_return(true) # rubocop:disable RSpec/AnyInstance

      expect { connect '/cable', params: { token: token } }.to have_rejected_connection
    end
  end

  describe 'a paired device' do
    it 'connects by subprotocol, identified by its prefixed id' do
      connect '/cable', headers: { 'Sec-WebSocket-Protocol' => "actioncable-v1-json, pos-device.#{device_token}" }

      expect(connection.kind).to eq(:device)
      expect(connection.device).to eq(device)
      expect(connection.staff).to be_nil
      expect(connection.device_id).to eq(device.prefixed_id)
      expect(device.reload.last_seen_at).to be_present
    end

    it 'connects by query parameter' do
      connect '/cable', params: { device_token: device_token }

      expect(connection.device).to eq(device)
    end

    it 'refuses an unknown token' do
      expect { connect '/cable', params: { device_token: 'unknown' } }.to have_rejected_connection
    end

    it 'refuses a revoked device' do
      device.revoke!(actor: cashier)

      expect { connect '/cable', params: { device_token: device_token } }.to have_rejected_connection
    end

    it 'never treats a list parameter as a token' do
      expect { connect '/cable', params: { device_token: [device_token] } }.to have_rejected_connection
    end
  end

  describe 'a paired device with a staff session' do
    it 'connects as that staff member' do
      open_staff_session
      connect '/cable', headers: { 'Sec-WebSocket-Protocol' => "actioncable-v1-json, pos-device.#{device_token}, pos-staff-session.#{session_token}" }

      expect(connection.kind).to eq(:device_staff)
      expect(connection.device).to eq(device)
      expect(connection.staff).to eq(cashier)
    end

    it 'does not count connecting as activity on the staff session' do
      session = open_staff_session
      session.update_columns(last_active_at: 10.minutes.ago)

      expect { connect '/cable', params: { device_token: device_token, staff_session_token: session_token } }
        .not_to(change { session.reload.last_active_at })
    end

    it 'refuses a session that has ended instead of falling back to the bare device' do
      open_staff_session.end!('signed_out')

      expect { connect '/cable', params: { device_token: device_token, staff_session_token: session_token } }.to have_rejected_connection
    end
  end

  describe 'request origin' do
    def real_connection(env)
      described_class.new(ActionCable.server, Rack::MockRequest.env_for('/cable', env))
    end

    def allowed?(env)
      real_connection(env).send(:allow_request_origin?)
    end

    let(:jwt_query) { "/cable?token=#{jwt_for(cashier)}" }

    def allowed_for(path, env = {})
      described_class.new(ActionCable.server, Rack::MockRequest.env_for(path, env)).send(:allow_request_origin?)
    end

    it 'accepts a missing Origin with a device token' do
      expect(allowed_for("/cable?device_token=#{device_token}")).to be(true)
      expect(allowed?('HTTP_SEC_WEBSOCKET_PROTOCOL' => "pos-device.#{device_token}")).to be(true)
    end

    it 'refuses a missing Origin with a JWT' do
      expect(allowed_for(jwt_query)).to be(false)
    end

    it 'refuses a missing Origin when a JWT rides along with a device token' do
      expect(allowed_for("#{jwt_query}&device_token=#{device_token}")).to be(false)
    end

    it 'refuses a missing Origin with no credentials' do
      expect(allowed_for('/cable')).to be(false)
    end

    it 'accepts a JWT from an origin the store allows' do
      store.allowed_origins.create!(origin: 'https://pos.example.test')

      expect(allowed_for(jwt_query, 'HTTP_ORIGIN' => 'https://pos.example.test')).to be(true)
    end

    it 'accepts any port of a loopback origin the store allows, as the dev POS on 5175' do
      store.allowed_origins.create!(origin: 'http://localhost')

      expect(allowed_for(jwt_query, 'HTTP_ORIGIN' => 'http://localhost:5175')).to be(true)
    end

    it 'accepts its own host' do
      expect(allowed_for(jwt_query, 'HTTP_ORIGIN' => 'http://cable.example.test', 'HTTP_HOST' => 'cable.example.test')).to be(true)
    end

    it 'refuses a foreign origin, even with a device token' do
      expect(allowed_for(jwt_query, 'HTTP_ORIGIN' => 'https://evil.example.test')).to be(false)
      expect(allowed_for("/cable?device_token=#{device_token}", 'HTTP_ORIGIN' => 'https://evil.example.test')).to be(false)
    end
  end

  describe 'token handling' do
    it 'filters every credential out of the logged path' do
      request = ActionDispatch::Request.new(
        Rails.application.env_config.merge(Rack::MockRequest.env_for('/cable?token=jwt-secret&device_token=dev-secret&staff_session_token=sess-secret'))
      )

      expect(request.filtered_path).not_to match(/secret/)
    end

    it 'never selects a token subprotocol, so the handshake cannot echo it' do
      socket = Struct.new(:env, :url) { def write(_data); end }.new(
        Rack::MockRequest.env_for('/cable', 'HTTP_SEC_WEBSOCKET_PROTOCOL' => "pos-device.#{device_token}, actioncable-v1-json",
                                            'HTTP_SEC_WEBSOCKET_KEY' => 'dGhlIHNhbXBsZSBub25jZQ==', 'HTTP_SEC_WEBSOCKET_VERSION' => '13'),
        'ws://example.test/cable'
      )
      driver = WebSocket::Driver::Hybi.new(socket, protocols: ActionCable::INTERNAL[:protocols], require_masking: false)

      expect(driver.protocol).to eq('actioncable-v1-json')
    end
  end
end

RSpec.describe Spree::Pos::BranchChannel, type: :channel do
  include_context 'with realtime branches'

  def subscribe_as(principal, branch_id:)
    stub_connection(device_id: principal.device&.prefixed_id, principal: principal)
    subscribe(branch_id: branch_id)
  end

  def staff_principal(user) = Spree::Pos::ApplicationCable::Principal.for_staff(user)
  def device_principal(session = nil) = Spree::Pos::ApplicationCable::Principal.for_device(device, session)

  def revalidate
    closed = []
    connection.define_singleton_method(:close) { |**options| closed << options }
    subscription.send(:revalidate)
    closed
  end

  describe 'staff' do
    it 'streams a branch where the membership reads workspaces' do
      subscribe_as(staff_principal(cashier), branch_id: branch.prefixed_id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("pos:branch:#{branch.prefixed_id}")
    end

    it 'accepts an approver, who is who approval events are for' do
      approver = credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE])
      subscribe_as(staff_principal(approver), branch_id: branch.prefixed_id)

      expect(subscription).to be_confirmed
    end

    it 'refuses a branch where the staff member has no membership' do
      subscribe_as(staff_principal(cashier), branch_id: other_branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'refuses a store-wide topology permission without a membership at the branch' do
      manager = credit_staff(store, other_branch, PosCreditHelpers::MANAGER, extra_permissions: %w[read_pos_topology])
      expect(Spree::Pos::AccessPolicy.new(store: store, staff: manager).visible_branches).to include(branch)

      subscribe_as(staff_principal(manager), branch_id: branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'refuses a membership that grants no reading capability' do
      clerk = credit_staff(store, branch, [Spree::Pos::Capabilities::REPORT_READ])
      subscribe_as(staff_principal(clerk), branch_id: branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'refuses a disabled membership' do
      Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch).update!(status: 'disabled')
      subscribe_as(staff_principal(cashier), branch_id: branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'refuses a member of a branch in a store where they hold no role' do
      foreign_store = create(:store, default_currency: 'VND', supported_currencies: 'VND')
      foreign_branch = credit_branch(foreign_store)
      Spree::Pos::StaffMembership.create!(store: foreign_store, branch: foreign_branch, staff: cashier,
                                          capabilities: PosCreditHelpers::CASHIER, status: 'active')
      subscribe_as(staff_principal(cashier), branch_id: foreign_branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'refuses an unknown or foreign-typed branch id' do
      subscribe_as(staff_principal(cashier), branch_id: 'posbranch_missing')
      expect(subscription).to be_rejected

      subscribe_as(staff_principal(cashier), branch_id: cashier.prefixed_id)
      expect(subscription).to be_rejected
    end

    it 'closes the socket once the staff member loses the membership' do
      subscribe_as(staff_principal(cashier), branch_id: branch.prefixed_id)
      expect(revalidate).to be_empty

      Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch).update!(status: 'disabled')

      expect(revalidate).to eq([{ reason: 'unauthorized', reconnect: true }])
    end
  end

  describe 'a device' do
    it 'streams its own branch' do
      subscribe_as(device_principal, branch_id: branch.prefixed_id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("pos:branch:#{branch.prefixed_id}")
    end

    it 'refuses any other branch' do
      subscribe_as(device_principal, branch_id: other_branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'refuses another branch for a device with a staff session, whatever the staff member may read' do
      session = open_staff_session
      Spree::Pos::StaffMembership.create!(store: store, branch: other_branch, staff: cashier,
                                          capabilities: PosCreditHelpers::CASHIER, status: 'active')
      subscribe_as(device_principal(session), branch_id: other_branch.prefixed_id)

      expect(subscription).to be_rejected
    end

    it 'closes the socket once the device is revoked' do
      subscribe_as(device_principal, branch_id: branch.prefixed_id)
      expect(revalidate).to be_empty

      device.revoke!(actor: cashier)

      expect(revalidate).to eq([{ reason: 'unauthorized', reconnect: true }])
    end

    it 'closes the socket once the device is paired again' do
      subscribe_as(device_principal, branch_id: branch.prefixed_id)

      Spree::Pos::Device.find(device.id).rotate_token!(actor: cashier)

      expect(revalidate).to eq([{ reason: 'unauthorized', reconnect: true }])
    end

    it 'closes the socket once the staff session ends, and does not extend it' do
      session = open_staff_session
      session.update_columns(last_active_at: 10.minutes.ago)
      subscribe_as(device_principal(session), branch_id: branch.prefixed_id)
      expect { revalidate }.not_to(change { session.reload.last_active_at })

      session.end!('signed_out')

      expect(revalidate).to eq([{ reason: 'unauthorized', reconnect: true }])
    end
  end

  it 'delivers a published event to the stream of that branch only' do
    subscribe_as(staff_principal(cashier), branch_id: branch.prefixed_id)

    expect { Spree::Pos::Realtime.publish(branch, 'workspace.updated', id: 'posws_abc') }
      .to have_broadcasted_to("pos:branch:#{branch.prefixed_id}").exactly(:once)
      .and have_broadcasted_to("pos:branch:#{other_branch.prefixed_id}").exactly(0).times
  end
end
