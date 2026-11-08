# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The current store's main industry profile, or null before the
          # first-run setup. Only the current store's row is ever read.
          class StoreProfilesController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_topology write_pos_topology]

            def show
              return if channel_rejected?

              render json: { data: Spree::Pos::StoreProfile.for_store(current_store).includes(:changed_by).first&.to_pos }
            end
          end
        end
      end
    end
  end
end
