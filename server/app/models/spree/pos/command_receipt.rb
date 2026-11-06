# frozen_string_literal: true

module Spree
  module Pos
    class CommandReceipt < Record
      self.table_name = 'spree_pos_command_receipts'
      has_prefix_id :poscommand

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :idempotency_key, :digest, presence: true

      def self.digest_for(payload)
        Digest::SHA256.hexdigest(JSON.generate(canonicalize(payload)))
      end

      def self.canonicalize(value)
        case value
        when Hash
          value.each_with_object({}) { |(key, item), sorted| sorted[key.to_s] = canonicalize(item) }.sort.to_h
        when Array
          value.map { |item| canonicalize(item) }
        else
          value
        end
      end
    end
  end
end
