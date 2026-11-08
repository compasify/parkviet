# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Print templates of the store's POS documents. Active members of
          # any branch and topology readers read them (a reprint may need a
          # disabled template's old version); only `write_pos_topology`
          # changes them. Every save adds an immutable version, a stale
          # `expected_version` is refused instead of overwriting someone
          # else's edit, and every change is audited (`receipt_template.*`).
          class ReceiptTemplatesController < BaseController
            scoped_resource :pos_topology
            READERS = %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology].freeze
            WRITERS = %w[write_pos_topology].freeze
            pos_permissions index: READERS, show: READERS, versions: WRITERS, create: WRITERS, update: WRITERS,
                            duplicate: WRITERS, default: WRITERS, restore: WRITERS, disable: WRITERS

            Template = Spree::Pos::ReceiptTemplate
            Invalid = Spree::Pos::ReceiptTemplateSchema::Invalid

            def index
              return if channel_rejected?

              readable!
              include_disabled = ActiveModel::Type::Boolean.new.cast(params[:include_disabled]) == true
              raise CanCan::AccessDenied if include_disabled && !administrator?

              Template.ensure_defaults!(current_store)
              scope = Template.for_store(current_store).includes(:updated_by)
              scope = scope.active unless include_disabled
              scope = scope.where(document_type: document_type!(params[:document_type], '/document_type')) if params[:document_type].present?
              templates = scope.order(:document_type, is_default: :desc, name: :asc, id: :asc).to_a
              versions = Template.current_versions(templates)
              render json: { data: templates.map { |template| template.to_pos(versions.fetch(template.id)) } }
            end

            # `?version=N` serves that saved version, disabled templates included.
            def show
              return if channel_rejected?

              readable!
              template = template!
              version = params[:version].present? ? template.version_record(positive_integer!(params[:version], '/version')) : nil
              raise ActiveRecord::RecordNotFound if params[:version].present? && version.nil?

              render json: { data: template.to_pos(version) }
            end

            def versions
              return if channel_rejected?

              template = template!
              records, meta = page_scope(template.versions.includes(:created_by).order(version: :desc))
              render json: { data: records.map(&:to_pos), meta: meta }
            end

            # From the built-in template (`from_default: <document_type>`) or a given `config`.
            def create
              return if channel_rejected?

              document_type, config = creation_source
              paper = params.key?(:paper) ? paper!(params[:paper]) : Template::DEFAULT_PAPER
              name = params.key?(:name) ? name!(params[:name]) : Template::DEFAULT_NAMES.fetch(document_type)
              template = Template.transaction do
                Template.ensure_defaults!(current_store)
                Template.lock_type!(current_store, document_type)
                Template.ensure_room!(current_store, document_type)
                created = Template.create_with_version!(store: current_store, document_type: document_type, name: name,
                                                        paper: paper, config: config, actor: current_user)
                audit!('receipt_template.create', created, created.audit_metadata)
                created
              end
              render json: { data: template.to_pos }, status: :created
            end

            # Requires the `expected_version` the edit started from; any change
            # (name, paper or config) saves a new version.
            def update
              return if channel_rejected?

              template = template!
              expected = positive_integer!(params[:expected_version], '/expected_version')
              config = params.key?(:config) ? valid_config!(template.document_type) : nil
              attributes = {}
              attributes[:name] = name!(params[:name]) if params.key?(:name)
              attributes[:paper] = paper!(params[:paper]) if params.key?(:paper)
              template.with_lock do
                editable!(template)
                stale!(template, expected)
                current = template.current_config
                template.assign_attributes(attributes)
                if template.changed? || (config && config != current)
                  template.revise!(config: config || current, actor: current_user)
                  audit!('receipt_template.update', template, template.audit_metadata)
                end
              end
              render json: { data: template.to_pos }
            end

            def duplicate
              return if channel_rejected?

              source = template!
              paper = params.key?(:paper) ? paper!(params[:paper]) : source.paper
              name = params.key?(:name) ? name!(params[:name]) : "#{source.name} (bản sao)".first(Template::MAX_NAME_LENGTH)
              template = Template.transaction do
                Template.lock_type!(current_store, source.document_type)
                Template.ensure_room!(current_store, source.document_type)
                created = Template.create_with_version!(store: current_store, document_type: source.document_type, name: name,
                                                        paper: paper, config: source.current_config, actor: current_user)
                audit!('receipt_template.duplicate', created,
                       created.audit_metadata.merge(source_id: source.prefixed_id, source_version: source.current_version))
                created
              end
              render json: { data: template.to_pos }, status: :created
            end

            # Makes this the default of its document type.
            def default
              return if channel_rejected?

              template = template!
              Template.transaction do
                others = Template.lock_type!(current_store, template.document_type)
                template.reload
                editable!(template)
                unless template.is_default
                  previous = others.find(&:is_default)
                  previous&.update!(is_default: false, updated_by: current_user)
                  template.update!(is_default: true, updated_by: current_user)
                  audit!('receipt_template.default', template,
                         template.audit_metadata.merge(previous_default_id: previous&.prefixed_id))
                end
              end
              render json: { data: template.to_pos }
            end

            # Saves the config of an earlier `version` as a new version.
            def restore
              return if channel_rejected?

              template = template!
              number = positive_integer!(params[:version], '/version')
              expected = params[:expected_version].present? ? positive_integer!(params[:expected_version], '/expected_version') : nil
              template.with_lock do
                editable!(template)
                stale!(template, expected) if expected
                source = template.version_record(number)
                raise Invalid.at('/version', 'not_found', 'This version does not exist.') if source.nil?

                template.revise!(config: source.config, actor: current_user)
                audit!('receipt_template.restore', template, template.audit_metadata.merge(restored_version: number))
              end
              render json: { data: template.to_pos }
            end

            # The default of a type is handed to its oldest other active
            # template; the only active template of a type stays on.
            def disable
              return if channel_rejected?

              template = template!
              Template.transaction do
                others = Template.lock_type!(current_store, template.document_type)
                template.reload
                unless template.disabled?
                  successor = template.is_default ? others.find { |other| other.id != template.id } : nil
                  if template.is_default && successor.nil?
                    raise Spree::Pos::Conflict.new('The only active template of a document type cannot be disabled.',
                                                   reason: 'template_default_required')
                  end

                  template.update!(status: 'disabled', is_default: false, updated_by: current_user)
                  successor&.update!(is_default: true, updated_by: current_user)
                  audit!('receipt_template.disable', template,
                         template.audit_metadata.merge(new_default_id: successor&.prefixed_id))
                end
              end
              render json: { data: template.to_pos }
            end

            private

            def administrator?
              policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology')
            end

            def readable!
              return if administrator? || policy.memberships.where(status: 'active').exists?

              raise CanCan::AccessDenied
            end

            def template!
              template = Template.locate(Template.for_store(current_store), params[:id])
              raise ActiveRecord::RecordNotFound if template.nil?

              template
            end

            def editable!(template)
              raise Spree::Pos::Conflict.new('A disabled template cannot be changed.', reason: 'template_disabled') if template.disabled?
            end

            def stale!(template, expected)
              return if template.current_version == expected

              raise Spree::Pos::Conflict.new('The template was changed by someone else.', reason: 'template_version_conflict',
                                                                                          details: { current_version: template.current_version })
            end

            def creation_source
              if params[:from_default].present?
                raise Invalid.at('/config', 'unexpected', 'Give from_default or config, not both.') if params.key?(:config)

                type = document_type!(params[:from_default], '/from_default')
                if params[:document_type].present? && params[:document_type] != type
                  raise Invalid.at('/document_type', 'mismatch', 'document_type must match from_default.')
                end

                [type, Template.default_config(type)]
              else
                type = document_type!(params[:document_type], '/document_type')
                raise Invalid.at('/config', 'missing', 'Give from_default or config.') unless params.key?(:config)

                [type, valid_config!(type)]
              end
            end

            # The config as plain JSON data, validated for the document type.
            def valid_config!(document_type)
              raw = params.to_unsafe_h['config']
              config = raw.is_a?(Hash) ? JSON.parse(raw.to_json) : raw
              Spree::Pos::ReceiptTemplateSchema.validate!(config, document_type)
            end

            def document_type!(value, pointer)
              return value if Template::DOCUMENT_TYPES.include?(value)

              raise Invalid.at(pointer, 'invalid_value', "Document type must be one of #{Template::DOCUMENT_TYPES.join(', ')}.")
            end

            def paper!(value)
              return value if Template::PAPERS.include?(value)

              raise Invalid.at('/paper', 'invalid_value', "Paper must be one of #{Template::PAPERS.join(', ')}.")
            end

            def positive_integer!(value, pointer)
              number = value.is_a?(Integer) ? value : Integer(value.to_s, 10, exception: false)
              return number if number&.positive?

              raise Invalid.at(pointer, value.blank? ? 'missing' : 'invalid_value', "#{pointer.delete_prefix('/')} must be a positive whole number.")
            end

            def name!(value)
              name = value.to_s.strip
              raise Invalid.at('/name', 'blank', 'Name cannot be empty.') if name.empty?
              if name.length > Template::MAX_NAME_LENGTH
                raise Invalid.at('/name', 'too_long', "Name must be at most #{Template::MAX_NAME_LENGTH} characters.")
              end

              name
            end
          end
        end
      end
    end
  end
end
