# frozen_string_literal: true

module Spree
  module Pos
    # Masking of payment references (beneficiary accounts, transfer
    # references) in read models. Only the last four characters stay readable
    # unless the reader resolves or approves money at that branch.
    module Masking
      module_function

      VISIBLE = 4
      # Who may read full payment references at a branch.
      REFERENCE_READERS = [Capabilities::APPROVE, Capabilities::RESOLVE].freeze
      # Who may read returns and refunds at a branch at all.
      RETURN_READERS = [Capabilities::RETURN, Capabilities::RESOLVE, Capabilities::APPROVE].freeze

      def reference(value)
        text = value.to_s
        return value if text.empty?
        return '•' * text.length if text.length <= VISIBLE

        ('•' * (text.length - VISIBLE)) + text[-VISIBLE..]
      end

      def references_visible?(policy, branch)
        REFERENCE_READERS.any? { |capability| policy.allows?(branch, capability) }
      end

      def returns_visible?(policy, branch)
        RETURN_READERS.any? { |capability| policy.allows?(branch, capability) }
      end
    end
  end
end
