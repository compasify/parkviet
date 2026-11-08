# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Immutable receipts of posted POS documents, readable per document
          # type: sale receipts by active members of the sale branch; return,
          # supplementary return and refund slips by readers of returns at
          # the receiving or the sale branch; shift closing slips by the
          # closer, the variance approver or report readers of the branch.
          # The customer's name is masked unless the reader collects,
          # approves or manages credit there; the phone is always masked.
          # Printing records an original or a numbered copy and never touches
          # money or stock. Each print keeps its template, version and paper;
          # a reprint uses the original's unless another template of the same
          # document type is asked for.
          class ReceiptsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            lookup: %w[read_pos_orders write_pos_orders], prints: %w[write_pos_orders]

            UNMASKED = ReceivablesController::UNMASKED
            LAYOUT_PARAMS = %w[receipt_template_id template_version paper].freeze
            RETURN_TYPES = %w[return return_supplement refund].freeze
            SOURCES = {
              'posworkspace' => Spree::Pos::Workspace, 'posreturn' => Spree::Pos::ReturnOperation,
              'posrefund' => Spree::Pos::RefundRequest, 'posclosure' => Spree::Pos::ShiftClosure
            }.freeze

            # Receipts of one branch by document number (exact or partial),
            # limited to the document types the reader may see there.
            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise ActiveRecord::RecordNotFound unless member?(branch)

              scope = visible_scope(branch).includes(:branch, :register).order(issued_at: :desc, id: :desc)
              term = params[:number].to_s.strip.upcase.first(64)
              scope = scope.where('UPPER(number) LIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(term)}%") if term.present?
              if params[:source_type].present?
                raise Spree::Pos::Conflict, 'Unknown document type.' unless Spree::Pos::ReceiptSnapshot::SOURCE_TYPES.include?(params[:source_type])

                scope = scope.where(source_type: params[:source_type])
              end
              records, meta = page_scope(scope)
              copies = Spree::Pos::ReceiptPrint.where(receipt_snapshot_id: records.map(&:id)).group(:receipt_snapshot_id).maximum(:copy_number)
              originals = Spree::Pos::ReceiptPrint.where(receipt_snapshot_id: records.map(&:id), copy_number: 0).
                          includes(:receipt_template).index_by(&:receipt_snapshot_id)
              mask = mask?(branch)
              render json: {
                data: records.map { |row| row.to_pos(mask: mask, copies: copies[row.id], original: originals[row.id]) }, meta: meta
              }
            end

            def show
              return if channel_rejected?

              snapshot = snapshot!(params[:id])
              render json: { data: snapshot.to_pos(mask: mask?(snapshot.branch)) }
            end

            # The receipt of a posted source document (sale workspace, return,
            # refund or shift closure). A source that is not posted has none.
            def lookup
              return if channel_rejected?

              source = source!(params[:source_id])
              raise ActiveRecord::RecordNotFound unless readable?(Spree::Pos::ReceiptBuilder::TYPES.fetch(source.class), source)

              snapshot = Spree::Pos::ReceiptBuilder.for_source!(source, actor: current_user)
              render json: { data: snapshot.to_pos(mask: mask?(snapshot.branch)) }
            end

            # The command result keeps only the print; the receipt is rendered
            # fresh for the reader, so a replay never serves stale masking.
            # `receipt_template_id`, `template_version` and `paper` choose the
            # layout (see ReceiptPrint.layout_for!) and are part of the
            # idempotent payload.
            def prints
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              snapshot = snapshot!(params[:id])
              requested = LAYOUT_PARAMS.select { |name| params[name].present? }.index_with { |name| params[name].to_s }
              payload = { 'command' => 'receipt.print', 'receipt_id' => snapshot.prefixed_id }
              payload['layout'] = requested if requested.any?
              authorize = -> { raise ActiveRecord::RecordNotFound unless readable?(snapshot.source_type, snapshot.source_record) }
              print = Spree::Pos::CommandExecutor.call(store: current_store, actor: current_user, key: key, payload: payload,
                                                       authorize: authorize) do
                snapshot.lock!
                copy_number = (snapshot.prints.maximum(:copy_number) || -1) + 1
                layout = Spree::Pos::ReceiptPrint.layout_for!(snapshot, requested)
                row = Spree::Pos::ReceiptPrint.create!(store: current_store, receipt_snapshot: snapshot, actor: current_user,
                                                       copy_number: copy_number, **layout)
                audit!(row.copy? ? 'receipt.reprint' : 'receipt.print', snapshot,
                       { print_id: row.prefixed_id, copy_number: copy_number, number: snapshot.number }.merge(row.layout))
                row.to_pos
              end
              render json: { data: { print: print, receipt: snapshot.to_pos(mask: mask?(snapshot.branch)) } }, status: :created
            end

            private

            def member?(branch)
              policy.membership_for(branch)&.status == 'active'
            end

            def returns_reader?(*branches)
              branches.compact.any? { |branch| Spree::Pos::Masking.returns_visible?(policy, branch) }
            end

            def readable?(type, record)
              case type
              when 'sale' then member?(record.branch)
              when 'return', 'return_supplement' then returns_reader?(record.branch, record.sale_branch)
              when 'refund' then returns_reader?(record.branch, record.return_operation.sale_branch)
              when 'shift_closure' then closure_reader?(record)
              else false
              end
            end

            def closure_reader?(closure)
              return false unless member?(closure.branch)

              [closure.closer_id, closure.approver_id].include?(current_user.id) ||
                policy.allows?(closure.branch, Spree::Pos::Capabilities::REPORT_READ)
            end

            # Rows of one branch the reader may list: sales as a member,
            # return documents with return rights there, closing slips they
            # closed or approved, or all of them with report rights.
            def visible_scope(branch)
              base = Spree::Pos::ReceiptSnapshot.for_store(current_store).where(branch_id: branch.id)
              types = ['sale']
              types += RETURN_TYPES if returns_reader?(branch)
              scope = base.where(source_type: types)
              closures = if policy.allows?(branch, Spree::Pos::Capabilities::REPORT_READ)
                           base.where(source_type: 'shift_closure')
                         else
                           own = Spree::Pos::ShiftClosure.where(branch_id: branch.id).
                                 where('closer_id = :id OR approver_id = :id', id: current_user.id)
                           base.where(source_type: 'shift_closure', source_id: own.select(:id))
                         end
              scope.or(closures)
            end

            def snapshot!(prefixed)
              snapshot = Spree::Pos::ReceiptSnapshot.locate(Spree::Pos::ReceiptSnapshot.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if snapshot.nil? || !readable?(snapshot.source_type, snapshot.source_record)

              snapshot
            end

            def source!(prefixed)
              model = SOURCES[prefixed.to_s.split('_').first]
              raise ActiveRecord::RecordNotFound if model.nil?

              source = model.locate(model.where(store_id: current_store.id), prefixed)
              raise ActiveRecord::RecordNotFound if source.nil?

              source
            end

            def mask?(branch)
              UNMASKED.none? { |capability| policy.allows?(branch, capability) }
            end
          end
        end
      end
    end
  end
end
