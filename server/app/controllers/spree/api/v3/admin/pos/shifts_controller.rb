# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class ShiftsController < BaseController
            scoped_resource :pos_shifts

            def index
              return if channel_rejected?

              scope = Spree::Pos::Shift.for_store(current_store).order(id: :desc)
              scope = scope.where(owner_id: current_user.id) unless policy.permission?('read_pos_topology')
              render_page(scope)
            end

            def show
              return if channel_rejected?

              render json: { data: shift!(params[:id]).to_pos }
            end

            def create
              return if channel_rejected? || currency_rejected?

              shift = Spree::Pos::Shifts::Open.call(
                store: current_store,
                staff: current_user,
                register: params[:register_id].present? ? register!(params[:register_id]) : nil,
                branch: params[:branch_id].present? ? branch!(params[:branch_id]) : nil,
                opening_float: params[:opening_float]
              )
              render json: { data: shift.to_pos }, status: :created
            end

            private

            def shift!(prefixed)
              scope = Spree::Pos::Shift.for_store(current_store)
              scope = scope.where(owner_id: current_user.id) unless policy.permission?('read_pos_topology')
              shift = Spree::Pos::Shift.locate(scope, prefixed)
              raise ActiveRecord::RecordNotFound if shift.nil?

              shift
            end
          end
        end
      end
    end
  end
end
