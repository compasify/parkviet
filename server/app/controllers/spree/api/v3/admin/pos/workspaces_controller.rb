# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          class WorkspacesController < BaseController
            scoped_resource :pos_workspaces

            STATUSES = %w[editing parked canceled completed].freeze

            def index
              return if channel_rejected?

              scope = visible_workspaces
              if params[:branch_id].present?
                branch = Spree::Pos::Branch.locate(policy.visible_branches, params[:branch_id])
                raise ActiveRecord::RecordNotFound if branch.nil?

                scope = scope.where(branch_id: branch.id)
              end
              scope = scope.where(register_id: register!(params[:register_id]).id) if params[:register_id].present?
              # `status=editing,parked` lists only open work: the register's tab
              # strip must not bring back invoices that were canceled or paid.
              if params[:status].present?
                statuses = params[:status].to_s.split(',').map(&:strip) & STATUSES
                scope = scope.where(operational_status: statuses)
              end
              records, meta = page_scope(scope.includes(:branch, :register, :shift, :order).order(id: :desc))
              render json: { data: Spree::Pos::WorkspaceSummary.list(records), meta: meta }
            end

            def show
              return if channel_rejected?

              render json: { data: workspace!.to_pos }
            end

            def create
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Workspaces::Create.call(
                store: current_store,
                staff: current_user,
                register_id: params[:register_id],
                branch_id: params[:branch_id],
                key: key,
                editor_id: params[:editor_id]
              )
              render json: { data: result }, status: :created
            end

            def park
              change('parked')
            end

            def cancel
              change('canceled')
            end

            def reopen
              change('editing')
            end

            private

            def change(status)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Workspaces::ChangeStatus.call(
                workspace: workspace!,
                staff: current_user,
                status: status,
                revision: params[:expected_revision].to_i,
                lease_generation: params[:lease_generation].to_i,
                editor_id: params[:editor_id],
                key: key
              )
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
