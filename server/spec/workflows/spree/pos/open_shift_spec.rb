# frozen_string_literal: true

RSpec.describe Spree::Pos::Shifts::Open do
  let(:store) { Spree::Store.default }
  let(:staff) { create(:admin_user, :without_admin_role) }
  let(:location) { create(:stock_location, store: store, backorderable_default: false) }
  let(:branch) do
    Spree::Pos::Branch.create!(
      store: store,
      stock_location: location,
      name: 'Quan 1',
      code: 'q1',
      timezone: 'Asia/Ho_Chi_Minh',
      status: 'active'
    )
  end
  let(:register) do
    Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quay 1', code: 'q1', status: 'active')
  end

  before do
    Spree::Pos::StaffMembership.create!(
      store: store,
      branch: branch,
      staff: staff,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT],
      status: 'active'
    )
  end

  it 'opens one shift with a store-currency float and refuses a second open shift' do
    shift = nil
    expect {
      shift = described_class.call(store: store, staff: staff, register: register, opening_float: '10000.5000')
    }.not_to change(Spree::Payment, :count)

    expect(shift).to be_persisted
    expect(shift.opening_float).to eq(BigDecimal('10000.5000'))
    expect(shift.currency).to eq(store.default_currency)
    expect(shift.owner).to eq(staff)
    expect(shift.to_pos[:reports]).to be(false)

    expect {
      described_class.call(store: store, staff: staff, register: register, opening_float: '1')
    }.to raise_error(Spree::Pos::Conflict)

    duplicate = Spree::Pos::Shift.new(shift.attributes.except('id', 'created_at', 'updated_at'))
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'rejects a negative float and a cashier without the capability' do
    expect {
      described_class.call(store: store, staff: staff, register: register, opening_float: '-1')
    }.to raise_error(ActiveRecord::RecordInvalid)

    other = create(:admin_user, :without_admin_role)
    expect {
      described_class.call(store: store, staff: other, register: register, opening_float: '1')
    }.to raise_error(CanCan::AccessDenied)
  end

  it 'lets a disabled membership recover the branch and still records the audit' do
    membership = Spree::Pos::StaffMembership.find_by!(staff: staff)
    membership.update!(capabilities: [Spree::Pos::Capabilities::RECOVER], status: 'disabled', disabled_at: Time.current)
    policy = Spree::Pos::AccessPolicy.new(store: store, staff: staff)

    Spree::Pos::Topology::Disable.call(record: branch, actor: staff)
    expect(branch.reload.status).to eq('disabled')
    Spree::Pos::Topology::Enable.call(record: branch, actor: staff, policy: policy)
    expect(branch.reload.status).to eq('active')
    expect(Spree::Pos::AuditEntry.where(subject_type: branch.class.name, subject_id: branch.id).pluck(:action)).to include('disable', 'enable')
  end
end
