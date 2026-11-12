# frozen_string_literal: true

require_relative 'pos_credit_helpers'

# Canteen scenarios through the real workflows: a branch with meal accounts
# on, accounts and sponsors made by their save commands, wallets topped up
# into a cashier's drawer and meals recorded on a counter order.
module PosMealHelpers
  include PosCreditHelpers

  CAPS = Spree::Pos::Capabilities
  MEAL_CASHIER = (PosCreditHelpers::CASHIER + [CAPS::MEAL_ACCOUNT_MANAGE]).freeze

  def canteen_branch(store)
    credit_branch(store).tap { |branch| set_pos_module(branch, 'fnb.meal_accounts', true) }
  end

  def meal_account!(store, staff, branch, code: "NV#{SecureRandom.hex(3).upcase}", name: 'Nguyễn Văn An', **attributes)
    values = { 'employee_code' => code, 'name' => name, 'phone' => "09#{rand(10**8).to_s.rjust(8, '0')}" }.
             merge(attributes.transform_keys(&:to_s))
    result = Spree::Pos::MealAccounts::Save.call(store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                 attributes: values)
    Spree::Pos::MealAccount.find_by_prefix_id!(result[:id] || result['id'])
  end

  def meal_sponsor!(store, staff, branch, name: 'Công ty ABC', credit_limit: 1_000_000, **attributes)
    values = { 'name' => name, 'phone' => "028#{rand(10**7).to_s.rjust(7, '0')}", 'credit_limit' => credit_limit.to_s,
               'due_days' => '30' }.merge(attributes.transform_keys(&:to_s))
    result = Spree::Pos::MealSponsors::Save.call(store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                 attributes: values)
    Spree::Pos::MealSponsor.find_by_prefix_id!(result[:id] || result['id'])
  end

  # The cashier needs an open shift at the branch (open_drawer / credit_sale).
  def top_up!(store, staff, branch, account, amount, kind: 'cash')
    evidence = kind == 'cash' ? {} : { reference: "FT#{SecureRandom.hex(4)}", receiving_account: 'VCB-123' }
    Spree::Pos::MealWallets::TopUp.call(store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                        meal_account_id: account.prefixed_id, kind: kind, amount: amount.to_s, **evidence)
  end

  def swipe(sale, account = nil, code: account&.employee_code, **)
    Spree::Pos::MealAccounts::Swipe.call(**editing_args(sale), code: code, **)
  end

  def wallet_pay(sale, amount = nil)
    Spree::Pos::MealWallets::Pay.call(**editing_args(sale), amount: amount&.to_s)
  end

  def complete_with_sponsor(sale)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale), meal_sponsor: true)
  end

  # A counter order of one item at `price` on the cashier's own register.
  def meal_sale(store, branch, cashier, price:)
    shift = Spree::Pos::Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: cashier.id)
    return credit_sale(store, branch, price: price, cashier: cashier) if shift.nil?

    editor_id = SecureRandom.uuid
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: shift.register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: "Suất #{SecureRandom.hex(3)}")
    product.default_variant.set_price(workspace.order.currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    branch.stock_location.restock(product.default_variant, 10)
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: workspace.revision, key: SecureRandom.uuid,
                                               lease_generation: workspace.lease_generation, editor_id: editor_id,
                                               variant_id: product.default_variant.prefixed_id, quantity: 1)
    PosCreditHelpers::Sale.new(workspace: workspace.reload, cashier: cashier, editor_id: editor_id, product: product)
  end

  def refusal(&)
    yield
    raise 'expected a refusal'
  rescue Spree::Pos::Conflict => e
    e
  end
end
