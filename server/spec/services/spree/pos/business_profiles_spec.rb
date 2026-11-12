# frozen_string_literal: true

# The industry profile catalog and the module registry it refers to: the
# shipped file is valid, every profile default passes the Branch rules, and a
# bad catalog fails with a message naming the profile and the field.
RSpec.describe Spree::Pos::BusinessProfiles do
  def catalog(profiles, version: 1)
    { 'version' => version, 'profiles' => profiles }
  end

  def profile(**overrides)
    { 'group' => 'retail', 'order' => 1, 'modules' => ['retail.units'], 'branch_defaults' => { 'return_window_days' => 7 },
      'display' => { 'catalog_view' => 'list' }, 'recommended_features' => ['returns'],
      'sample_units' => ['vien'] }.merge(overrides.transform_keys(&:to_s))
  end

  def errors_of(profiles)
    described_class.errors_for(catalog(profiles))
  end

  describe 'the shipped catalog' do
    it 'offers 13 retail profiles and six F&B profiles, every one available' do
      profiles = described_class.all
      expect(described_class.version).to eq(4)
      expect(profiles.size).to eq(19)
      expect(profiles.map(&:order)).to eq((1..19).to_a)
      expect(profiles.select { |item| item.group == 'retail' }.map(&:status)).to all(eq('available'))
      fnb = profiles.select { |item| item.group == 'fnb' }.to_h { |item| [item.key, item.status] }
      expect(fnb).to eq('quan_an' => 'available', 'cafe_tra_sua' => 'available', 'cang_tin_tram_dung' => 'available',
                        'karaoke_bida' => 'available', 'bar_pub_club' => 'available', 'nha_hang' => 'available')
      expect(profiles.count(&:available?)).to eq(19)
      expect(profiles.map(&:key)).to include('tap_hoa_sieu_thi', 'nha_thuoc', 'vat_lieu_xay_dung', 'khac', 'nha_hang')
    end

    it 'turns on every retail module for khac, the profile of branches that already run' do
      retail = Spree::Pos::Modules.available.select { |definition| definition.group == 'retail' }.map(&:key)
      expect(described_class.fetch!('khac').modules).to match_array(retail)
    end

    it 'keeps every profile default within the Branch validations' do
      store = create(:store)
      location = create(:stock_location, store: store)
      described_class.all.each do |item|
        branch = Spree::Pos::Branch.new(store: store, stock_location: location, name: 'B', code: 'b1', timezone: 'Asia/Ho_Chi_Minh',
                                        status: 'active', profile_key: item.key, **item.branch_defaults.symbolize_keys)
        branch.validate
        expect(branch.errors.attribute_names & (item.branch_defaults.keys.map(&:to_sym) + [:profile_key])).
          to be_empty, "#{item.key}: #{branch.errors.full_messages.join(', ')}"
      end
    end

    it 'names only known features and units, and never a length or area unit' do
      features = described_class.all.flat_map(&:recommended_features)
      expect(features - Spree::Pos::FeatureFlag::FEATURES).to be_empty
      units = described_class.all.flat_map(&:sample_units).uniq
      expect(units - Spree::Pos::UnitDefinition.known_codes).to be_empty
      expect(described_class.fetch!('vat_lieu_xay_dung').sample_units).to eq(%w[bao tam cay xe])
      expect(Spree::Pos::UnitDefinition.samples.values.map { |row| row[2] }).to all(eq('count'))
    end

    it 'serializes modules and profiles for the API' do
      data = described_class.to_pos
      expect(data[:modules]).to include({ key: 'retail.measured', group: 'retail', status: 'available', depends_on: ['retail.units'] },
                                        include(key: 'fnb.menu', status: 'available'),
                                        include(key: 'fnb.kitchen', status: 'available'),
                                        include(key: 'fnb.order_number', status: 'available'),
                                        include(key: 'fnb.cup_label', status: 'available', depends_on: ['fnb.menu']),
                                        include(key: 'fnb.tables', status: 'available', depends_on: ['resources']),
                                        include(key: 'timed_billing', status: 'available', depends_on: ['resources', 'fnb.tables']))
      expect(data[:modules].pluck(:status).uniq).to eq(['available'])
      expect(data[:profiles].first.keys).
        to eq(%i[key group order status modules optional_modules branch_defaults display recommended_features sample_units kitchen_stations])
      expect(data[:tax_categories].map { |row| row[:code] }).to eq(%w[vat_food vat_special])
      expect(data[:menu_tax_defaults]).to eq('food' => 'vat_food', 'alcohol' => 'vat_special')
    end

    it 'presets the wave-one F&B profiles as decided' do
      cafe = described_class.fetch!('cafe_tra_sua')
      expect(cafe.modules).to include('fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.cup_label', 'fnb.recipes', 'fnb.delivery_platforms')
      expect(cafe.recommended_features).to eq(%w[vietqr customer_display])
      expect(cafe.kitchen_stations).to eq(%w[prep bar])
      quan_an = described_class.fetch!('quan_an')
      expect(quan_an.modules).to include('fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.recipes', 'retail.measured', 'fnb.delivery_platforms')
      expect(quan_an.recommended_features).to eq(%w[vietqr credit delivery])
      canteen = described_class.fetch!('cang_tin_tram_dung')
      expect(canteen.modules).to contain_exactly('fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'retail.units', 'fnb.meal_accounts', 'fnb.vehicle_commission')
      expect(canteen.kitchen_stations).to eq(['prep'])
      [cafe, quan_an, canteen].each do |item|
        expect(item.display).to eq('surface' => 'menu_grid')
        expect(item.branch_defaults).to eq('kitchen_send_trigger' => 'on_complete')
      end
      expect([cafe, canteen].map(&:optional_modules)).to all(eq([]))
    end

    it 'presets the wave-two table profiles as decided' do
      quan_an = described_class.fetch!('quan_an')
      expect(quan_an.optional_modules).to eq(%w[resources fnb.tables fnb.postpay fnb.service_charge])
      expect(quan_an.tables_optional?).to be(true)
      expect(quan_an.modules_for(has_tables: true)).to include('fnb.tables', 'fnb.postpay', 'fnb.service_charge', 'fnb.menu')
      expect(quan_an.modules_for(has_tables: false)).not_to include('fnb.tables')
      restaurant = described_class.fetch!('nha_hang')
      expect(restaurant.display).to eq('surface' => 'floor_plan')
      expect(restaurant.branch_defaults).to eq('kitchen_send_trigger' => 'manual', 'service_charge_rate' => 5)
      expect(restaurant.kitchen_stations).to eq(%w[prep bar])
      expect(restaurant.modules).to include('fnb.reservations')
      bar = described_class.fetch!('bar_pub_club')
      expect(bar.modules).to include('resources', 'fnb.tables', 'fnb.postpay')
      expect(bar.modules).not_to include('fnb.reservations')
      expect(bar.display).to eq('surface' => 'tab_list')
      expect(bar.modules).to include('fnb.bottle_keep')
      expect(bar.modules).not_to include('fnb.pour_tracking')
      expect(bar.branch_defaults).not_to have_key('service_charge_rate')
      [restaurant, bar].each { |item| expect(item.recommended_features).to eq(%w[vietqr customer_display]) }
      karaoke = described_class.fetch!('karaoke_bida')
      expect(karaoke.status).to eq('available')
      expect(karaoke.modules).to include('resources', 'fnb.tables', 'timed_billing', 'fnb.menu', 'fnb.postpay', 'fnb.bottle_keep')
      expect(karaoke.display).to eq('surface' => 'resource_board')
    end
    it 'refuses an unknown profile' do
      expect { described_class.fetch!('teleport') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('profile_unknown') }
    end
  end

  describe '.errors_for' do
    it 'accepts a well-formed catalog' do
      expect(errors_of('nha_thuoc' => profile)).to eq([])
      expect(described_class.build(catalog({ 'nha_thuoc' => profile })).profiles.first.status).to eq('available')
    end

    it 'names the profile and field of an unknown module' do
      expect(errors_of('nha_thuoc' => profile(modules: ['retail.teleport']))).to eq(['nha_thuoc.modules: unknown module "retail.teleport".'])
    end

    it 'names a module listed without the module it depends on' do
      expect(errors_of('nha_thuoc' => profile(modules: ['retail.measured']))).
        to eq(['nha_thuoc.modules: retail.measured needs retail.units.'])
    end

    it 'names every branch default the Branch would refuse' do
      defaults = { 'lot_selection' => 'random', 'return_window_days' => 9999, 'variance_threshold' => -1,
                   'adjustment_approval_threshold' => 1.5, 'timezone' => 'UTC' }
      errors = errors_of('nha_thuoc' => profile(branch_defaults: defaults))
      expect(errors).to contain_exactly(
        start_with('nha_thuoc.branch_defaults.lot_selection: "random" must be one of fefo, cashier_pick'),
        start_with('nha_thuoc.branch_defaults.return_window_days: 9999 must be'),
        start_with('nha_thuoc.branch_defaults.variance_threshold: -1 must be'),
        start_with('nha_thuoc.branch_defaults.adjustment_approval_threshold: 1.5 must be'),
        start_with('nha_thuoc.branch_defaults.timezone: unknown field')
      )
    end

    it 'names an unknown feature and an unknown unit' do
      errors = errors_of('nha_thuoc' => profile(recommended_features: %w[returns teleport], sample_units: %w[vien met]))
      expect(errors).to contain_exactly('nha_thuoc.recommended_features: unknown feature "teleport".',
                                        'nha_thuoc.sample_units: unknown unit "met".')
    end

    it 'names a bad key, group, order, display and unknown field' do
      expect(errors_of('Nha-Thuoc' => profile)).to eq(['Nha-Thuoc: key must match \A[a-z_]{2,40}\z.'])
      errors = errors_of('nha_thuoc' => profile(group: 'spa', order: 0, display: { 'catalog_view' => 'grid' }, label: 'Nhà thuốc'))
      expect(errors).to contain_exactly('nha_thuoc: unknown fields label.', 'nha_thuoc.group: must be one of retail, fnb.',
                                        'nha_thuoc.order: must be a positive integer.',
                                        'nha_thuoc.display.catalog_view: "grid" must be one of cards, list.')
    end

    it 'checks the selling surface and the module it needs' do
      expect(errors_of('nha_thuoc' => profile(display: { 'surface' => 'menu_grid' }))).
        to eq(['nha_thuoc.display.surface: menu_grid needs fnb.menu.'])
      expect(errors_of('nha_thuoc' => profile(display: { 'surface' => 'floor_plan' }))).
        to eq(['nha_thuoc.display.surface: floor_plan needs fnb.tables.'])
      expect(errors_of('nha_thuoc' => profile(display: { 'surface' => 'kiosk' }))).
        to eq(['nha_thuoc.display.surface: "kiosk" must be one of catalog, menu_grid, table_grid, floor_plan, resource_board, tab_list.'])
      expect(errors_of('nha_thuoc' => profile(display: { 'surface' => 'resource_board' }))).
        to eq(['nha_thuoc.display.surface: resource_board needs resources.'])
      expect(errors_of('quan_an' => profile(group: 'fnb', modules: %w[resources fnb.tables], display: { 'surface' => 'table_grid' }))).to eq([])
      expect(errors_of('nha_thuoc' => profile(display: { 'surface' => 'catalog', 'catalog_view' => 'cards' }))).to eq([])
      expect(errors_of('quan_an' => profile(group: 'fnb', modules: ['fnb.menu'], display: { 'surface' => 'menu_grid' }))).to eq([])
    end

    it 'checks the kitchen send trigger default' do
      expect(errors_of('quan_an' => profile(branch_defaults: { 'kitchen_send_trigger' => 'manual' }))).to eq([])
      expect(errors_of('quan_an' => profile(branch_defaults: { 'kitchen_send_trigger' => 'later' }))).
        to eq(['quan_an.branch_defaults.kitchen_send_trigger: "later" must be one of on_complete, manual.'])
    end

    it 'checks the proposed kitchen stations' do
      kitchen = %w[fnb.menu fnb.kitchen]
      expect(errors_of('quan_an' => profile(modules: kitchen, kitchen_stations: %w[prep bar]))).to eq([])
      expect(errors_of('quan_an' => profile(modules: kitchen, kitchen_stations: %w[prep expo prep]))).
        to contain_exactly('quan_an.kitchen_stations: "expo" must be one of prep, bar.',
                           'quan_an.kitchen_stations: lists a kind more than once.')
      expect(errors_of('quan_an' => profile(kitchen_stations: ['prep']))).to eq(['quan_an.kitchen_stations: needs fnb.kitchen.'])
    end

    it 'names a duplicate order and a bad version' do      errors = described_class.errors_for(catalog({ 'nha_thuoc' => profile, 'my_pham' => profile }, version: 0))
      expect(errors).to contain_exactly('version: must be a positive integer.', 'profiles: order 1 is used 2 times.')
    end

    it 'raises with every message when building a bad catalog' do
      expect { described_class.build(catalog({ 'nha_thuoc' => profile(modules: ['x.y']) })) }.
        to raise_error(described_class::Invalid, /nha_thuoc\.modules: unknown module "x\.y"/)
    end

    it 'counts a profile with a planned module as coming soon' do
      built = described_class.build(catalog({ 'quan_an' => profile(group: 'retail', modules: [with_planned_module('fnb.planned_example'), 'retail.units']) }))
      expect(built.profiles.first.status).to eq('coming_soon')
    end

    it 'offers a profile that lists the table service modules' do
      built = described_class.build(catalog({ 'quan_an' => profile(group: 'fnb', modules: %w[fnb.menu resources fnb.tables]) }))
      expect(built.profiles.first.status).to eq('available')
    end

    it 'checks optional modules and leaves the status to the required ones' do
      expect(errors_of('quan_an' => profile(optional_modules: %w[resources fnb.tables]))).to eq([])
      expect(errors_of('quan_an' => profile(optional_modules: %w[fnb.tables teleport retail.units fnb.tables]))).
        to contain_exactly('quan_an.optional_modules: lists a module more than once.',
                           'quan_an.optional_modules: fnb.tables needs resources.',
                           'quan_an.optional_modules: unknown module "teleport".',
                           'quan_an.optional_modules: retail.units is already in modules.')
      expect(errors_of('quan_an' => profile(optional_modules: 'fnb.tables'))).to eq(['quan_an.optional_modules: must be a list.'])
      built = described_class.build(catalog({ 'quan_an' => profile(optional_modules: [with_planned_module('fnb.planned_example')]) }))
      expect(built.profiles.first.status).to eq('available')
    end

    it 'checks the suggested service charge rate' do
      expect(errors_of('nha_hang' => profile(branch_defaults: { 'service_charge_rate' => 5 }))).to eq([])
      expect(errors_of('nha_hang' => profile(branch_defaults: { 'service_charge_rate' => '7.5' }))).to eq([])
      expect(errors_of('nha_hang' => profile(branch_defaults: { 'service_charge_rate' => 60 }))).
        to eq(['nha_hang.branch_defaults.service_charge_rate: 60 must be empty or a percent above 0 and at most 50.'])
    end

    it 'keeps an F&B profile coming soon while its group is closed, even with every module available' do
      stub_const('Spree::Pos::BusinessProfiles::OPEN_GROUPS', %w[retail])
      built = described_class.build(catalog({ 'quan_an' => profile(group: 'fnb', modules: %w[fnb.menu fnb.order_number]) }))
      expect(built.profiles.first.status).to eq('coming_soon')
    end
  end

  describe Spree::Pos::Modules do
    let(:definition) { Spree::Pos::Modules::Definition }

    def graph(*rows)
      rows.to_h do |key, depends_on, status = 'available'|
        entrypoints = status == 'available' ? ['Spree::Pos::Modules'] : []
        [key, definition.new(key: key, group: 'retail', depends_on: depends_on, status: status, entrypoints: entrypoints)]
      end
    end

    it 'registers the three retail modules, the F&B modules, and freezes the registry' do
      expect(described_class.available_keys).to eq(%w[retail.units retail.measured retail.traceability fnb.menu fnb.recipes fnb.kitchen fnb.order_number fnb.cup_label fnb.delivery_platforms resources fnb.tables fnb.postpay fnb.service_charge
                                                          fnb.reservations fnb.bottle_keep fnb.pour_tracking fnb.meal_accounts fnb.vehicle_commission fnb.qr_order fnb.kiosk timed_billing])
      expect(described_class.find('fnb.recipes').depends_on).to eq(%w[fnb.menu retail.units])
      expect(described_class.find('retail.measured').depends_on).to eq(['retail.units'])
      expect(described_class.available?('fnb.menu')).to be(true)
      expect(described_class.find('fnb.tables').depends_on).to eq(['resources'])
      expect(described_class.find('timed_billing').depends_on).to eq(['resources', 'fnb.tables'])
      expect(described_class.all.map(&:status).uniq).to eq(['available'])
      expect(described_class.find('fnb.kitchen').depends_on).to eq(['fnb.menu'])
      expect(described_class.all).to all(be_frozen)
      expect { described_class.send(:registry)['retail.extra'] = nil }.to raise_error(FrozenError)
    end

    it 'refuses an unknown module key' do
      expect { described_class.fetch!('retail.teleport') }.to raise_error(Spree::Pos::Conflict) do |error|
        expect(error.reason).to eq('module_unknown')
        expect(error.details).to eq(module: 'retail.teleport')
      end
    end

    it 'rejects a dependency cycle, a dependency on a planned module and an unknown dependency' do
      expect { described_class.validate!(graph(['a.x', ['a.y']], ['a.y', ['a.x']])) }.to raise_error(described_class::Invalid, /cycle/)
      expect { described_class.validate!(graph(['a.x', ['a.p']], ['a.p', [], 'planned'])) }.
        to raise_error(described_class::Invalid, /"a.x" depends on planned module "a.p"/)
      expect { described_class.validate!(graph(['a.x', ['a.z']])) }.to raise_error(described_class::Invalid, /unknown module "a.z"/)
      expect(described_class.validate!(graph(['a.x', ['a.y']], ['a.y', []]))).to be(true)
    end
  end

  describe 'sample units' do
    let(:store) { create(:store) }

    it 'adds only the named units and the unit they convert to, once' do
      units = Spree::Pos::UnitDefinition.for_store(store)
      Spree::Pos::UnitDefinition.ensure_samples!(store, %w[vien pack])
      expect(units.pluck(:code)).to contain_exactly('vien', 'pack', 'chai')
      vien = units.find_by!(code: 'vien')
      expect(vien.attributes.slice('name', 'dimension', 'base_code', 'factor_to_base', 'sale_precision', 'status')).
        to eq('name' => 'Viên', 'dimension' => 'count', 'base_code' => 'vien', 'factor_to_base' => 1, 'sale_precision' => 0,
              'status' => 'active')

      expect { Spree::Pos::UnitDefinition.ensure_samples!(store, %w[vien pack bo bo_hoa]) }.to change(units, :count).by(2)
      expect(units.where(code: %w[bo bo_hoa]).pluck(:code, :name)).to contain_exactly(%w[bo Bộ], %w[bo_hoa Bó])
      expect { Spree::Pos::UnitDefinition.ensure_samples!(store, %w[vien bo]) }.not_to change(units, :count)
    end

    it 'leaves a unit the store already has as it is and refuses an unknown code' do
      Spree::Pos::UnitDefinition.create!(store: store, code: 'hop', name: 'Hộp 10', dimension: 'count', base_code: 'hop',
                                         factor_to_base: 1, sale_precision: 0, status: 'active')
      Spree::Pos::UnitDefinition.ensure_samples!(store, ['hop'])
      expect(Spree::Pos::UnitDefinition.find_by!(store: store, code: 'hop').name).to eq('Hộp 10')
      expect { Spree::Pos::UnitDefinition.ensure_samples!(store, ['met']) }.to raise_error(ArgumentError, /met/)
    end

    it 'keeps the store defaults unchanged' do
      Spree::Pos::UnitDefinition.ensure_defaults!(store)
      expect(Spree::Pos::UnitDefinition.for_store(store).order(:code).pluck(:code)).to eq(%w[case chai g item kg l ml pack])
      expect(Spree::Pos::UnitDefinition.known_codes).to include('vien', 'bo', 'bo_hoa', 'gio')
    end
  end
end
