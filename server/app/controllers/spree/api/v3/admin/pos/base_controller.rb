# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Staff-session boundary for POS. Secret keys are not cashiers.
          class BaseController < Spree::Api::V3::Admin::BaseController
            # 100 is a technical page cap, not a business quota for branches or registers.
            PAGE_MAX = 100

            class_attribute :pos_action_permissions, instance_accessor: false, default: {}

            # Per-action role permissions for this controller, e.g.
            #   pos_permissions index: %w[read_pos_orders read_pos_topology],
            #                   update_variant_unit: %w[write_pos_topology]
            # Actions not listed fall back to the single derived scope
            # "#{action_kind}_#{scoped_resource}".
            def self.pos_permissions(map)
              self.pos_action_permissions = map.transform_keys(&:to_s)
                                               .transform_values { |v| Array(v).map(&:to_s) }
            end

            before_action :require_pos_staff!

            rescue_from Spree::Pos::Conflict, with: :render_pos_conflict

            private

            # Spree derives "#{action_kind}_#{scoped_resource}" and checks it
            # before any action code, so one controller cannot mix two scopes
            # (Units reads under pos_orders but writes under pos_topology).
            # POS therefore runs its own staff gate here: a per-action
            # permission map when declared, otherwise the same derived scope
            # the key gate would have required. Non-staff principals (secret
            # keys) are left to require_pos_staff!, which rejects them.
            # Branch membership/capability checks stay in the actions.
            def authorize_api_key_scope!
              return unless current_user.is_a?(Spree.admin_user_class)

              required = self.class.pos_action_permissions[action_name] || [derived_scope].compact
              return if required.empty?
              return if required.any? { |key| policy.permission?(key) }

              render_forbidden(required.first)
            end

            def derived_scope
              resource = self.class._scoped_resource
              return if resource.nil?

              kind = %w[index show].include?(action_name) ? 'read' : 'write'
              "#{kind}_#{resource}"
            end

            def render_forbidden(permission = nil)
              render_error(
                code: Spree::Api::V3::ErrorHandler::ERROR_CODES[:access_denied],
                message: permission.present? ? "Missing permission: #{permission}" : 'Access denied.',
                status: :forbidden,
                details: permission.present? ? { required_permission: permission } : {}
              )
              true
            end

            def require_pos_staff!
              return if current_user.is_a?(Spree.admin_user_class)

              render_error(
                code: Spree::Api::V3::ErrorHandler::ERROR_CODES[:access_denied],
                message: 'POS context requires a staff session.',
                status: :forbidden
              )
            end

            def render_pos_conflict(error)
              details = error.revision.nil? ? {} : { current_revision: error.revision }
              details[:reason] = error.reason if error.reason
              details[:retry_after_seconds] = error.retry_after_seconds if error.retry_after_seconds
              render_error(code: 'conflict', message: error.message, status: :conflict, details: details)
            end

            def channel_rejected?
              return false unless params.key?(:channel_id)

              render_error(
                code: 'parameter_invalid',
                message: 'A channel does not select a POS branch.',
                status: :unprocessable_content
              )
              true
            end

            def idempotency_key
              header = request.headers['Idempotency-Key'].presence
              body = params[:idempotency_key].to_s.presence
              if header && body && header != body
                render_error(
                  code: 'parameter_invalid',
                  message: 'Idempotency-Key header and body must match.',
                  status: :unprocessable_content
                )
                return
              end
              key = header || body
              if key.blank? || key.length > 200
                render_error(
                  code: 'parameter_invalid',
                  message: 'Idempotency-Key is required.',
                  status: :unprocessable_content
                )
                return
              end
              key
            end

            def policy
              @policy ||= Spree::Pos::AccessPolicy.new(store: current_store, staff: current_user)
            end

            def page_scope(scope)
              page = [params[:page].to_i, 1].max
              limit = params[:limit].to_i
              limit = 25 if limit <= 0
              limit = PAGE_MAX if limit > PAGE_MAX
              total = scope.except(:order).count
              pages = total.zero? ? 0 : (total.to_f / limit).ceil
              records = scope.offset((page - 1) * limit).limit(limit).to_a
              from = records.empty? ? 0 : ((page - 1) * limit) + 1
              to = records.empty? ? 0 : from + records.length - 1
              meta = {
                page: page,
                limit: limit,
                count: total,
                pages: pages,
                from: from,
                to: to,
                in: records.length,
                previous: page > 1 && page <= pages ? page - 1 : nil,
                next: page < pages ? page + 1 : nil
              }
              [records, meta]
            end

            def search_named(scope)
              term = params[:q].to_s.strip
              return scope if term.blank?

              escaped = ActiveRecord::Base.sanitize_sql_like(term)
              scope.where('name ILIKE :term OR code ILIKE :term', term: "%#{escaped}%")
            end

            def render_page(scope)
              records, meta = page_scope(scope)
              render json: { data: records.map(&:to_pos), meta: meta }
            end

            def location!(prefixed)
              location = Spree::StockLocation.find_by_prefix_id(prefixed.to_s)
              raise ActiveRecord::RecordNotFound if location.nil? || location.store_id != current_store.id

              location
            end

            def staff!(prefixed)
              user = Spree.admin_user_class.find_by_prefix_id(prefixed.to_s)
              raise ActiveRecord::RecordNotFound if user.nil?
              raise ActiveRecord::RecordNotFound unless user.spree_roles.for_resource(current_store).exists?

              user
            end

            def branch!(prefixed)
              branch = Spree::Pos::Branch.locate(Spree::Pos::Branch.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if branch.nil?

              branch
            end

            def register!(prefixed, branch: nil)
              scope = Spree::Pos::Register.for_store(current_store)
              scope = scope.where(branch_id: branch.id) if branch
              register = Spree::Pos::Register.locate(scope, prefixed)
              raise ActiveRecord::RecordNotFound if register.nil?

              register
            end

            def visible_workspaces
              takeover_ids = policy.memberships.select { |membership|
                membership.allows?(Spree::Pos::Capabilities::TAKEOVER)
              }.map(&:branch_id)
              Spree::Pos::Workspace.for_store(current_store).left_joins(:shift).where(
                'spree_pos_shifts.owner_id = :id OR spree_pos_workspaces.lease_holder_id = :id OR spree_pos_workspaces.branch_id IN (:branches)',
                id: current_user.id,
                branches: takeover_ids.presence || [0]
              )
            end

            def workspace!(prefixed = params[:id])
              workspace = Spree::Pos::Workspace.locate(visible_workspaces, prefixed)
              raise ActiveRecord::RecordNotFound if workspace.nil?

              workspace
            end

            def audit!(action, subject, metadata = {})
              Spree::Pos::AuditEntry.record!(
                store: current_store,
                actor: current_user,
                action: action,
                subject: subject,
                metadata: metadata
              )
            end

            def currency_rejected?
              return false if params[:currency].blank? || params[:currency] == current_store.default_currency

              render_error(
                code: 'parameter_invalid',
                message: 'Currency is taken from the store.',
                status: :unprocessable_content
              )
              true
            end
          end
        end
      end
    end
  end
end
