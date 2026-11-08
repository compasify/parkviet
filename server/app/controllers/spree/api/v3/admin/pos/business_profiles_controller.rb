# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The catalog of industry profiles and POS modules, read by every
          # POS session (same permissions as the context) so clients never
          # keep their own list. Labels are translated client-side by key.
          class BusinessProfilesController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders read_pos_topology write_pos_topology]

            def show
              return if channel_rejected?

              render json: { data: Spree::Pos::BusinessProfiles.to_pos }
            end
          end
        end
      end
    end
  end
end
