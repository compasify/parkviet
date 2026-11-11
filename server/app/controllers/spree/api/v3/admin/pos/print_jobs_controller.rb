# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The print queue of a branch. A response never carries a job's
          # document; that goes only to the station printing it.
          class PrintJobsController < BaseController
            include ReceiptAccess

            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            prebills: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            create: %w[write_pos_orders], reprint: %w[write_pos_orders write_pos_topology],
                            cancel: %w[write_pos_orders write_pos_topology]

            LAYOUT_PARAMS = ReceiptsController::LAYOUT_PARAMS

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = listed(Spree::Pos::PrintJob.for_store(current_store).where(branch: branch))
              statuses = requested_statuses
              return if statuses.nil?

              render_jobs(statuses.empty? ? scope : scope.where(status: statuses), branch)
            end

            # The latest printed pre-bill of each open order, where a reprint
            # is asked for and approved. Someone who can grant approvals sees
            # every order of the branch: that does not need working on it.
            def prebills
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              printed = Spree::Pos::PrintJob.for_store(current_store).
                        where(branch: branch, kind: 'prebill', status: 'printed', source_type: Spree::Pos::Workspace.name,
                              source_id: reachable_workspaces(branch).where(operational_status: guard::OPEN_WORKSPACE_STATUSES).select('spree_pos_workspaces.id'))
              render_jobs(listed(Spree::Pos::PrintJob.where(id: printed.group(:source_id).select('MAX(spree_pos_print_jobs.id)'))), branch)
            end

            def create
              key = idempotency_key
              return if key.nil?

              case params[:kind]
              when 'receipt' then create_receipt(key)
              when 'prebill' then create_prebill(key)
              else render_error(code: 'parameter_invalid', message: 'Only receipts and pre-bills are queued here.', status: :unprocessable_content)
              end
            end

            def reprint
              key = idempotency_key
              return if key.nil?

              job = guard.job!(current_store, params[:id])
              result = Spree::Pos::PrintJobs::Reprint.call(store: current_store, staff: current_user, key: key, job: job, approval_id: params[:approval_id],
                                                           mask: mask?(job.branch), authorize: -> { authorize_job!(job) })
              render json: { data: fresh(result) }, status: :created
            end

            def cancel
              key = idempotency_key
              return if key.nil?

              job = guard.job!(current_store, params[:id])
              Spree::Pos::PrintJobs::Cancel.call(store: current_store, staff: current_user, key: key, job: job)
              render json: { data: job.reload.to_pos }
            end

            private

            def guard
              Spree::Pos::PrintJobs::Guard
            end

            def listed(scope)
              scope.includes(:branch, :copy_of, :source, :live_copies, printer: :print_station_device).order(id: :desc)
            end

            def reachable_workspaces(branch)
              return Spree::Pos::Workspace.for_store(current_store).where(branch_id: branch.id) if grants_approvals?(branch)

              visible_workspaces.where(branch_id: branch.id)
            end

            # What POST /pos/approvals itself requires, so nobody is offered a
            # button it would refuse.
            def grants_approvals?(branch)
              %w[write_pos_orders write_pos_topology].any? { |key| policy.permission?(key) } &&
                policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)
            end

            def render_jobs(scope, branch)
              records, meta = page_scope(scope)
              render json: { data: with_reprint_state(records, branch), meta: meta }
            end

            # What the reader may do about reprinting each pre-bill of an open order.
            def with_reprint_state(records, branch)
              ids = records.select { |job| job.kind == 'prebill' }.map(&:source_id)
              workspaces = Spree::Pos::Workspace.where(id: ids, branch_id: branch.id, operational_status: guard::OPEN_WORKSPACE_STATUSES).
                           includes(:lease_holder, shift: :owner).index_by(&:id)
              approvals = usable_approvals(workspaces.keys)
              can_approve = grants_approvals?(branch)
              records.map do |job|
                workspace = workspaces[job.source_id] if job.kind == 'prebill'
                workspace ? job.to_pos.merge(reprint: reprint_state(workspace, approvals, can_approve)) : job.to_pos
              end
            end

            # Approvals only the reader can spend, so showing their ids is safe.
            def usable_approvals(workspace_ids)
              Spree::Pos::Approval.for_store(current_store).
                where(action: Spree::Pos::PrintJob::REPRINT_PREBILL_ACTION, subject_type: Spree::Pos::Workspace.name, subject_id: workspace_ids,
                      requester_id: current_user.id, status: 'active').
                where('expires_at > ?', Spree::Pos::Workspace.database_now).to_a
            end

            # An approval names who will reprint: whoever works the order, and
            # never the approver.
            def reprint_state(workspace, approvals, can_approve)
              approval = approvals.find { |row| row.subject_id == workspace.id && row.revision == workspace.revision.to_s }
              requester = [workspace.lease_holder, workspace.shift.owner].compact.find { |staff| staff.id != current_user.id }
              { workspace_revision: workspace.revision, approval_id: approval&.prefixed_id, requester_id: requester&.prefixed_id,
                can_approve: can_approve && requester.present? }
            end

            def requested_statuses
              statuses = Array(params[:status].to_s.split(',')).map(&:strip).compact_blank
              return statuses if (statuses - Spree::Pos::PrintJob::STATUSES).empty?

              render_error(code: 'parameter_invalid', message: 'Unknown print job status.', status: :unprocessable_content)
              nil
            end

            def create_receipt(key)
              snapshot = snapshot!(params[:receipt_id])
              printer = guard.printer!(current_store, params[:printer_id], branch: snapshot.branch)
              requested = LAYOUT_PARAMS.select { |name| params[name].present? }.index_with { |name| params[name].to_s }
              authorize = lambda {
                guard.operate!(current_store, current_user, snapshot.branch)
                raise ActiveRecord::RecordNotFound unless readable?(snapshot.source_type, snapshot.source_record)
              }
              result = Spree::Pos::PrintJobs::Create.receipt(store: current_store, staff: current_user, key: key, snapshot: snapshot, printer: printer,
                                                             requested: requested, mask: mask?(snapshot.branch), authorize: authorize)
              render json: { data: fresh(result).merge('receipt' => snapshot.to_pos(mask: mask?(snapshot.branch))) }, status: :created
            end

            def create_prebill(key)
              workspace = workspace!(params[:workspace_id])
              printer = guard.printer!(current_store, params[:printer_id], branch: workspace.branch)
              result = Spree::Pos::PrintJobs::Create.prebill(store: current_store, staff: current_user, key: key, workspace: workspace, printer: printer,
                                                             template_id: params[:receipt_template_id], mask: mask?(workspace.branch),
                                                             authorize: -> { guard.operate!(current_store, current_user, workspace.branch) })
              render json: { data: fresh(result) }, status: :created
            end

            # A receipt's reprint needs the right to read it; a pre-bill the
            # right to see its open order.
            def authorize_job!(job)
              guard.operate!(current_store, current_user, job.branch)
              case job.kind
              when 'receipt'
                snapshot = job.source
                raise ActiveRecord::RecordNotFound unless snapshot && readable?(snapshot.source_type, snapshot.source_record)
              when 'prebill'
                raise ActiveRecord::RecordNotFound unless visible_workspaces.exists?(id: job.source_id)
              end
            end

            # A command's stored result is what the job looked like then.
            def fresh(result)
              job = guard.job!(current_store, result.dig('print_job', 'id'))
              result.merge('print_job' => job.to_pos)
            end
          end
        end
      end
    end
  end
end
