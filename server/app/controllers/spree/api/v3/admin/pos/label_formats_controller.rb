# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Scale label layouts per branch. Any change bumps the version that every
          # sale line read with the format records; a format is disabled, never deleted.
          class LabelFormatsController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology]

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              render_page(Spree::Pos::LabelFormat.for_store(current_store).where(branch_id: branch.id).order(:prefix, :id))
            end

            def create
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              # A new scale label layout is measured-goods setup (D5).
              Spree::Pos::ModulePolicy.require!(branch, 'retail.measured')
              Spree::Pos::UnitDefinition.ensure_defaults!(current_store)
              format = Spree::Pos::LabelFormat.create!(format_attributes.merge(store: current_store, branch: branch, status: 'active', version: 1))
              audit!('label_format.create', branch, format.to_pos)
              render json: { data: format.to_pos }, status: :created
            rescue ActiveRecord::RecordNotUnique
              raise Spree::Pos::Conflict, 'Another active label format uses this prefix.'
            end

            def update
              return if channel_rejected?

              format = format!
              # Changing a layout is setup too; disabling one (below) is not.
              Spree::Pos::ModulePolicy.require!(format.branch, 'retail.measured')
              format.with_lock do
                raise Spree::Pos::Conflict, 'A disabled label format cannot be changed.' if format.disabled?

                format.assign_attributes(format_attributes)
                if format.changed?
                  format.version += 1
                  format.save!
                  audit!('label_format.update', format.branch, format.to_pos)
                end
              end
              render json: { data: format.to_pos }
            rescue ActiveRecord::RecordNotUnique
              raise Spree::Pos::Conflict, 'Another active label format uses this prefix.'
            end

            def disable
              format = format!
              format.with_lock do
                unless format.disabled?
                  format.update!(status: 'disabled')
                  audit!('label_format.disable', format.branch, format.to_pos)
                end
              end
              render json: { data: format.to_pos }
            end

            private

            def format!
              branch = branch!(params[:branch_id])
              format = Spree::Pos::LabelFormat.locate(Spree::Pos::LabelFormat.for_store(current_store).where(branch_id: branch.id), params[:id])
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
