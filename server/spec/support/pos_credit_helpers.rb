# frozen_string_literal: true

# Builds credit-sale scenarios through the real POS workflows (no HTTP), so
# workflow specs and committed two-connection race specs share one setup.
module PosCreditHelpers
  CAPS = Spree::Pos::Capabilities
  CASHIER = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::CREDIT_SELL].freeze
  MANAGER = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::RESOLVE, CAPS::APPROVE, CAPS::CREDIT_MANAGE].freeze

  Sale = Struct.new(:workspace, :cashier, :editor_id, :product, keyword_init: true)

  def credit_branch(store)
    location = Spree::StockLocation.create!(
      store: store, name: "Credit #{SecureRandom.hex(4)}", address1: '1 Credit St', city: 'HCM',
      zipcode: '70000', country_code: 'VN', active: true, backorderable_default: false, propagate_all_variants: false
    )
    suffix = SecureRandom.hex(3)
    create(:check_payment_method, store: store, name: "Bank transfer #{suffix}", active: true) unless
      Spree::PaymentMethod.where(store_id: store.id, active: true).where('name ILIKE ?', '%bank%').exists?
    Spree::Pos::Branch.create!(store: store, stock_location: location, name: "Credit #{suffix}", code: "cr#{suffix}",
                               timezone: 'Asia/Ho_Chi_Minh', status: 'active')
  end

  def credit_staff(store, branch, capabilities, extra_permissions: [])
    role = Spree::Role.create!(name: "credit-#{SecureRandom.hex(4)}", resource: store,
                               permissions: %w[write_pos_orders read_pos_orders write_pos_workspaces write_pos_shifts] + extra_permissions)
    user = Spree.admin_user_class.create!(email: "credit-#{SecureRandom.hex(6)}@example.test", password: 'secret123',
                                          password_confirmation: 'secret123')
    Spree::RoleUser.create!(role: role, user: user)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, capabilities: capabilities, status: 'active')
    user
  end

  def open_drawer(store, branch, staff)
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'R', code: "r#{SecureRandom.hex(4)}", status: 'active')
    Spree::Pos::Shifts::Open.call(store: store, staff: staff, register: register, opening_float: '0')
    register
  end

  def credit_sale(store, branch, price:, cashier: credit_staff(store, branch, CASHIER), product: nil)
    editor_id = SecureRandom.uuid
    register = open_drawer(store, branch, cashier)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    unless product
      product = create(:product, store: store, status: 'active', name: "Hang #{SecureRandom.hex(3)}")
      product.default_variant.set_price(workspace.order.currency, price)
      Spree::Pos::BranchProduct.create!(branch: branch, product: product)
      branch.stock_location.restock(product.default_variant, 10)
    end
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: 0, key: SecureRandom.uuid,
                                               lease_generation: workspace.lease_generation, editor_id: editor_id,
                                               variant_id: product.default_variant.prefixed_id, quantity: 1)
    Sale.new(workspace: workspace.reload, cashier: cashier, editor_id: editor_id, product: product)
  end

  def editing_args(sale)
    workspace = sale.workspace.reload
    { workspace: workspace, staff: sale.cashier, revision: workspace.revision, lease_generation: workspace.lease_generation,
      editor_id: sale.editor_id, key: SecureRandom.uuid }
  end

  def credit_customer(store, staff, name: 'Chi Lan')
    Spree::Pos::CustomerProfile.create!(store: store, created_by: staff, name: name, phone: "09#{rand(10**8).to_s.rjust(8, '0')}")
  end

  def assign(sale, profile)
    Spree::Pos::Workspaces::AssignCustomer.call(**editing_args(sale), profile_id: profile&.prefixed_id)
  end

  def configure_credit(store, manager, branch, profile, limit:, due_days: 30)
    result = Spree::Pos::Credit::Configure.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                customer_id: profile.prefixed_id, credit_limit: limit.to_s, due_days: due_days)
    Spree::Pos::CreditAccount.find_by_prefix_id!(result['id'])
  end

  def take_tender(sale, kind, amount)
    method = Spree::Pos::PaymentMethodResolver.new(store: sale.workspace.store).available.find { |row| row.kind == kind }
    Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || "posmethod-#{kind}",
                                                            amount: amount.to_s)
    attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).order(:id).last
    evidence = if kind == 'cash'
                 { evidence_kind: 'cash_count', handed_amount: amount.to_s }
               else
                 { evidence_kind: 'bank_manual', reference: "FT#{SecureRandom.hex(3)}", receiving_account: 'VCB-123' }
               end
    Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, **evidence)
  end

  def approve_credit(sale, manager, amount, key: SecureRandom.uuid)
    workspace = sale.workspace.reload
    Spree::Pos::Credit::Approve.call(workspace: workspace, staff: manager, key: key, requester_id: sale.cashier.prefixed_id,
                                     amount: amount.to_s, revision: workspace.revision)
  end

  def complete_on_credit(sale, approval_id)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale), credit_approval_id: approval_id)
  end

  def credit_order(store, branch, manager, profile, price:, product: nil)
    sale = credit_sale(store, branch, price: price, product: product)
    assign(sale, profile)
    approval = approve_credit(sale, manager, price)
    complete_on_credit(sale, approval['approval_id'])
    sale.workspace.reload
    sale
  end

  def request_credit(sale)
    Spree::Pos::Credit::RequestApproval.call(**editing_args(sale))
  end

  def receivable_balance(order)
    Spree::Pos::ReceivableEntry.balance_sum(Spree::Pos::ReceivableEntry.where(order_id: order.id))
  end
end
