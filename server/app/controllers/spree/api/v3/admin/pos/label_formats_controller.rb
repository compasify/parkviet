# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Scale label layouts, shared by the store and assigned to branches.
          # Under /pos/label_formats they are managed store-wide; under
          # /pos/branches/:branch_id/label_formats the same actions work on the
          # formats assigned to that branch (a new one is assigned there), and
          # PUT replaces the branch's assignment. Any change bumps the version
          # that every sale line read with the format records; a format is
          # disabled, never deleted. At one branch, active formats never share
          # a prefix.
          class LabelFormatsController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology]

            Format = Spree::Pos::LabelFormat

            def index
              return if channel_rejected?

              scope = Format.for_store(current_store).includes(:branch, :assigned_branches)
              scope = scope.assigned_to(branch!(params[:branch_id])) if params[:branch_id].present?
              render_page(scope.order(:prefix, :id))
            end

            def create
              return if channel_rejected?

              branch = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
              # A new scale label layout is measured-goods setup (D5).
              Spree::Pos::ModulePolicy.require!(branch, 'retail.measured') if branch
              Spree::Pos::UnitDefinition.ensure_defaults!(current_store)
              format = Format.transaction do
                branch&.lock!
                Format.create!(format_attributes.merge(store: current_store, branch: branch, status: 'active', version: 1))
              end
              audit!('label_format.create', branch || format, format.to_pos)
              render json: { data: format.to_pos }, status: :created
            end

            def update
              return if channel_rejected?

              format = format!
              # Changing a layout is setup too; disabling one (below) is not.
              Spree::Pos::ModulePolicy.require!(scoped_branch, 'retail.measured') if scoped_branch
              format.with_lock do
                raise Spree::Pos::Conflict, 'A disabled label format cannot be changed.' if format.disabled?

                format.assign_attributes(format_attributes)
                if format.changed?
                  format.assigned_branches.order(:id).each(&:lock!) if format.prefix_changed?
                  format.version += 1
                  format.save!
                  audit!('label_format.update', scoped_branch || format, format.to_pos)
                end
              end
              render json: { data: format.to_pos }
            end

            def disable
              format = format!
              format.with_lock do
                unless format.disabled?
                  format.update!(status: 'disabled')
                  audit!('label_format.disable', scoped_branch || format, format.to_pos)
                end
              end
              render json: { data: format.to_pos }
            end

            # PUT /pos/branches/:branch_id/label_formats with `label_format_ids`:
            # the branch reads exactly these formats afterwards. Newly
            # assigned formats must be active and need `retail.measured`.
            def assign
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              ids = Array(params[:label_format_ids]).map(&:to_s).uniq
              formats = ids.map do |prefixed|
                format = Format.locate(Format.for_store(current_store), prefixed)
                raise ActiveRecord::RecordNotFound if format.nil?

                format
              end
              Format.transaction do
                branch.lock!
                current = Spree::Pos::BranchLabelFormat.where(branch_id: branch.id)
                current_ids = current.pluck(:label_format_id)
                added = formats.reject { |format| current_ids.include?(format.id) }
                if added.any?
                  Spree::Pos::ModulePolicy.require!(branch, 'retail.measured')
                  raise Spree::Pos::Conflict, 'A disabled label format cannot be assigned.' if added.any?(&:disabled?)
                end
                current.where.not(label_format_id: formats.map(&:id)).delete_all
                added.each { |format| Spree::Pos::BranchLabelFormat.create!(store: current_store, branch: branch, label_format: format) }
                Format.ensure_unique_prefixes!(branch)
                audit!('label_format.assign', branch, label_format_ids: formats.map(&:prefixed_id))
              end
              render json: { data: Format.for_store(current_store).assigned_to(branch).includes(:branch, :assigned_branches).
                                   order(:prefix, :id).map(&:to_pos) }
            end

            private

            def scoped_branch
              return @scoped_branch if defined?(@scoped_branch)

              @scoped_branch = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
            end

            def format!
              scope = Format.for_store(current_store)
              scope = scope.assigned_to(scoped_branch) if scoped_branch
              format = Format.locate(scope, params[:id])
              raise ActiveRecord::RecordNotFound if format.nil?

              format
            end

            def format_attributes
              keys = %i[name prefix kind item_code_length value_length value_decimals value_unit_code price_tolerance]
              attrs = keys.select { |key| params.key?(key) }.index_with { |key| params[key] }
              attrs[:value_unit_code] = attrs[:value_unit_code].presence if attrs.key?(:value_unit_code)
              attrs
            end
          end
        end
      end
    end
  end
end
