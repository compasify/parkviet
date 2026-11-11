# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_table_helpers'

# A booking still waiting past its time and the branch's grace minutes is a
# no-show: its table is free again and its deposit stays held.
RSpec.describe Spree::Pos::Reservations::MarkNoShowJob do
  include PosTableHelpers

  let(:store) { menu_store }
  let(:branch) { table_branch(store).tap { |row| set_pos_module(row, 'fnb.reservations', true) } }
  let(:host) do
    credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::RESERVATION_MANAGE])
  end
  let(:area) { area!(branch) }

  def book(table, starts_at)
    result = Spree::Pos::Reservations::Create.call(
      store: store, staff: host, key: SecureRandom.uuid, branch_id: branch.prefixed_id, resource_ids: [table.prefixed_id],
      attributes: { 'guest_name' => 'Chị Hoa', 'party_size' => 2, 'starts_at' => starts_at.iso8601 }
    )
    Spree::Pos::Reservation.find_by_prefix_id!(result.with_indifferent_access[:id])
  end

  it 'marks bookings past their grace as no-shows and leaves the others' do
    branch.update!(reservation_grace_minutes: 15)
    late = book(table!(area, name: 'Bàn 1'), 20.minutes.ago)
    within = book(table!(area, name: 'Bàn 2', x: 4), 10.minutes.ago)
    ahead = book(table!(area, name: 'Bàn 3', x: 8), 1.hour.from_now)
    table_register!(branch, host)
    Spree::Pos::Reservations::TakeDeposit.call(store: store, staff: host, key: SecureRandom.uuid, reservation_id: late.prefixed_id,
                                               kind: 'cash', amount: '100000')

    described_class.perform_now

    expect(late.reload).to have_attributes(status: 'no_show')
    expect(late.canceled_at).to be_present
    expect(late.holds.active).to be_empty
    expect(late.deposits.sole.status).to eq('held')
    expect(within.reload.status).to eq('booked')
    expect(ahead.reload.status).to eq('booked')
  end

  it 'is scheduled' do
    schedule = YAML.safe_load_file(Rails.root.join('config/recurring.yml'), aliases: true)
    jobs = schedule.values.select { |value| value.is_a?(Hash) }.flat_map(&:values)
    expect(jobs.map { |job| job['class'] if job.is_a?(Hash) }).to include(described_class.name)
  end
end
