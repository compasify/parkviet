# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The print template a branch uses per document type. A type
          # without a choice, or whose chosen template is disabled, prints
          # with the store default. PUT takes `templates`, a map of document
          # type to template id (null returns the type to the store default);
          # types left out keep their current choice.
          class BranchReceiptTemplatesController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_topology write_pos_topology]

            Template = Spree::Pos::ReceiptTemplate
            Invalid = Spree::Pos::ReceiptTemplateSchema::Invalid

            def show
              return if channel_rejected?

              render_assignments(branch!(params[:branch_id]))
            end

            def update
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              changes = requested_changes
              Template.transaction do
                branch.lock!
                changes.each do |document_type, template|
                  row = Spree::Pos::BranchReceiptTemplate.find_by(branch_id: branch.id, document_type: document_type)
                  if template.nil?
                    row&.destroy!
                  elsif row
                    row.update!(receipt_template: template)
                  else
                    Spree::Pos::BranchReceiptTemplate.create!(store: current_store, branch: branch, document_type: document_type,
                                                              receipt_template: template)
                  end
                end
                audit!('branch.receipt_templates', branch, changes.transform_values { |template| template&.prefixed_id })
              end
              render_assignments(branch)
            end

            private

            # { document_type => template or nil }, validated.
            def requested_changes
              raw = params.to_unsafe_h['templates']
              raise Invalid.at('/templates', 'missing', 'Give templates by document type.') unless raw.is_a?(Hash)

              raw.to_h do |document_type, prefixed|
                document_type = document_type.to_s
                unless Template::DOCUMENT_TYPES.include?(document_type)
                  raise Invalid.at("/templates/#{document_type}", 'invalid_value',
                                   "Document type must be one of #{Template::DOCUMENT_TYPES.join(', ')}.")
                end
                next [document_type, nil] if prefixed.blank?

                [document_type, assignable!(document_type, prefixed)]
              end
            end

            def assignable!(document_type, prefixed)
              pointer = "/templates/#{document_type}"
              template = Template.locate(Template.for_store(current_store), prefixed.to_s)
              raise Invalid.at(pointer, 'not_found', 'Unknown receipt template.') if template.nil?
              if template.document_type != document_type
                raise Invalid.at(pointer, 'mismatch',
                                 "This document prints with a #{document_type} template.")
              end
              raise Invalid.at(pointer, 'template_disabled', 'This template is disabled.') if template.disabled?

              template
            end

            def render_assignments(branch)
              Template.ensure_defaults!(current_store)
              chosen = Spree::Pos::BranchReceiptTemplate.where(branch_id: branch.id).includes(:receipt_template).
                       index_by(&:document_type)
              data = Template::DOCUMENT_TYPES.map do |document_type|
                assigned = chosen[document_type]&.receipt_template
                effective = Template.effective_for(current_store, document_type, branch: branch)
                { document_type: document_type, receipt_template: summary(assigned), effective_template: summary(effective),
                  uses_store_default: effective.id != assigned&.id }
              end
              render json: { data: { branch_id: branch.prefixed_id, templates: data } }
            end

            def summary(template)
              template && { id: template.prefixed_id, name: template.name, paper: template.paper, status: template.status,
                            is_default: template.is_default }
            end
          end
        end
      end
    end
  end
end
