# frozen_string_literal: true

module Spree
  module Pos
    # One print of a receipt snapshot. Number 0 is the original; every later
    # print is a numbered copy. A print never moves money or stock. It keeps
    # the template, version and paper it was printed with (null on prints
    # made before templates existed), so a reprint can reproduce it.
    class ReceiptPrint < Record
      self.table_name = 'spree_pos_receipt_prints'
      has_prefix_id :posprint

      COPY_LABEL = 'BẢN SAO'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :receipt_snapshot, class_name: 'Spree::Pos::ReceiptSnapshot'
      belongs_to :actor, class_name: staff_class_name
      belongs_to :receipt_template, class_name: 'Spree::Pos::ReceiptTemplate', optional: true

      validates :copy_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :paper, inclusion: { in: ReceiptTemplate::PAPERS }, allow_nil: true

      # The template, version and paper for printing `snapshot`, from the
      # `receipt_template_id`, `template_version` and `paper` asked for.
      # Nothing asked: the original print's, or the current default when the
      # original is missing or predates templates. A template must be of the
      # document's type; a disabled one only when it is the original's. The
      # original's template without a version or paper keeps the original's;
      # any other template defaults to its current version and paper.
      def self.layout_for!(snapshot, requested)
        document_type = ReceiptTemplate.document_type_for(snapshot.source_type)
        original = snapshot.prints.find_by(copy_number: 0)
        return requested_layout(snapshot, document_type, original, requested) if requested['receipt_template_id'].present?

        %w[template_version paper].each do |key|
          raise invalid("/#{key}", 'unexpected', "#{key} needs receipt_template_id.") if requested[key].present?
        end
        if original&.receipt_template
          return { receipt_template: original.receipt_template, template_version: original.template_version, paper: original.paper }
        end

        ReceiptTemplate.ensure_defaults!(snapshot.store)
        template = ReceiptTemplate.for_store(snapshot.store).active.find_by!(document_type: document_type, is_default: true)
        { receipt_template: template, template_version: template.current_version, paper: template.paper }
      end

      def self.requested_layout(snapshot, document_type, original, requested)
        scope = ReceiptTemplate.for_store(snapshot.store)
        template = ReceiptTemplate.locate(scope, requested['receipt_template_id'])
        raise invalid('/receipt_template_id', 'not_found', 'Unknown receipt template.') if template.nil?
        unless template.document_type == document_type
          raise invalid('/receipt_template_id', 'mismatch', "This document prints with a #{document_type} template.")
        end
        if template.disabled? && template.id != original&.receipt_template_id
          raise invalid('/receipt_template_id', 'template_disabled', 'This template is disabled.')
        end

        same = original && template.id == original.receipt_template_id
        version = same ? original.template_version : template.current_version
        if requested['template_version'].present?
          version = Integer(requested['template_version'].to_s, 10, exception: false)
          raise invalid('/template_version', 'not_found', 'This version does not exist.') unless version && template.version_record(version)
        end
        paper = requested['paper'].presence || (same ? original.paper : template.paper)
        unless ReceiptTemplate::PAPERS.include?(paper)
          raise invalid('/paper', 'invalid_value', "Paper must be one of #{ReceiptTemplate::PAPERS.join(', ')}.")
        end

        { receipt_template: template, template_version: version, paper: paper }
      end

      def self.invalid(pointer, code, message)
        ReceiptTemplateSchema::Invalid.at(pointer, code, message)
      end
      private_class_method :requested_layout, :invalid

      def readonly?
        persisted? || super
      end

      def copy?
        copy_number.positive?
      end

      def to_pos
        { id: prefixed_id, receipt_id: receipt_snapshot.prefixed_id, copy: copy?, copy_number: copy_number,
          label: copy? ? COPY_LABEL : nil, printed_at: created_at.iso8601 }.merge(layout)
      end

      # The template, version and paper of this print; all null before templates.
      def layout
        { template_id: receipt_template&.prefixed_id, template_version: template_version, paper: paper }
      end
    end
  end
end
