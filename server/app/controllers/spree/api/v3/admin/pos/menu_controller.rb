# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The menu a branch sells from now, for the counter and the staff
          # app. Answers 304 when `If-None-Match` carries the current etag.
          class MenuController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders read_pos_topology]

            def show
              return if channel_rejected?

              guard = Spree::Pos::Menu::Guard
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              body = Spree::Pos::Menu::Reader.call(branch: branch)
              response.headers['ETag'] = %("#{body[:etag]}")
              response.headers['Cache-Control'] = 'private, no-cache'
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
