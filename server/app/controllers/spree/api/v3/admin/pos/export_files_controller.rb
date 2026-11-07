# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Streams one export file for a signed one-minute link issued by
          # ExportsController#download_link after re-authorizing the
          # requester. The link is the credential (a browser download sends no
          # bearer token); it names one export, expires quickly, and the file
          # is refused once the export itself expired.
          class ExportFilesController < ActionController::API
            def show
              export = Spree::Pos::ExportRequest.find_signed(params[:token].to_s, purpose: ExportsController::LINK_PURPOSE)
              return head(:not_found) if export.nil?
              return head(:gone) if export.expired?
              return head(:conflict) unless export.file.attached?

              blob = export.file.blob
              response.headers['Content-Type'] = 'text/csv; charset=utf-8'
              response.headers['Content-Disposition'] =
                ActionDispatch::Http::ContentDisposition.format(disposition: 'attachment', filename: blob.filename.to_s)
              response.headers['Cache-Control'] = 'no-store'
              response.headers['Content-Length'] = blob.byte_size.to_s
              self.response_body = Enumerator.new { |out| blob.download { |chunk| out << chunk } }
            end
          end
        end
      end
    end
  end
end
