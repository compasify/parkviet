# Development-only, isolated POS fixtures. Run through `pnpm spree rails runner db/pos_supermarket_sandbox.rb`.
raise 'Development only' unless Rails.env.development?

store = Spree::Store.default
staff = Spree.admin_user_class.find_by!(email: 'buithehien1991@gmail.com')
raise 'Expected VND store' unless store.default_currency == 'VND'
raise 'Sandbox already exists; inspect it instead of overwriting' if Spree::Pos::Branch.for_store(store).exists?(code: 'sandbox-hien-supermarket')

ActiveRecord::Base.transaction do
  location = Spree::StockLocation.create!(store: store, name: 'Kho siêu thị Hiền - kiểm thử', active: true, propagate_all_variants: false)
  branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: 'Siêu thị Hiền - Kiểm thử', code: 'sandbox-hien-supermarket', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
  register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quầy Hiền - VND', code: 'hien-vnd-test', status: 'active')
  Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: staff, capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT], status: 'active')

  items = [['Gạo thơm 5kg', 125_000], ['Sữa tươi không đường 1L', 35_000], ['Trứng gà hộp 10 quả', 38_000], ['Mì ăn liền gói', 5_000], ['Dầu ăn 1L', 48_000], ['Nước suối 500ml', 7_000], ['Cà phê hòa tan hộp', 75_000], ['Bánh quy bơ', 42_000], ['Nước mắm 500ml', 40_000], ['Đường trắng 1kg', 28_000], ['Bột giặt 2kg', 115_000], ['Giấy vệ sinh 10 cuộn', 85_000]]
  items.each_with_index do |(name, amount), index|
    product = Spree::Product.new(store: store, name: name, status: 'active')
    variant = product.build_default_variant(sku: format('HIEN-%03d', index + 1), barcode: format('990000000%04d', index + 1))
    variant.product = product
    product.save!
    product.default_variant.set_price('VND', amount)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    location.restock(product.default_variant, 30)
  end
  shift = Spree::Pos::Shifts::Open.call(store: store, staff: staff, register: register, opening_float: '0')
  puts({ branch: branch.prefixed_id, register: register.prefixed_id, shift: shift.respond_to?(:prefixed_id) ? shift.prefixed_id : shift, products: items.length, currency: store.default_currency }.inspect)
end
