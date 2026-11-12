# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # What a counter stores to keep selling cash sales offline
          # (OfflineSales::Snapshot). Answers 304 when `If-None-Match`
          # carries the current etag.
          class OfflineSnapshotsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders write_pos_orders]

            def show
              register = register!(params[:register_id])
              raise CanCan::AccessDenied unless policy.allows?(register.branch, Spree::Pos::Capabilities::OPEN_SHIFT) &&
                policy.allows?(register.branch, Spree::Pos::Capabilities::PAYMENT)

              body = Spree::Pos::OfflineSales::Snapshot.call(store: current_store, staff: current_user, register: register)
              response.headers['ETag'] = %("#{body[:etag]}")
              response.headers['Cache-Control'] = 'private, no-store'
              return head(:not_modified) if etag_matches?(body[:etag])

              render json: { data: body }
            end

            private

            def etag_matches?(etag)
              request.headers['If-None-Match'].to_s.split(',').any? do |value|
                value.strip.delete_prefix('W/').delete('"') == etag
              end
            end
          end
        end
      end
    end
  end
end
