# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Kill-switches of risky POS capabilities (see FeaturePolicy): the
          # effective value is the store default AND the branch override. Store
          # defaults and switching a branch back on need `write_pos_topology`;
          # `pos.topology.manage` at a branch may only switch that branch off.
          # Every change is audited (`feature_flag.change`); turning a feature
          # off never touches money, stock or receipts already recorded.
          class FeatureFlagsController < BaseController
            scoped_resource :pos_topology
            MANAGERS = %w[read_pos_orders read_pos_topology write_pos_topology].freeze
            pos_permissions index: MANAGERS, update: MANAGERS

            def index
              return if channel_rejected?

              branch = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
              raise CanCan::AccessDenied unless readable?(branch)

              rows = Spree::Pos::FeatureFlag.for_store(current_store).where(branch_id: [nil, branch&.id].uniq).
                     includes(:branch, :changed_by).order(:feature)
              switches = Spree::Pos::FeaturePolicy.describe(current_store, branch)
              render json: {
                data: {
                  branch_id: branch&.prefixed_id,
                  features: switches.transform_values { |row| row[:effective] },
                  switches: switches,
                  settings: rows.map(&:to_pos)
                }
              }
            end

            def update
              return if channel_rejected?

              branch = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
              features = Spree::Pos::FeaturePolicy.set!(store: current_store, actor: current_user, branch: branch,
                                                        feature: params[:id], enabled: enabled_param, reason: params[:reason])
              render json: { data: { branch_id: branch&.prefixed_id, features: features } }
            end

            private

            def readable?(branch)
              policy.permission?('read_pos_topology') || Spree::Pos::FeaturePolicy.manage?(policy, branch)
            end

            # true / false; for a branch, true and null both drop its override.
            def enabled_param
              raise Spree::Pos::Conflict.new('Enabled must be given.', reason: 'feature_value_invalid') unless params.key?(:enabled)

              value = params[:enabled]
              return nil if value.nil?
              return value if [true, false].include?(value)

              raise Spree::Pos::Conflict.new('Enabled must be true, false or null.', reason: 'feature_value_invalid')
            end
          end
        end
      end
    end
  end
end
