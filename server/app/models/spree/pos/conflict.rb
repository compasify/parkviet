# frozen_string_literal: true

module Spree
  module Pos
      class Conflict < StandardError
        attr_reader :revision, :reason, :retry_after_seconds

        def initialize(message = 'Conflict.', revision: nil, reason: nil, retry_after_seconds: nil)
          super(message)
          @revision = revision
          @reason = reason
          @retry_after_seconds = retry_after_seconds
        end
      end
  end
end
