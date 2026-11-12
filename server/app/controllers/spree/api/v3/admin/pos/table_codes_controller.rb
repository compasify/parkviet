# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The QR codes of a branch's tables: which tables have one, and
          # issuing a new one (printing a sticker). The token and the link
          # are answered once, by the request that issued them.
          class TableCodesController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology read_pos_orders],
                            create: %w[write_pos_topology write_pos_orders]

            def index
              branch = branch!(params[:branch_id])
              Spree::Pos::GuestOrders::Guard.codes!(current_store, current_user, branch)
              codes = Spree::Pos::TableCode.active.where(branch_id: branch.id).includes(:resource).index_by(&:resource_id)
              rows = Spree::Pos::Resource.active.where(branch_id: branch.id).order(:position, :id).map do |resource|
                { resource_id: resource.prefixed_id, name: resource.name, area_id: resource.area.prefixed_id,
                  table_code: codes[resource.id]&.to_pos }
              end
              render json: { data: rows }
            end

            def create
              key = idempotency_key
              return if key.nil?

              result, token = Spree::Pos::TableCodes::Issue.call(
                store: current_store, staff: current_user, key: key, resource_id: params[:resource_id], printer_id: params[:printer_id],
                base_url: Spree::Pos::DeviceAuthenticator.public_base_url(request)
              )
              link = token && { token: token, url: Spree::Pos::TableCode.url(Spree::Pos::DeviceAuthenticator.public_base_url(request), token) }
              render json: { data: result['table_code'], meta: { print_job: result['print_job'] }.merge(link || { token: nil, url: nil }) },
                     status: :created
            end
          end
        end
      end
    end
  end
end
