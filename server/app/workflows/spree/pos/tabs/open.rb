# frozen_string_literal: true

module Spree
  module Pos
    module Tabs
      # Opens a bar tab: an order named after its guest, served wherever
      # they stand, paid when they leave. Like a table order, every counter
      # and waiter of the branch adds to it without a lease
      # (Workspaces::AppendItems), so it is booked on the opener's own open
      # shift at the branch, or else on the shift of the branch's table
      # register. Two open tabs never share a name.
      module Open
        MODULE = 'fnb.postpay'

        module_function

        def call(store:, staff:, key:, editor_id:, branch_id:, tab_name:)
          editor_digest = Workspace.editor_digest(editor_id)
          name = tab_name.to_s.squish
          payload = { 'command' => 'tab.open', 'branch_id' => branch_id.to_s, 'tab_name' => name, 'editor_digest' => editor_digest }
          branch = Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Tables::Guard.serve!(store, staff, branch) }) do
            ModulePolicy.require!(branch, MODULE)
            if name.empty? || name.length > Workspace::TAB_NAME_MAX
              raise Conflict.new('Give the tab a name of at most 60 characters.', reason: 'tab_name_invalid')
            end

            # One opening per branch at a time decides whether the name is free.
            branch.lock!
            taken = open_tabs(branch).where('LOWER(tab_name) = ?', name.downcase).first
            raise Conflict.new('An open tab already has this name.', reason: 'tab_name_taken', details: { workspace_id: taken.prefixed_id }) if taken

            shift = booking_shift!(branch, staff)
            workspace = Workspaces::Create.draft!(store: store, staff: staff, shift: shift, editor_digest: editor_digest,
                                                  service_mode: 'tab', tab_name: name)
            AuditEntry.record!(store: store, actor: staff, action: 'tab.open', subject: workspace,
                               metadata: { tab_name: name, shift_id: shift.prefixed_id })
            Realtime.announce_workspaces([workspace.id])
            workspace.to_pos
          end
        end

        def open_tabs(branch)
          Workspace.where(branch_id: branch.id, service_mode: 'tab', operational_status: Workspace::OPEN_STATUSES).where.not(tab_name: nil)
        end

        def booking_shift!(branch, staff)
          own = Shift.for_store(branch.store).open_now.where(branch_id: branch.id, owner_id: staff.id).order(opened_at: :desc).first
          own || Tables::Guard.booking_shift!(branch)
        end

        # The bar's tab list: each tab's summary with the menu units the
        # kitchen has not been told about yet, read for the whole page in one
        # query.
        def rows(workspaces)
          ids = workspaces.map(&:id)
          return [] if ids.empty?

          unsent = Workspace.where(id: ids).pluck(:id, Arel.sql(ResourceState::UNSENT_ITEMS)).to_h
          workspaces.map do |workspace|
            workspace.summary.merge(unsent_kitchen_items: BigDecimal((unsent[workspace.id] || 0).to_s).ceil)
          end
        end

        # Open tabs of a branch whose name, call number or table matches `query`.
        def search(scope, query)
          text = query.to_s.squish.downcase
          return scope if text.empty?

          pattern = "%#{ActiveRecord::Base.sanitize_sql_like(text)}%"
          matches = scope.where('LOWER(spree_pos_workspaces.tab_name) LIKE ?', pattern).
                    or(scope.where(resource_id: Resource.where(branch_id: scope.select(:branch_id)).where('LOWER(name) LIKE ?', pattern).select(:id)))
          matches = matches.or(scope.where(order_number: text.to_i)) if text.match?(/\A\d{1,9}\z/)
          matches
        end
      end
    end
  end
end
