# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The current store's main industry profile, or null before the
          # first-run setup. Only the current store's row is ever read.
          # Changing it (`write_pos_topology`) only changes the default of
          # branches created afterwards.
          class StoreProfilesController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_topology write_pos_topology]

            def show
              return if channel_rejected?

              profile = Spree::Pos::StoreProfile.for_store(current_store).includes(:changed_by, :food_tax_category, :alcohol_tax_category).first
              render json: { data: profile&.to_pos }
            end

            def update
              return if channel_rejected?

              data = Spree::Pos::Profiles::UpdateStore.call(
                store: current_store, actor: current_user, profile_key: params[:profile_key], reason: params[:reason],
                wholesale: params.key?(:wholesale) ? params[:wholesale] : nil, interests: params.key?(:interests) ? Array(params[:interests]) : nil
              )
              render json: { data: data }
            end
          end
        end
      end
    end
  end
end
