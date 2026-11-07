# frozen_string_literal: true

module Spree
  module Pos
    class Conflict < StandardError
      attr_reader :revision, :reason, :retry_after_seconds, :details

      # `details` carries machine-readable facts behind the refusal (for
      # example both counts of a mismatch) so clients never parse messages.
      def initialize(message = 'Conflict.', revision: nil, reason: nil, retry_after_seconds: nil, details: nil)
        super(message)
        @revision = revision
        @reason = reason
        @retry_after_seconds = retry_after_seconds
        @details = details
      end
    end
  end
end
