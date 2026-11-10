# frozen_string_literal: true

module Spree
  module Pos
    # Layout of an in-store EAN-13 scale label, shared by the store and read
    # at the branches it is assigned to (BranchLabelFormat):
    #   prefix | item code (the SKU's label code) | value | check digit
    # A weight label carries the net weight; a price label carries the amount,
    # which is only used to infer the weight from the current server price.
    class LabelFormat < Record
      self.table_name = 'spree_pos_label_formats'
      has_prefix_id :poslabel

      KINDS = %w[weight price].freeze
      BODY_LENGTH = 12

      belongs_to :store, class_name: 'Spree::Store'
      # The branch the format was first made for; it is assigned there on create.
      belongs_to :branch, class_name: 'Spree::Pos::Branch', optional: true
      has_many :branch_label_formats, class_name: 'Spree::Pos::BranchLabelFormat', inverse_of: :label_format,
                                      dependent: :delete_all
      has_many :assigned_branches, through: :branch_label_formats, source: :branch

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }
      scope :assigned_to, ->(branch) { where(id: BranchLabelFormat.where(branch_id: branch.id).select(:label_format_id)) }

      after_create :assign_origin_branch
      after_update :check_assigned_prefixes, if: -> { saved_change_to_prefix? || (saved_change_to_status? && !disabled?) }

      # Two active formats read at one branch must not share a prefix.
      def self.ensure_unique_prefixes!(branch)
        taken = active.assigned_to(branch).group(:prefix).having('COUNT(*) > 1').count
        raise Conflict, 'Another active label format uses this prefix.' if taken.any?
      end

      validates :name, presence: true, length: { maximum: 80 }
      validates :prefix, format: { with: /\A\d{1,4}\z/ }
      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: %w[active disabled] }
      validates :item_code_length, :value_length, numericality: { only_integer: true, greater_than: 0 }
      validates :value_decimals, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }
      validates :price_tolerance, numericality: { greater_than_or_equal_to: 0 }
      validate :fills_the_label
      validate :weight_unit_is_known
      validate :same_store

      def disabled?
        status == 'disabled'
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch&.prefixed_id,
          branch_ids: assigned_branches.map(&:prefixed_id), name: name, prefix: prefix, kind: kind,
          item_code_length: item_code_length, value_length: value_length, value_decimals: value_decimals,
          value_unit_code: value_unit_code, price_tolerance: price_tolerance.to_s('F'), version: version, status: status
        }
      end

      private

      def assign_origin_branch
        return if branch.nil?

        branch_label_formats.create!(store: store, branch: branch)
        self.class.ensure_unique_prefixes!(branch)
      end

      def check_assigned_prefixes
        assigned_branches.each { |assigned| self.class.ensure_unique_prefixes!(assigned) }
      end

      def fills_the_label
        return if prefix.blank? || item_code_length.nil? || value_length.nil?
        return if prefix.length + item_code_length + value_length == BODY_LENGTH

        errors.add(:base, 'Prefix, item code and value must fill the 12 digits before the check digit.')
      end

      def weight_unit_is_known
        if kind == 'weight'
          unit = store && UnitDefinition.find_by(store: store, code: value_unit_code.to_s)
          errors.add(:value_unit_code, :invalid) unless unit && %w[mass volume].include?(unit.dimension)
        elsif value_unit_code.present?
          errors.add(:value_unit_code, :invalid)
        end
      end

      def same_store
        errors.add(:branch, :invalid) if branch && store && branch.store_id != store_id
      end
    end
  end
end
