# frozen_string_literal: true

module Spree
  module Pos
    # A store's e-invoice provider settings. The row without a branch is the
    # store default; a branch row overrides it for that branch, with the
    # branch's own seller details and invoice symbol. Credentials are a JSON
    # object of the provider's own fields, encrypted at rest (when Active
    # Record encryption keys are configured, as production requires), and
    # never returned: `to_pos` lists only which fields are set.
    class EinvoiceSetting < Record
      self.table_name = 'spree_pos_einvoice_settings'
      has_prefix_id :poseinvset

      STATUSES = %w[active disabled].freeze
      DEFAULT_CONSUMER_LABEL = 'Bán cho người tiêu dùng'
      TAX_CODE = /\A\d{10}(-\d{3})?\z/
      SYMBOL = /\A[CK]\d{2}[A-Z]{3}\z/
      TEMPLATE = /\A[1-9]\z/

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch', optional: true
      belongs_to :changed_by, class_name: staff_class_name, optional: true

      encrypts :credentials, support_unencrypted_data: true if ActiveRecord::Encryption.config.has_primary_key?

      validates :status, inclusion: { in: STATUSES }
      validates :provider, presence: true
      validates :template_code, format: { with: TEMPLATE }, allow_blank: true
      validates :symbol, format: { with: SYMBOL }, allow_blank: true
      validates :seller_tax_code, format: { with: TAX_CODE }, allow_blank: true
      validates :seller_name, :seller_address, length: { maximum: 400 }
      validates :consumer_label, length: { maximum: 100 }
      validates :buyer_link_hours, numericality: { only_integer: true, in: 1..720 }, allow_nil: true
      validate :lookup_url_is_web

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      # The settings a branch issues with: its own row, else the store default.
      def self.for_branch(branch)
        rows = active.where(store_id: branch.store_id, branch_id: [branch.id, nil]).to_a
        rows.find { |row| row.branch_id == branch.id } || rows.find { |row| row.branch_id.nil? }
      end

      def credential_values
        value = credentials.presence && JSON.parse(credentials)
        value.is_a?(Hash) ? value : {}
      rescue JSON::ParserError
        {}
      end

      def credential_values=(hash)
        self.credentials = hash.presence && JSON.generate(hash)
      end

      def consumer_label_text
        consumer_label.presence || DEFAULT_CONSUMER_LABEL
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch&.prefixed_id, branch_name: branch&.name, provider: provider, status: status,
          template_code: template_code, symbol: symbol, seller_name: seller_name, seller_tax_code: seller_tax_code,
          seller_address: seller_address, consumer_label: consumer_label, lookup_url: lookup_url,
          buyer_link_hours: buyer_link_hours, credential_fields: credential_values.keys.sort,
          updated_at: updated_at&.iso8601
        }
      end

      private

      def lookup_url_is_web
        return if lookup_url.blank?
        return if lookup_url.length <= 300 && lookup_url.match?(%r{\Ahttps?://[^\s]+\z}i)

        errors.add(:lookup_url, :invalid)
      end
    end
  end
end
