# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Store administrators set which e-invoice the store issues and with
      # which provider: the store default row, or a branch's own row (its
      # seller details and symbol; `disabled` makes the branch use the
      # default again). Credentials are write-only: a new object replaces
      # the stored one, an absent one keeps it. Only registered providers
      # are accepted. Issuing anything needs an active store default.
      # Audited as `einvoice_settings.change`, never with credential values.
      module SaveSettings
        SETTING_FIELDS = %w[provider template_code symbol seller_name seller_tax_code seller_address consumer_label lookup_url
                            buyer_link_hours status].freeze

        module_function

        def call(store:, staff:, key:, einvoice_type: nil, setting: nil, branch: nil)
          fields = setting.respond_to?(:to_unsafe_h) ? setting.to_unsafe_h : setting
          credentials = fields.is_a?(Hash) ? (fields['credentials'] || fields[:credentials]) : nil
          payload = { 'command' => 'einvoice_settings.save', 'einvoice_type' => einvoice_type, 'branch_id' => branch&.prefixed_id,
                      'setting' => fields.is_a?(Hash) ? fields.except('credentials', :credentials) : nil,
                      'credentials_digest' => credentials &&
                        OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, credentials.to_json) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Einvoices.settings!(store, staff) }) do
            changes = {}
            changes[:setting] = save_setting!(store, staff, branch, fields, credentials) if fields.is_a?(Hash)
            changes[:einvoice_type] = save_type!(store, einvoice_type) unless einvoice_type.nil?
            AuditEntry.record!(store: store, actor: staff, action: 'einvoice_settings.change', subject: store,
                               metadata: changes.merge(branch_id: branch&.prefixed_id))
            { 'saved' => true }
          end
        end

        def save_setting!(store, staff, branch, fields, credentials)
          row = EinvoiceSetting.lock.find_or_initialize_by(store_id: store.id, branch_id: branch&.id)
          values = SETTING_FIELDS.each_with_object({}) do |field, result|
            next unless fields.key?(field) || fields.key?(field.to_sym)

            value = fields[field] || fields[field.to_sym]
            result[field] = value.is_a?(String) ? value.strip.presence : value
          end
          values['symbol'] = values['symbol'].upcase if values['symbol']
          provider = values.fetch('provider', row.provider)
          raise Conflict.new('This provider has no adapter.', reason: 'einvoice_provider_unknown') unless provider && Einvoices.registered?(provider)

          row.assign_attributes(values.merge('changed_by' => staff))
          row.status ||= 'active'
          row.credential_values = clean_credentials(credentials) if credentials
          unless row.valid?
            field = row.errors.attribute_names.first.to_s
            raise Conflict.new("The setting #{field.tr('_', ' ')} is invalid.", reason: 'einvoice_setting_invalid', details: { field: field })
          end

          changed = row.changed - %w[credentials changed_by_id updated_at]
          row.save!
          { fields: changed, credentials_changed: !credentials.nil? }
        end

        def clean_credentials(value)
          raw = value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value
          raise Conflict.new('Credentials must be an object of text fields.', reason: 'einvoice_setting_invalid') unless raw.is_a?(Hash)

          raw.each_with_object({}) do |(name, text), result|
            next if text.nil? || text.to_s.strip.empty?
            raise Conflict.new('Credentials must be an object of text fields.', reason: 'einvoice_setting_invalid') if text.is_a?(Hash) ||
              text.is_a?(Array)

            result[name.to_s.first(60)] = text.to_s.first(500)
          end
        end

        def save_type!(store, type)
          raise Conflict.new('Unknown e-invoice type.', reason: 'einvoice_type_invalid') unless StoreProfile::EINVOICE_TYPES.include?(type)

          profile = StoreProfile.lock.find_by(store_id: store.id)
          raise Conflict.new('Set up the store profile first.', reason: 'store_profile_required') if profile.nil?
          if type != 'none' && !EinvoiceSetting.active.exists?(store_id: store.id, branch_id: nil)
            raise Conflict.new('Choose a provider before issuing e-invoices.', reason: Issue::NOT_CONFIGURED)
          end

          before = profile.einvoice_type
          profile.update!(einvoice_type: type)
          { from: before, to: type }
        end
      end
    end
  end
end
