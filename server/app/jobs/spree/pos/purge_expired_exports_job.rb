# frozen_string_literal: true

module Spree
  module Pos
    # Deletes export files past their TTL and marks the requests expired. The
    # request row stays as a record of who exported what.
    class PurgeExpiredExportsJob < ApplicationJob
      queue_as :default

      def perform
        ExportRequest.expired_now.find_each do |export|
          export.file.purge if export.file.attached?
          export.update!(status: 'expired')
        end
      end
    end
  end
end
