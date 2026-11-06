# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class MeasurementBarcodesController < BaseController
            scoped_resource :pos_orders

            # Ordinary barcodes only. Embedded weight/price label parsing is not
            # enabled without a branch profile, checksum and device UAT.
            def parse
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              membership = policy.membership_for(branch)
              raise ActiveRecord::RecordNotFound unless membership && !membership.disabled?

              render json: { data: { kind: 'ordinary', barcode: params[:barcode].to_s, measurement: nil, capability: 'ordinary_only' } }
            end
          end
        end
      end
    end
  end
end
