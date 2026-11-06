# frozen_string_literal: true

module Spree
  module Pos
    # Public workspace list. Order lines, customers and payments stay off this DTO.
    class WorkspaceSummary
      def self.list(workspaces)
        workspaces.map(&:summary)
      end
    end
  end
end
