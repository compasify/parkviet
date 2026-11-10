# frozen_string_literal: true

require 'spree/api/testing_support/v3/base'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# Store-wide POS master data managed from the dashboard (payment methods,
# units, staff roles, scale label formats, print templates) and what each
# branch takes from it.
RSpec.describe 'POS shared master data', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:other_branch) { returns_branch(store) }
  let(:admin) { credit_staff(store, branch, [], extra_permissions: %w[read_pos_topology write_pos_topology]) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }

  before { allow(Spree::Store).to receive(:default).and_return(store) }

  def token_for(user)
    @tokens ||= {}
    @tokens[user.id] ||= begin
      post '/api/v3/admin/auth/login', params: { email: user.email, password: 'secret123' }, as: :json
      response.parsed_body.fetch('token')
    end
  end

  def call(user, verb, path, body = {})
    send(verb, "/api/v3/admin/pos/#{path}", headers: { 'Authorization' => "Bearer #{token_for(user)}" },
                                            params: body, as: verb == :get ? nil : :json)
    response.parsed_body
  end

  describe 'payment methods' do
    def resolver
      Spree::Pos::PaymentMethodResolver.new(store: store)
    end

    it 'saves the built-in methods, manages them and keeps one active cash method' do
      list = call(admin, :get, 'payment_methods')['data']
      expect(response).to have_http_status(:ok)
      expect(list.map { |row| row['kind'] }).to include('cash', 'bank_manual')
      cash = list.find { |row| row['kind'] == 'cash' }
      expect(cash['id']).to start_with('pospaymethod_')

      created = call(admin, :post, 'payment_methods', { kind: 'bank_manual', name: 'Chuyển khoản MB', code: 'mb_bank' })['data']
      expect(response).to have_http_status(:created)
      expect(created).to include('kind' => 'bank_manual', 'name' => 'Chuyển khoản MB', 'status' => 'active')
      call(admin, :post, 'payment_methods', { kind: 'bank_manual', name: 'Trùng', code: 'mb_bank' })
      expect(response).to have_http_status(:unprocessable_content)
      call(admin, :post, 'payment_methods', { kind: 'card', name: 'Thẻ' })
      expect(response).to have_http_status(:unprocessable_content)

      call(admin, :patch, "payment_methods/#{created['id']}", { name: 'MB Bank', position: 7 })
      expect(response.parsed_body['data']).to include('name' => 'MB Bank', 'position' => 7)
      call(admin, :patch, "payment_methods/#{created['id']}", { status: 'disabled' })
      expect(response.parsed_body.dig('data', 'status')).to eq('disabled')
      expect(resolver.available.map(&:prefixed_id)).not_to include(created['id'])
      expect(call(admin, :get, 'payment_methods')['data'].map { |row| row['id'] }).not_to include(created['id'])
      expect(call(admin, :get, 'payment_methods', { include_disabled: true })['data'].map { |row| row['id'] }).to include(created['id'])

      call(admin, :patch, "payment_methods/#{cash['id']}", { status: 'disabled' })
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('last_cash_method')

      call(admin, :delete, "payment_methods/#{created['id']}")
      expect(response).to have_http_status(:no_content)
      expect(Spree::Pos::PosPaymentMethod.locate(Spree::Pos::PosPaymentMethod.for_store(store), created['id'])).to be_nil
    end

    it 'offers every method until a branch chooses, then only the chosen ones' do
      list = call(admin, :get, 'payment_methods')['data']
      cash = list.find { |row| row['kind'] == 'cash' }
      bank = list.find { |row| row['kind'] == 'bank_manual' }

      selection = call(admin, :get, "branches/#{branch.prefixed_id}/payment_methods")['data']
      expect(selection['customized']).to be(false)
      expect(selection['payment_methods'].map { |row| row['enabled'] }.uniq).to eq([true])

      call(admin, :put, "branches/#{branch.prefixed_id}/payment_methods", { payment_method_ids: [cash['id']] })
      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data['customized']).to be(true)
      expect(data['payment_methods'].find { |row| row['id'] == bank['id'] }['enabled']).to be(false)

      expect(resolver.available(branch: branch).map(&:prefixed_id)).to eq([cash['id']])
      expect(resolver.available(branch: other_branch).map(&:prefixed_id)).to include(cash['id'], bank['id'])
      expect { resolver.resolve!(bank['id'], branch: branch) }.to raise_error(Spree::Pos::Conflict, /does not offer/)
      expect(resolver.resolve!(bank['id'], branch: other_branch).first.prefixed_id).to eq(bank['id'])

      call(admin, :put, "branches/#{branch.prefixed_id}/payment_methods", { payment_method_ids: [] })
      expect(response).to have_http_status(:unprocessable_content)
      call(admin, :put, "branches/#{branch.prefixed_id}/payment_methods", { payment_method_ids: nil })
      expect(response.parsed_body.dig('data', 'customized')).to be(false)
      expect(resolver.available(branch: branch).map(&:prefixed_id)).to include(bank['id'])
    end

    it 'keeps the methods to topology readers and writers' do
      call(cashier, :get, 'payment_methods')
      expect(response).to have_http_status(:forbidden)
      call(cashier, :put, "branches/#{branch.prefixed_id}/payment_methods", { payment_method_ids: nil })
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'units' do
    it 'creates, renames, disables and re-enables store units' do
      created = call(admin, :post, 'units', { code: 'yen', name: 'Yến', dimension: 'mass', base_code: 'g', factor_to_base: 10_000,
                                              sale_precision: 2 })['data']
      expect(response).to have_http_status(:created)
      expect(created).to include('code' => 'yen', 'base_code' => 'g', 'factor_to_base' => 10_000, 'status' => 'active')

      call(admin, :post, 'units', { code: 'bad', name: 'Sai', dimension: 'mass', base_code: 'kg', factor_to_base: 2 })
      expect(response).to have_http_status(:unprocessable_content)
      call(admin, :post, 'units', { code: 'yen', name: 'Trùng', dimension: 'mass', base_code: 'g', factor_to_base: 1 })
      expect(response).to have_http_status(:unprocessable_content)

      call(admin, :patch, "units/#{created['id']}", { name: 'Yến (10kg)' })
      expect(response.parsed_body['data']).to include('name' => 'Yến (10kg)', 'version' => 2)
      call(admin, :patch, "units/#{created['id']}", { factor_to_base: 5 })
      expect(response).to have_http_status(:conflict)

      call(admin, :post, "units/#{created['id']}/disable")
      expect(response.parsed_body.dig('data', 'status')).to eq('disabled')
      expect(call(admin, :get, 'units')['data'].map { |row| row['code'] }).not_to include('yen')
      expect(call(admin, :get, 'units', { include_disabled: true })['data'].map { |row| row['code'] }).to include('yen')
      call(admin, :post, "units/#{created['id']}/enable")
      expect(response.parsed_body.dig('data', 'status')).to eq('active')

      call(cashier, :post, 'units', { code: 'bao', name: 'Bao', dimension: 'count', factor_to_base: 1 })
      expect(response).to have_http_status(:forbidden)
    end

    it 'refuses to disable a unit that SKUs or other units still use' do
      Spree::Pos::UnitDefinition.ensure_defaults!(store)
      gram = Spree::Pos::UnitDefinition.find_by!(store: store, code: 'g')
      call(admin, :post, "units/#{gram.prefixed_id}/disable")
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body.dig('error', 'details', 'reason')).to eq('unit_in_use')

      bottle = Spree::Pos::UnitDefinition.find_by!(store: store, code: 'case')
      product = create(:product, store: store, status: 'active')
      Spree::Pos::VariantUnit.create!(store: store, variant: product.default_variant, sale_unit: bottle, base_unit: bottle,
                                      price_unit: bottle, ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none',
                                      status: 'active', version: 1)
      call(admin, :post, "units/#{bottle.prefixed_id}/disable")
      expect(response).to have_http_status(:conflict)

      item = Spree::Pos::UnitDefinition.find_by!(store: store, code: 'item')
      call(admin, :post, "units/#{item.prefixed_id}/disable")
      expect(response).to have_http_status(:conflict)
    end
  end

  describe 'staff roles' do
    let(:clerk) { credit_staff(store, branch, []) }
    let(:membership) { Spree::Pos::StaffMembership.find_by!(staff: clerk, branch: branch) }

    def capabilities_of(user)
      call(user, :get, 'context', { branch_id: branch.prefixed_id })['capabilities']
    end

    it 'grants the role capabilities to its members and follows role changes' do
      role = call(admin, :post, 'staff_roles', { name: 'Thu ngân', capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT] })['data']
      expect(response).to have_http_status(:created)
      call(admin, :post, 'staff_roles', { name: 'thu ngân', capabilities: [] })
      expect(response).to have_http_status(:unprocessable_content)
      call(admin, :post, 'staff_roles', { name: 'Sai', capabilities: ['pos.unknown'] })
      expect(response).to have_http_status(:unprocessable_content)

      expect(capabilities_of(clerk)).not_to include(Spree::Pos::Capabilities::OPEN_SHIFT)
      updated = call(admin, :patch, "memberships/#{membership.prefixed_id}", { staff_role_id: role['id'] })['data']
      expect(updated['staff_role']).to eq('id' => role['id'], 'name' => 'Thu ngân')
      expect(updated['capabilities']).to eq([Spree::Pos::Capabilities::OPEN_SHIFT])
      expect(capabilities_of(clerk)).to include(Spree::Pos::Capabilities::OPEN_SHIFT)

      call(admin, :patch, "staff_roles/#{role['id']}", { capabilities: [Spree::Pos::Capabilities::CUSTOMER] })
      expect(capabilities_of(clerk)).to include(Spree::Pos::Capabilities::CUSTOMER)
      expect(capabilities_of(clerk)).not_to include(Spree::Pos::Capabilities::OPEN_SHIFT)

      call(admin, :patch, "staff_roles/#{role['id']}", { status: 'disabled' })
      expect(response).to have_http_status(:conflict)
      call(admin, :delete, "staff_roles/#{role['id']}")
      expect(response).to have_http_status(:conflict)

      call(admin, :patch, "memberships/#{membership.prefixed_id}", { staff_role_id: nil })
      expect(response.parsed_body.dig('data', 'staff_role')).to be_nil
      expect(capabilities_of(clerk)).not_to include(Spree::Pos::Capabilities::CUSTOMER)

      call(admin, :patch, "staff_roles/#{role['id']}", { status: 'disabled' })
      expect(response.parsed_body.dig('data', 'status')).to eq('disabled')
      call(admin, :patch, "memberships/#{membership.prefixed_id}", { staff_role_id: role['id'] })
      expect(response).to have_http_status(:unprocessable_content)
      call(admin, :delete, "staff_roles/#{role['id']}")
      expect(response).to have_http_status(:no_content)
    end

    it 'keeps roles to topology readers and writers' do
      call(cashier, :get, 'staff_roles')
      expect(response).to have_http_status(:forbidden)
      call(cashier, :post, 'staff_roles', { name: 'X', capabilities: [] })
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'scale label formats' do
    let(:format_body) do
      { name: 'Cân điện tử', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: 'g' }
    end

    def parse(barcode)
      call(admin, :post, 'measurement_barcodes/parse', { branch_id: branch.prefixed_id, barcode: barcode })
    end

    def ean(body)
      sum = body.chars.each_with_index.sum { |char, index| char.to_i * (index.even? ? 1 : 3) }
      "#{body}#{(10 - (sum % 10)) % 10}"
    end

    it 'shares store formats and reads only the formats assigned to the branch' do
      Spree::Pos::UnitDefinition.ensure_defaults!(store)
      gram = Spree::Pos::UnitDefinition.find_by!(store: store, code: 'g')
      kilo = Spree::Pos::UnitDefinition.find_by!(store: store, code: 'kg')
      product = create(:product, store: store, status: 'active')
      product.default_variant.set_price('VND', 100_000)
      Spree::Pos::BranchProduct.create!(branch: branch, product: product)
      Spree::Pos::VariantUnit.create!(store: store, variant: product.default_variant, sale_unit: kilo, base_unit: gram,
                                      price_unit: kilo, ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none',
                                      status: 'active', version: 1, label_code: '12345')

      shared = call(admin, :post, 'label_formats', format_body)['data']
      expect(response).to have_http_status(:created)
      expect(shared).to include('branch_id' => nil, 'branch_ids' => [])
      expect(call(admin, :get, "branches/#{branch.prefixed_id}/label_formats")['data']).to be_empty
      expect(parse(ean('211234501250')).dig('data', 'kind')).to eq('ordinary')

      assigned = call(admin, :put, "branches/#{branch.prefixed_id}/label_formats", { label_format_ids: [shared['id']] })['data']
      expect(response).to have_http_status(:ok)
      expect(assigned.map { |row| row['id'] }).to eq([shared['id']])
      expect(assigned.first['branch_ids']).to eq([branch.prefixed_id])
      expect(parse(ean('211234501250')).dig('data', 'kind')).to eq('measured_label')
      expect(call(admin, :get, 'label_formats')['data'].map { |row| row['id'] }).to eq([shared['id']])

      twin = call(admin, :post, 'label_formats', format_body.merge(name: 'Trùng tiền tố'))['data']
      call(admin, :put, "branches/#{branch.prefixed_id}/label_formats", { label_format_ids: [shared['id'], twin['id']] })
      expect(response).to have_http_status(:conflict)
      call(admin, :put, "branches/#{other_branch.prefixed_id}/label_formats", { label_format_ids: [twin['id']] })
      expect(response).to have_http_status(:ok)

      call(admin, :put, "branches/#{branch.prefixed_id}/label_formats", { label_format_ids: [] })
      expect(parse(ean('211234501250')).dig('data', 'kind')).to eq('ordinary')
    end

    it 'assigns a format created under a branch to that branch' do
      created = call(admin, :post, "branches/#{branch.prefixed_id}/label_formats", format_body)['data']
      expect(response).to have_http_status(:created)
      expect(created).to include('branch_id' => branch.prefixed_id, 'branch_ids' => [branch.prefixed_id])
      call(admin, :post, "branches/#{branch.prefixed_id}/label_formats", format_body.merge(name: 'Trùng'))
      expect(response).to have_http_status(:conflict)
    end
  end

  describe 'print templates per branch' do
    def template_id(type)
      call(admin, :get, 'receipt_templates', { document_type: type })['data'].find { |row| row['is_default'] }['id']
    end

    it 'prints with the branch choice while it is active, else the store default' do
      default_id = template_id('sale')
      chosen = call(admin, :post, 'receipt_templates', { from_default: 'sale', name: 'K58', paper: '58mm' })['data']

      call(admin, :put, "branches/#{branch.prefixed_id}/receipt_templates", { templates: { sale: chosen['id'] } })
      expect(response).to have_http_status(:ok)
      sale = response.parsed_body.dig('data', 'templates').find { |row| row['document_type'] == 'sale' }
      expect(sale.dig('receipt_template', 'id')).to eq(chosen['id'])
      expect(sale.dig('effective_template', 'id')).to eq(chosen['id'])
      expect(Spree::Pos::ReceiptTemplate.effective_for(store, 'sale', branch: branch).prefixed_id).to eq(chosen['id'])
      expect(Spree::Pos::ReceiptTemplate.effective_for(store, 'sale', branch: other_branch).prefixed_id).to eq(default_id)

      list = call(admin, :get, 'receipt_templates', { document_type: 'sale', branch_id: branch.prefixed_id })['data']
      expect(list.select { |row| row['branch_default'] }.map { |row| row['id'] }).to eq([chosen['id']])

      call(admin, :put, "branches/#{branch.prefixed_id}/receipt_templates", { templates: { refund: chosen['id'] } })
      expect(response).to have_http_status(:unprocessable_content)

      call(admin, :post, "receipt_templates/#{chosen['id']}/disable")
      expect(Spree::Pos::ReceiptTemplate.effective_for(store, 'sale', branch: branch).prefixed_id).to eq(default_id)

      call(admin, :put, "branches/#{branch.prefixed_id}/receipt_templates", { templates: { sale: nil } })
      sale = response.parsed_body.dig('data', 'templates').find { |row| row['document_type'] == 'sale' }
      expect(sale['receipt_template']).to be_nil
      expect(sale['uses_store_default']).to be(true)

      call(cashier, :put, "branches/#{branch.prefixed_id}/receipt_templates", { templates: { sale: nil } })
      expect(response).to have_http_status(:forbidden)
    end
  end
end
