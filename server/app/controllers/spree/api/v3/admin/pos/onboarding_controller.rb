# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # First-run POS setup (Onboarding::Setup). Idempotent by
          # Idempotency-Key; once the store is set up, 409 `already_onboarded`.
          class OnboardingController < BaseController
            scoped_resource :pos_topology

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Onboarding::Setup.call(
                store: current_store, actor: current_user, key: key, profile_key: params[:profile_key], branch: params[:branch],
                wholesale: params[:wholesale], interests: params[:interests], register: params[:register],
                grant_self: params[:grant_self], features: params[:features],
                disabled_modules: params[:disabled_modules], fnb_setup: params[:fnb_setup],
                answers: params[:answers]
              )
              render json: { data: data }, status: :created
            end
          end
        end
      end
    end
  end
end
