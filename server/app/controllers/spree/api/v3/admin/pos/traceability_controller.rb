# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Draft traceability choices. Full reservation/sold lifecycle is phase 8;
          # this reader never claims stock is reserved by selecting a draft value.
          class TraceabilityController < BaseController
            scoped_resource :pos_orders

            def show
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              membership = policy.membership_for(branch)
              raise ActiveRecord::RecordNotFound unless membership && !membership.disabled?

              variant = Spree::Variant.find_by_prefix_id(params[:variant_id].to_s)
              raise ActiveRecord::RecordNotFound if variant.nil? || variant.product.store_id != current_store.id
              raise ActiveRecord::RecordNotFound unless Spree::Pos::BranchProduct.exists?(branch: branch, product: variant.product)

              configured = Spree::Pos::VariantUnit.find_by(store: current_store, variant: variant, status: 'active')
              mode = configured&.tracked_mode || 'none'
              render json: { data: { variant_id: variant.prefixed_id, tracked_mode: mode, draft_selection: mode != 'none', reservation: 'unavailable_phase_8', serial_units: [], lots: [] } }
            end
          end
        end
      end
    end
  end
end
