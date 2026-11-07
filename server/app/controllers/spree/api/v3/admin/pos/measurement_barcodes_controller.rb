# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class MeasurementBarcodesController < BaseController
            scoped_resource :pos_orders

            # Previews a scanned code. A code claimed by one of the branch's label
            # formats is read into an exact measured quantity; anything else is an
            # ordinary barcode for the catalog lookup. Adding the line re-reads the
            # label on the server, so this preview is never trusted as input.
            def parse
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              membership = policy.membership_for(branch)
              raise ActiveRecord::RecordNotFound unless membership && !membership.disabled?

              label = Spree::Pos::MeasurementBarcodeParser.call(branch: branch, barcode: params[:barcode])
              data = label ? label.to_pos(current_store.default_currency) : { kind: 'ordinary', barcode: params[:barcode].to_s, measurement: nil, capability: 'measured_labels' }
              render json: { data: data }
            end
          end
        end
      end
    end
  end
end
