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
    it 'offers 13 retail profiles now and 6 F&B profiles as coming soon, in picker order' do
      profiles = described_class.all
      expect(described_class.version).to eq(1)
      expect(profiles.size).to eq(19)
      expect(profiles.map(&:order)).to eq((1..19).to_a)
      expect(profiles.select { |item| item.group == 'retail' }.map(&:status)).to all(eq('available'))
      expect(profiles.select { |item| item.group == 'fnb' }.map(&:status)).to all(eq('coming_soon'))
      expect(profiles.count(&:available?)).to eq(13)
      expect(profiles.map(&:key)).to include('tap_hoa_sieu_thi', 'nha_thuoc', 'vat_lieu_xay_dung', 'khac', 'nha_hang')
    end

    it 'turns on every retail module for khac, the profile of branches that already run' do
      expect(described_class.fetch!('khac').modules).to match_array(Spree::Pos::Modules.available_keys)
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
                                        include(key: 'fnb.menu', status: 'planned'))
      expect(data[:profiles].first.keys).
        to eq(%i[key group order status modules branch_defaults display recommended_features sample_units])
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

    it 'names a duplicate order and a bad version' do
      errors = described_class.errors_for(catalog({ 'nha_thuoc' => profile, 'my_pham' => profile }, version: 0))
      expect(errors).to contain_exactly('version: must be a positive integer.', 'profiles: order 1 is used 2 times.')
    end

    it 'raises with every message when building a bad catalog' do
      expect { described_class.build(catalog({ 'nha_thuoc' => profile(modules: ['x.y']) })) }.
        to raise_error(described_class::Invalid, /nha_thuoc\.modules: unknown module "x\.y"/)
    end

    it 'counts a profile with a planned module as coming soon' do
      built = described_class.build(catalog({ 'quan_an' => profile(group: 'fnb', modules: ['fnb.menu', 'retail.units']) }))
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

    it 'registers the three retail modules, the planned F&B names, and freezes the registry' do
      expect(described_class.available_keys).to eq(%w[retail.units retail.measured retail.traceability])
      expect(described_class.find('retail.measured').depends_on).to eq(['retail.units'])
      expect(described_class.known?('fnb.menu')).to be(true)
      expect(described_class.available?('fnb.menu')).to be(false)
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
