# frozen_string_literal: true

# A demo restaurant for trying table service on a development stack:
#   POS_FNB_DEMO=1 pnpm spree seed
# Profile `nha_hang` with its modules, a register for table orders, two areas
# of six tables, 30 dishes and drinks (some with options), the Bếp and Bar
# stations with drinks routed to the bar, and an ESC/POS LAN printer at
# 127.0.0.1:9100 for the kitchen, behind a placeholder print station.
# Development only; a store that already has the demo branch is left alone.
return unless ENV['POS_FNB_DEMO'] == '1'

unless Rails.env.development?
  puts 'POS F&B demo: development only, skipped.'
  return
end

store = Spree::Store.default
actor = Spree.admin_user_class.order(:id).first
code = 'demo-nha-hang'
if actor.nil?
  puts 'POS F&B demo: no admin user yet, skipped.'
elsif Spree::Pos::Branch.for_store(store).exists?(code: code)
  puts "POS F&B demo: branch #{code} already exists, left as it is."
else
  ActiveRecord::Base.transaction do
    Spree::Pos::TaxCategories.seed!(store)
    location = Spree::StockLocation.create!(store: store, name: 'Kho nhà hàng demo', active: true, propagate_all_variants: false)
    branch = Spree::Pos::Branches::Create.call(store: store, actor: actor, profile_key: 'nha_hang',
                                               attributes: { name: 'Nhà hàng demo', code: code, timezone: 'Asia/Ho_Chi_Minh',
                                                             stock_location: location })
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quầy 1', code: "#{code}-1", status: 'active')
    branch.update!(table_register: register)
    Spree::Pos::StaffMembership.find_or_create_by!(store: store, branch: branch, staff: actor) do |membership|
      membership.capabilities = Spree::Pos::Capabilities::ASSIGNABLE
      membership.status = 'active'
    end
    stations = Spree::Pos::Kitchen::Defaults.stations!(store: store, actor: actor, branch: branch, kinds: %w[prep bar])
    Spree::Pos::Kitchen::Defaults.routes!(store: store, actor: actor, branch: branch)
    # A LAN printer is driven by a print station; this one is a placeholder whose
    # token nobody holds. Pair a real print station and pick it on the printer.
    station_device = Spree::Pos::Device.create!(store: store, branch: branch, name: 'Trạm in demo (chưa ghép)', mode: 'print_station',
                                                platform: 'android', token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token))
    printer = Spree::Pos::Printer.create!(store: store, branch: branch, name: 'Máy in bếp (giả lập)', connection: 'escpos_lan',
                                          address: '127.0.0.1:9100', paper: '80mm', command_language: 'escpos',
                                          roles: %w[kitchen_ticket void_ticket checklist], status: 'active',
                                          print_station_device: station_device)
    stations.first.update!(printer: printer)

    [['Tầng 1', 0], ['Sân vườn', 1]].each do |name, area_index|
      area = Spree::Pos::Area.create!(store: store, branch: branch, name: name, position: area_index, floor_width: 24, floor_height: 16)
      6.times do |index|
        number = (area_index * 6) + index + 1
        Spree::Pos::Resource.create!(store: store, branch: branch, area: area, kind: 'table', name: "Bàn #{number}", capacity: 4,
                                     shape: index.even? ? 'rect' : 'round', x: ((index % 3) * 7) + 1, y: ((index / 3) * 7) + 1,
                                     w: 5, h: 5, position: index)
      end
    end

    food_tax = Spree::TaxCategory.find_by(store_id: store.id, tax_code: 'vat_food')
    drink_tax = Spree::TaxCategory.find_by(store_id: store.id, tax_code: 'vat_special')
    categories = %w[Khai\ vị Món\ chính Lẩu Đồ\ uống].each_with_index.to_h do |name, index|
      [name, Spree::Pos::MenuCategory.find_or_create_by!(store: store, name: name) { |row| row.position = index }]
    end
    spicy = Spree::Pos::ModifierGroup.create!(store: store, name: 'Độ cay', min_select: 0, max_select: 1)
    %w[Không\ cay Cay\ vừa Cay\ nhiều].each_with_index { |label, index| spicy.modifier_options.create!(name: label, price_delta: 0, position: index) }
    extra = Spree::Pos::ModifierGroup.create!(store: store, name: 'Thêm', min_select: 0, max_select: 3)
    [['Thêm trứng', 5_000], ['Thêm thịt', 15_000], ['Thêm rau', 5_000]].each_with_index do |(label, delta), index|
      extra.modifier_options.create!(name: label, price_delta: delta, position: index)
    end
    ice = Spree::Pos::ModifierGroup.create!(store: store, name: 'Đá', min_select: 1, max_select: 1)
    %w[Nhiều\ đá Ít\ đá Không\ đá].each_with_index do |label, index|
      ice.modifier_options.create!(name: label, price_delta: 0, position: index, default_selected: index.zero?)
    end

    dishes = {
      'Khai vị' => [['Gỏi cuốn', 45_000], ['Chả giò', 55_000], ['Nộm bò', 65_000], ['Súp cua', 40_000], ['Đậu hũ chiên', 35_000],
                    ['Khoai tây chiên', 40_000]],
      'Món chính' => [['Phở bò', 60_000], ['Bún chả', 55_000], ['Cơm tấm sườn', 55_000], ['Cơm chiên hải sản', 75_000],
                      ['Bò lúc lắc', 120_000], ['Cá kho tộ', 95_000], ['Gà nướng mật ong', 150_000], ['Mì xào bò', 70_000],
                      ['Rau muống xào tỏi', 45_000], ['Canh chua cá', 85_000]],
      'Lẩu' => [['Lẩu thái', 250_000], ['Lẩu nấm', 220_000], ['Lẩu bò', 280_000], ['Lẩu cá', 260_000]],
      'Đồ uống' => [['Trà đá', 5_000], ['Trà chanh', 20_000], ['Nước cam', 35_000], ['Sinh tố bơ', 40_000], ['Cà phê sữa đá', 30_000],
                    ['Nước suối', 10_000], ['Coca-Cola', 20_000], ['Bia Sài Gòn', 25_000], ['Bia Tiger', 30_000], ['Nước dừa', 30_000]]
    }
    dishes.each do |category_name, rows|
      drink = category_name == 'Đồ uống'
      rows.each_with_index do |(name, price), index|
        product = Spree::Product.create!(store: store, name: name, status: 'active')
        tax = drink ? drink_tax : food_tax
        product.update!(tax_category: tax) if tax
        product.default_variant.set_price(store.default_currency, price)
        location.restock(product.default_variant, 500)
        Spree::Pos::BranchProduct.create!(branch: branch, product: product)
        item = Spree::Pos::MenuItem.create!(store: store, product: product, kind: 'single', menu_category: categories[category_name],
                                            kitchen_category: drink ? Spree::Pos::Kitchen::Defaults::BAR_CATEGORY : nil, position: index)
        groups = if drink then name.start_with?('Bia', 'Nước suối', 'Coca') ? [] : [ice]
                 elsif category_name != 'Lẩu' && index.even? then [spicy, extra]
                 else [spicy]
                 end
        groups.each_with_index do |group, position|
          Spree::Pos::MenuItemModifierGroup.create!(menu_item: item, modifier_group: group, position: position)
        end
      end
    end
    puts "POS F&B demo: branch #{branch.prefixed_id} (#{code}), register #{register.prefixed_id}, 12 tables, 30 dishes."
  end
end
