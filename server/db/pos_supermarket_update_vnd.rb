# One-time development fixture update; leaves existing shifts and orders intact.
raise 'Development only' unless Rails.env.development?
store = Spree::Store.default
raise 'Expected VND store' unless store.default_currency == 'VND'
staff = Spree.admin_user_class.find_by!(email: 'buithehien1991@gmail.com')
branch = Spree::Pos::Branch.for_store(store).find_by!(code: 'sandbox-hien-supermarket')
prices = [125_000, 35_000, 38_000, 5_000, 48_000, 7_000, 75_000, 42_000, 40_000, 28_000, 115_000, 85_000]

ActiveRecord::Base.transaction do
  branch.update!(name: 'Siêu thị Hiền - Kiểm thử')
  prices.each_with_index do |amount, index|
    scope = Spree::Variant.joins(:product).where(spree_products: { store_id: store.id })
    variant = scope.find_by(sku: format('SANDBOX-HIEN-%03d', index + 1)) || scope.find_by!(sku: format('HIEN-%03d', index + 1))
    raise 'Product not assigned to test branch' unless Spree::Pos::BranchProduct.exists?(branch: branch, product: variant.product)
    variant.product.update!(name: variant.product.name.delete_prefix('[Sandbox] '))
    variant.update!(sku: format('HIEN-%03d', index + 1))
    variant.set_price('VND', amount)
  end
  register = Spree::Pos::Register.for_store(store).find_or_create_by!(branch: branch, code: 'hien-vnd-test') do |row|
    row.name = 'Quầy Hiền - VND'
    row.status = 'active'
  end
  shift = Spree::Pos::Shift.for_store(store).open_now.find_by(register: register)
  if shift
    raise 'Existing shift has unexpected owner or currency' unless shift.owner_id == staff.id && shift.currency == 'VND'
  else
    shift = Spree::Pos::Shifts::Open.call(store: store, staff: staff, register: register, opening_float: '0')
  end
  puts({ branch: branch.prefixed_id, register: register.prefixed_id, shift: shift.prefixed_id, products: prices.length, currency: 'VND' }.inspect)
end
