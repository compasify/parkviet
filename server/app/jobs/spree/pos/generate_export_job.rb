# frozen_string_literal: true

require 'tempfile'

module Spree
  module Pos
    # Builds one report export under the requester's current scope. Claiming
    # the request (queued -> processing) is a single conditional update, so a
    # duplicate job does nothing. The requester is re-authorized here (they
    # may have lost access since asking, including branch-wide report access
    # for a branch-wide export); rows are written to a Tempfile in keyset
    # batches and attached until the request expires.
    class GenerateExportJob < ApplicationJob
      queue_as :default

      def perform(export_request_id)
        claimed = ExportRequest.where(id: export_request_id, status: 'queued').where('expires_at > ?', Time.current).
                  update_all(status: 'processing', updated_at: Time.current)
        return expire!(export_request_id) if claimed.zero?

        export = ExportRequest.find(export_request_id)
        generate!(export)
      rescue CanCan::AccessDenied, ActiveRecord::RecordNotFound
        fail!(export, 'Access to this report was withdrawn.')
      rescue Reports::Filters::Invalid, Reports::ExportFile::TooLarge => e
        fail!(export, e.message.first(200))
      rescue StandardError
        fail!(export, 'The export could not be generated.')
        raise
      end

      private

      def generate!(export)
        scope = Reports::Scope.new(store: export.store, staff: export.requester, branch: export.branch)
        raise CanCan::AccessDenied unless scope.export? && (!export.full_scope || scope.full?)

        report = Reports.build(export.report_type, scope: scope, values: export.filters)
        Tempfile.create(['pos-export', '.csv'], binmode: true) do |file|
          count = Reports::ExportFile.write(report, file)
          file.rewind
          export.file.attach(io: file, content_type: 'text/csv',
                             filename: "#{export.report_type}-#{export.branch.code}-#{export.created_at.strftime('%Y%m%d%H%M')}.csv")
          export.update!(status: 'ready', row_count: count, completed_at: Time.current)
        end
      end

      def expire!(export_request_id)
        ExportRequest.where(id: export_request_id, status: 'queued').where(expires_at: ..Time.current).
          update_all(status: 'expired', updated_at: Time.current)
      end

      def fail!(export, message)
        export&.update!(status: 'failed', error_message: message)
      end
    end
  end
end
