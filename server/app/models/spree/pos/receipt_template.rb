# frozen_string_literal: true

module Spree
  module Pos
    # A store's print template for one document type. Branches and registers
    # have none of their own; their details reach the print through template
    # variables. Every save adds an immutable version, and a template is
    # disabled, never deleted, because recorded prints point at it. Each
    # document type keeps exactly one active default.
    class ReceiptTemplate < Record
      self.table_name = 'spree_pos_receipt_templates'
      has_prefix_id :postpl

      DOCUMENT_TYPES = ReceiptTemplateSchema::DOCUMENT_TYPES
      PAPERS = %w[58mm 80mm a4 a5 a6].freeze
      DEFAULT_PAPER = '80mm'
      MAX_ACTIVE = 5
      MAX_NAME_LENGTH = 60
      DEFAULT_NAMES = {
        'sale' => 'Phiếu bán hàng', 'prebill' => 'Phiếu tạm tính', 'payment_ticket' => 'Phiếu thanh toán',
        'return' => 'Phiếu trả hàng', 'refund' => 'Phiếu hoàn tiền', 'shift_closure' => 'Phiếu chốt ca'
      }.freeze
      # The built-in configs, mirrored by the POS client's fallback templates.
      DEFAULT_CONFIGS = DOCUMENT_TYPES.index_with do |type|
        JSON.parse(Rails.root.join("config/pos/receipt_templates/#{type}.json").read).freeze
      end.freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :created_by, class_name: staff_class_name, optional: true
      belongs_to :updated_by, class_name: staff_class_name, optional: true
      has_many :versions, class_name: 'Spree::Pos::ReceiptTemplateVersion', inverse_of: :receipt_template,
                          dependent: :restrict_with_error

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
      validates :document_type, inclusion: { in: DOCUMENT_TYPES }
      validates :paper, inclusion: { in: PAPERS }
      validates :status, inclusion: { in: %w[active disabled] }
      validates :current_version, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      # Posted documents print with the template of their type; a return
      # supplement uses the return template.
      def self.document_type_for(source_type)
        source_type == 'return_supplement' ? 'return' : source_type
      end

      def self.default_config(document_type)
        DEFAULT_CONFIGS.fetch(document_type).deep_dup
      end

      # Gives every document type of the store an active default, creating
      # the built-in template the first time. Safe to call concurrently.
      def self.ensure_defaults!(store)
        present = for_store(store).active.where(is_default: true).pluck(:document_type)
        (DOCUMENT_TYPES - present).each do |type|
          transaction(requires_new: true) do
            fallback = for_store(store).active.where(document_type: type).order(:id).lock.first
            if fallback
              fallback.update!(is_default: true)
            else
              create_with_version!(store: store, document_type: type, name: DEFAULT_NAMES.fetch(type), paper: DEFAULT_PAPER,
                                   config: default_config(type), actor: nil, default: true)
            end
          end
        rescue ActiveRecord::RecordNotUnique
          # Another request gave this type its default first.
          next
        end
      end

      def self.create_with_version!(store:, document_type:, name:, paper:, config:, actor:, default: false)
        template = create!(store: store, document_type: document_type, name: name, paper: paper, status: 'active',
                           is_default: default, current_version: 1, created_by: actor, updated_by: actor)
        template.versions.create!(version: 1, config: config, created_by: actor)
        template
      end

      # Locks the active templates of one document type so the active limit
      # and the single default hold under concurrent changes.
      def self.lock_type!(store, document_type)
        for_store(store).active.where(document_type: document_type).order(:id).lock.to_a
      end

      def self.ensure_room!(store, document_type)
        return if for_store(store).active.where(document_type: document_type).count < MAX_ACTIVE

        raise Conflict.new("At most #{MAX_ACTIVE} active templates per document type.", reason: 'template_limit_reached',
                                                                                        details: { limit: MAX_ACTIVE })
      end

      # The current version of each template, in one query.
      def self.current_versions(templates)
        ReceiptTemplateVersion.joins(:receipt_template).
          where(receipt_template_id: templates.map(&:id)).
          where('spree_pos_receipt_template_versions.version = spree_pos_receipt_templates.current_version').
          index_by(&:receipt_template_id)
      end

      def disabled?
        status == 'disabled'
      end

      def version_record(number = current_version)
        versions.find_by(version: number)
      end

      def current_config
        version_record.config
      end

      # A new version holding `config`, with any attribute changes.
      def revise!(config:, actor:, **attributes)
        self.current_version += 1
        assign_attributes(attributes.merge(updated_by: actor))
        save!
        versions.create!(version: current_version, config: config, created_by: actor)
      end

      def audit_metadata
        { id: prefixed_id, document_type: document_type, name: name, paper: paper, status: status,
          is_default: is_default, version: current_version }
      end

      # The template with the config of `version` (the current one unless given).
      def to_pos(version = nil)
        version ||= version_record
        {
          id: prefixed_id, document_type: document_type, name: name, paper: paper, status: status,
          is_default: is_default, current_version: current_version, version: version.version, config: version.config,
          updated_by: updated_by && { id: updated_by.prefixed_id, name: StaffName.call(updated_by) },
          created_at: created_at.iso8601, updated_at: updated_at.iso8601
        }
      end
    end
  end
end
