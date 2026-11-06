# frozen_string_literal: true

FactoryBot.define do
  factory :pos_branch, class: 'Spree::Pos::Branch' do
    store { Spree::Store.default }
    name { 'Chi nhanh' }
    sequence(:code) { |number| "cn#{number}" }
    timezone { 'Asia/Ho_Chi_Minh' }
    status { 'active' }
    receiving_config { {} }
    stock_location { association(:stock_location, store: store, backorderable_default: false) }
  end

  factory :pos_register, class: 'Spree::Pos::Register' do
    branch factory: :pos_branch
    store { branch.store }
    name { 'Quay 1' }
    sequence(:code) { |number| "q#{number}" }
    status { 'active' }
  end

  factory :pos_membership, class: 'Spree::Pos::StaffMembership' do
    branch factory: :pos_branch
    store { branch.store }
    association :staff, factory: :admin_user
    capabilities { ['pos.shift.open'] }
    status { 'active' }
  end
end
