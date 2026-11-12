# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Guests calling staff or asking for the bill from the table QR,
          # and marking a request done.
          class GuestRequestsController < BaseController
            scoped_resource :pos_orders

            def index
              branch = branch!(params[:branch_id])
              Spree::Pos::GuestOrders::Guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::GuestRequest.still_open.where(branch_id: branch.id).where(created_at: 1.day.ago..).
                      includes(:workspace, :handled_by, resource: :area)
              if params[:area_id].present?
                area = Spree::Pos::Area.locate(Spree::Pos::Area.where(branch_id: branch.id), params[:area_id]) || raise(ActiveRecord::RecordNotFound)
                scope = scope.joins(:resource).where(spree_pos_resources: { area_id: area.id })
              end
              render_page(scope.order(:created_at, :id))
            end

            def done
              key = idempotency_key
              return if key.nil?

              request_row = Spree::Pos::GuestRequest.find_by_prefix_id(params[:id].to_s)
              raise ActiveRecord::RecordNotFound if request_row.nil? || request_row.store_id != current_store.id

              render json: { data: Spree::Pos::GuestRequests::Done.call(request: request_row, staff: current_user, key: key) }
            end
          end
        end
      end
    end
  end
end
