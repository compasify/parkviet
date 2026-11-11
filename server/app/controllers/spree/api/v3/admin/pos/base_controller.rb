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
            # A device that works as the machine (kitchen screen, pass, print
            # station…) opens a staff session only to sign one thing, so it
            # reaches the few controllers that say so; a waiter's or an
            # owner's device reaches all of them.
            class_attribute :pos_machine_devices, instance_accessor: false, default: false

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

            # A paired device with a staff session is that staff member for
            # every existing permission, capability and lease check. A device
            # token alone never enters this API.
            def authenticate_admin!
              return super unless Spree::Pos::DeviceAuthenticator.device_request?(request)

              device, staff = Spree::Pos::DeviceAuthenticator.authenticate(request)
              if device.nil? || device.store_id != current_store&.id
                render_error(code: 'device_unauthorized', message: 'The device is not connected.', status: :unauthorized)
                return false
              end
              if staff.nil?
                render_error(code: Spree::Api::V3::ErrorHandler::ERROR_CODES[:access_denied],
                             message: 'This device needs a staff session.', status: :forbidden,
                             details: { reason: 'device_staff_required' })
                return false
              end

              if device.mode.in?(Spree::Pos::Device::MACHINE_MODES) && !self.class.pos_machine_devices
                render_error(code: Spree::Api::V3::ErrorHandler::ERROR_CODES[:access_denied], message: 'This device mode cannot call that.',
                             status: :forbidden, details: { reason: 'device_mode_forbidden' })
                return false
              end

              @current_user = staff
              @pos_device = device
              require_store_membership!
            end

            rescue_from Spree::Pos::Conflict, with: :render_pos_conflict
            rescue_from Spree::Pos::ReceiptTemplateSchema::Invalid, with: :render_template_invalid

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
              details = error.details.merge(details) if error.details.is_a?(Hash)
              render_error(code: 'conflict', message: error.message, status: :conflict, details: details)
            end

            # Every refused print template or print layout: one 422 shape with
            # a JSON pointer per problem.
            def render_template_invalid(error)
              render_error(code: 'validation_error', message: error.message, status: :unprocessable_content,
                           details: { errors: error.errors })
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

            # Drafts carry customer and basket data, so they stay readable only while
            # the staff member still works at that branch: their own shift or lease
            # needs an active selling membership, other drafts need takeover.
            def visible_workspaces
              memberships = policy.memberships.to_a
              takeover_ids = memberships.select { |membership|
                membership.allows?(Spree::Pos::Capabilities::TAKEOVER)
              }.map(&:branch_id)
              working_ids = memberships.select { |membership|
                membership.allows?(Spree::Pos::Capabilities::OPEN_SHIFT) ||
                  membership.allows?(Spree::Pos::Capabilities::TAKEOVER)
              }.map(&:branch_id)
              # Table orders and bar tabs are shared by the people serving tables
              # and the cashiers who collect them.
              serving_ids = memberships.select { |membership|
                membership.allows?(Spree::Pos::Capabilities::TABLE_SERVE) ||
                  (membership.allows?(Spree::Pos::Capabilities::OPEN_SHIFT) && membership.allows?(Spree::Pos::Capabilities::PAYMENT))
              }.map(&:branch_id)
              Spree::Pos::Workspace.for_store(current_store).left_joins(:shift).where(
                '((spree_pos_shifts.owner_id = :id OR spree_pos_workspaces.lease_holder_id = :id) AND ' \
                'spree_pos_workspaces.branch_id IN (:working)) OR spree_pos_workspaces.branch_id IN (:takeover) OR ' \
                "((spree_pos_workspaces.resource_id IS NOT NULL OR spree_pos_workspaces.service_mode = 'tab') AND " \
                'spree_pos_workspaces.branch_id IN (:serving))',
                id: current_user.id,
                working: working_ids.presence || [0],
                takeover: takeover_ids.presence || [0],
                serving: serving_ids.presence || [0]
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
