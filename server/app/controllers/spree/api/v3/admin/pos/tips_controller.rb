# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Tips of a branch's business day: what is held and paid out, and
          # paying the held ones to the staff by the branch's split rule.
          class TipsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders read_pos_shifts write_pos_shifts], payout: %w[write_pos_shifts]

            def index
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::RESOLVE) || policy.permission?('read_pos_shifts')

              day = Spree::Pos::Tips::Payout.date!(params[:business_date].presence || Spree::Pos::BusinessDay.for(branch, Spree::Pos::Workspace.business_now).iso8601)
              scope = Spree::Pos::TipRecord.where(branch_id: branch.id, business_date: day).includes(:branch, :workspace, :shift, :received_funds, :liability_payout).order(:id)
              scope = scope.where(status: params[:status]) if Spree::Pos::TipRecord::STATUSES.include?(params[:status])
              records = scope.limit(500).to_a
              held = records.select { |record| record.status == 'held' }.sum(BigDecimal('0'), &:amount)
              paid = records.select { |record| record.status == 'paid_out' }.sum(BigDecimal('0'), &:amount)
              rule = Spree::Pos::TipSplitRule.for(branch)
              render json: { data: records.map(&:to_pos),
                             meta: { business_date: day.iso8601, held: held.to_s('F'), paid_out: paid.to_s('F'),
                                     tips_as_revenue: branch.tips_as_revenue, rule: rule.to_pos, staff: sharing_staff(branch, rule) } }
            end

            def payout
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              recipients = Array(params.permit(recipients: %i[staff_id hours amount]).to_h['recipients'])
              result = Spree::Pos::Tips::Payout.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                     business_date: params[:business_date], shift_id: params[:shift_id],
                                                     mode: params[:mode], recipients: recipients)
              render json: { data: result }, status: :created
            end

            private

            # Active staff of the branch who may share the tips under its rule.
            def sharing_staff(branch, rule)
              roles = Array(rule.role_codes)
              Spree::Pos::StaffMembership.for_store(current_store).where(branch_id: branch.id, status: 'active').
                includes(:staff, :staff_role).order(:id).limit(200).filter_map do |membership|
                next if membership.staff.nil? || (roles.any? && !roles.include?(membership.staff_role&.prefixed_id))

                { staff_id: membership.staff.prefixed_id, name: Spree::Pos::KitchenSend.staff_name(membership.staff),
                  role: membership.staff_role&.name }
              end
            end
          end
        end
      end
    end
  end
end