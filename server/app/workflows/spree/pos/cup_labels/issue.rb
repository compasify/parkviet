# frozen_string_literal: true

module Spree
  module Pos
    module CupLabels
      # One print job per cup: every menu line whose item prints cup labels
      # (`menu_items.cup_label`) gets one label for each unit, "1/3", "2/3",
      # "3/3". A label is one job per (line, cup, trigger): the automatic
      # labels of a kitchen send and of the completion share the trigger
      # `auto`, so a cup the send already printed is never printed again; a
      # reprint is its own trigger, its command key.
      module Issue
        MODULE = 'fnb.cup_label'
        AUTO = 'auto'

        module_function

        # From Kitchen::Send (`upto: :sent`, the cups the kitchen has been
        # told about) and Workspaces::Complete (`upto: :sold`, every cup).
        # Runs after the caller commits; a printer that is off or has no
        # live station is logged and never undoes the sale.
        def after_commit(workspace:, actor:, upto:)
          return unless ModulePolicy.enabled?(workspace.branch, MODULE)

          ActiveRecord.after_all_transactions_commit do
            call(workspace: Workspace.find(workspace.id), actor: actor, upto: upto)
          rescue StandardError => e
            Rails.logger.error("[pos] cup labels of #{workspace.prefixed_id} not queued: #{e.class}: #{e.message}")
          end
        end

        # @return [Array<PrintJob>] the jobs of these labels, new or replayed
        def call(workspace:, actor:, upto:, trigger: AUTO, line: nil, strict: false)
          printer = workspace.branch.cup_label_printer
          return [] if printer.nil?

          settings = Settings.for(workspace.branch)
          at = Workspace.database_now
          labels(workspace, upto, line).filter_map do |sale_line, index, total|
            document = Document.build(workspace: workspace, line: sale_line, index: index, total: total, settings: settings, at: at)
            enqueue(workspace, printer, document, "cup_label:#{sale_line.prefixed_id}:#{index}:#{trigger}", actor, strict)
          end
        end

        # [line, cup, cups of the line] for every label due.
        def labels(workspace, upto, only = nil)
          lines = SaleLine.where(workspace_id: workspace.id, kind: SaleLineKinds::Menu::KIND).order(:id).
                  includes(:line_modifiers, variant: %i[product option_values]).to_a
          lines.select! { |row| row.id == only.id } if only
          cups = MenuItem.where(store_id: workspace.store_id, product_id: lines.map { |row| row.variant.product_id }, cup_label: true).
                 pluck(:product_id).to_set
          lines.select { |row| cups.include?(row.variant.product_id) }.flat_map do |row|
            total = row.sale_quantity.to_i
            due = [upto == :sold ? total : row.kitchen_sent_quantity.to_i, total].min
            (1..due).map { |index| [row, index, total] }
          end
        end

        def enqueue(workspace, printer, document, key, actor, strict)
          PrintJobs::Enqueue.call(store: workspace.store, printer: printer, kind: 'cup_label', document: document, key: key,
                                  actor: actor, source: workspace)
        rescue Conflict => e
          raise if strict

          Rails.logger.error("[pos] cup label #{key} not queued: #{e.reason || e.message}")
          nil
        end
      end
    end
  end
end
