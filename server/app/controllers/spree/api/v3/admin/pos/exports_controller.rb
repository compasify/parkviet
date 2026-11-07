# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Asynchronous report exports. Requesting needs `pos.report.export`
          # at the branch; filters are validated now and the CSV is built by
          # GenerateExportJob. Each requester sees only their own exports.
          # Downloading re-authorizes the requester (export capability, and
          # branch report access again when the export was branch-wide) and
          # hands out a one-minute signed link that streams the file.
          class ExportsController < BaseController
            scoped_resource :pos_orders
            READ = %w[read_pos_orders read_pos_shifts write_pos_shifts].freeze
            pos_permissions index: READ, show: READ, download_link: READ, create: READ

            LINK_TTL = 1.minute
            LINK_PURPOSE = :pos_export_download

            rescue_from Spree::Pos::Reports::Filters::Invalid, with: :render_invalid_filter

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              render_page(own.where(branch_id: branch.id).order(id: :desc))
            end

            def show
              render json: { data: export!.to_pos }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              branch = branch!(params[:branch_id])
              scope = Spree::Pos::Reports::Scope.new(store: current_store, staff: current_user, branch: branch)
              raise CanCan::AccessDenied unless scope.export?

              filters = params[:filters].respond_to?(:to_unsafe_h) ? params[:filters].to_unsafe_h : {}
              filters = filters.to_h { |name, value| [name.to_s, value.is_a?(String) ? value : raise_invalid(name)] }
              report = Spree::Pos::Reports.build(params[:report_type], scope: scope, values: filters)
              created = false
              result = Spree::Pos::CommandExecutor.call(
                store: current_store, actor: current_user, key: key,
                payload: { 'command' => 'report.export', 'branch_id' => branch.prefixed_id,
                           'report_type' => params[:report_type].to_s, 'filters' => report.filters.to_h },
                authorize: -> {}
              ) do
                Spree::Pos::FeaturePolicy.require!(branch, :exports)
                record = Spree::Pos::ExportRequest.create!(
                  store: current_store, branch: branch, requester: current_user, report_type: params[:report_type].to_s,
                  filters: report.filters.to_h, status: 'queued', full_scope: scope.full?,
                  expires_at: Spree::Pos::ExportRequest::TTL.from_now
                )
                audit!('report.export', record, report_type: record.report_type, filters: record.filters,
                                                full_scope: record.full_scope)
                created = true
                record.to_pos
              end
              record = Spree::Pos::ExportRequest.find_by_prefix_id!(result['id'])
              # A replayed request returns its first result and is not enqueued again.
              Spree::Pos::GenerateExportJob.perform_later(record.id) if created
              render json: { data: record.to_pos }, status: :accepted
            end

            def download_link
              export = export!
              scope = Spree::Pos::Reports::Scope.new(store: current_store, staff: current_user, branch: export.branch)
              raise CanCan::AccessDenied unless scope.export? && (!export.full_scope || scope.full?)
              if export.expired? || !export.file.attached?
                return render_error(code: export.expired? ? 'export_expired' : 'export_not_ready',
                                    message: 'This export has expired or is not ready.',
                                    status: export.expired? ? :gone : :conflict)
              end

              audit!('report.export_download', export, report_type: export.report_type)
              token = export.signed_id(purpose: LINK_PURPOSE, expires_in: LINK_TTL)
              render json: { data: { id: export.prefixed_id, url: "/api/v3/admin/pos/export_files/#{token}",
                                     filename: export.file.filename.to_s, expires_at: LINK_TTL.from_now.iso8601 } }
            end

            private

            def own
              Spree::Pos::ExportRequest.for_store(current_store).where(requester_id: current_user.id)
            end

            def export!
              export = Spree::Pos::ExportRequest.locate(own, params[:id])
              raise ActiveRecord::RecordNotFound if export.nil?

              export
            end

            def raise_invalid(name)
              raise Spree::Pos::Reports::Filters::Invalid, "Filter #{name} takes one value."
            end

            def render_invalid_filter(error)
              render_error(code: 'parameter_invalid', message: error.message, status: :unprocessable_content)
            end
          end
        end
      end
    end
  end
end
