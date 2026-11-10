# frozen_string_literal: true

RSpec.describe Pos::CreateWalkInDraft do
  let(:store) { Spree::Store.default }
  let(:staff) { create(:admin_user, :without_admin_role) }

  before { PosChannelHelpers.channel_for(store) }

  def grant_pos_access(user, target_store)
    role = create(:role, resource: target_store, permissions: %w[write_pos_orders])
    create(:role_user, user: user, role: role)
  end

  it 'creates a staff-owned draft and marker together without granting core order writes' do
    grant_pos_access(staff, store)
    ability = Spree.ability_class.new(staff, store: store)
    expect(ability.permission_keys).not_to include('write_orders')

    result = described_class.call(store: store, staff: staff)
    expect(result).to be_success
    order = result.value
    expect(order).to be_draft
    expect(order.store).to eq(store)
    expect(order.channel.code).to eq('pos')
    expect(order.created_by).to eq(staff)
    expect(order.email).to be_nil
    expect(Pos::WalkInOrder.exists?(order: order)).to be(true)
  end

  it 'refuses staff without POS write access, including staff from another store' do
    other = create(:store)
    grant_pos_access(staff, other)
    expect { described_class.call(store: store, staff: staff) }.to raise_error(CanCan::AccessDenied)
    expect { described_class.call(store: store, staff: nil) }.to raise_error(CanCan::AccessDenied)
  end

  it 'refuses deactivated staff even if their role still grants POS access' do
    grant_pos_access(staff, store)
    Spree.admin_user_class.find(staff.id).deactivate!
    expect { described_class.call(store: store, staff: staff) }.to raise_error(CanCan::AccessDenied)
  end

  it 'refuses staff after their POS role is removed' do
    grant_pos_access(staff, store)
    expect(described_class.call(store: store, staff: staff)).to be_success
    role = staff.spree_roles.for_resource(store).first
    Spree::RoleUser.find_by!(user: staff, role: role).destroy!

    expect { described_class.call(store: store, staff: staff) }.to raise_error(CanCan::AccessDenied)
  end

  it 'rolls back the draft when the marker cannot be created' do
    grant_pos_access(staff, store)
    allow(Pos::WalkInOrder).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Pos::WalkInOrder.new))

    expect do
      expect { described_class.call(store: store, staff: staff) }.to raise_error(ActiveRecord::RecordInvalid)
    end.not_to change { store.orders.count }
  end
end
