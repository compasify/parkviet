# frozen_string_literal: true

module Spree
  module Pos
    module Approvals
      # Grants one action-bound approval: the approver lets the requester run
      # `action` once on `subject` as it stands at `revision`. Used by the
      # manager standing at the counter (POST /approvals) and by a remote
      # grant of an approval request, so both pass the same checks.
      #
      # `subject!` finds what the approval is bound to from request params;
      # `check!` tells whether the requester may ask for that action there.
      # Both raise the same errors the approvals endpoint always answered.
      module Issue
        # The param naming each subject other than an order, and its scope.
        SUBJECT_PARAMS = {
          reservation_id: 'Spree::Pos::Reservation',
          bottle_keep_id: 'Spree::Pos::BottleKeep',
          meal_account_id: 'Spree::Pos::MealAccount',
          vehicle_visit_id: 'Spree::Pos::VehicleVisit',
          stored_value_account_id: 'Spree::Pos::StoredValueAccount'
        }.freeze
        # The ref an `approval.requested` event carries, by subject.
        REFS = SUBJECT_PARAMS.invert.merge('Spree::Pos::Workspace' => :workspace_id).freeze

        module_function

        # @param params [#[]] request params; one of SUBJECT_PARAMS, else workspace_id
        def subject!(store, branch, params)
          key = SUBJECT_PARAMS.keys.find { |name| params[name].present? }
          type = key ? SUBJECT_PARAMS.fetch(key) : 'Spree::Pos::Workspace'
          subject = type.constantize.locate(subject_scope(store, branch, type), key ? params[key] : params[:workspace_id])
          raise ActiveRecord::RecordNotFound if subject.nil?

          subject
        end

        def subject_scope(store, branch, type)
          case type
          when 'Spree::Pos::Workspace' then Workspace.for_store(store).where(branch_id: branch.id)
          when 'Spree::Pos::Reservation' then Reservation.for_store(store).where(branch_id: branch.id)
          when 'Spree::Pos::BottleKeep' then BottleKeep.where(store_id: store.id, branch_id: branch.id)
          when 'Spree::Pos::MealAccount' then MealAccount.for_store(store)
          when 'Spree::Pos::VehicleVisit' then VehicleVisit.for_store(store).where(branch_id: branch.id)
          when 'Spree::Pos::StoredValueAccount' then StoredValueAccount.for_store(store).cards
          else raise ActiveRecord::RecordNotFound
          end
        end

        # Whether `requester` may ask for `action` on `subject` at `revision`.
        def check!(store:, branch:, requester:, subject:, action:, revision:)
          action = action.to_s
          return check_workspace!(store, branch, requester, subject, action, revision) if subject.is_a?(Workspace)

          allowed_action!(subject, action)
          requester_policy = AccessPolicy.new(store: store, staff: requester)
          allowed = Approval::REQUESTER_CAPABILITIES.fetch(subject.class.name).any? { |key| requester_policy.allows?(branch, key) }
          raise CanCan::AccessDenied unless allowed

          fresh!(subject, revision)
        end

        # @return [Spree::Pos::Approval]
        def call(store:, branch:, approver:, requester:, subject:, action:, revision:, amount:, expires_at:)
          check!(store: store, branch: branch, requester: requester, subject: subject, action: action, revision: revision)
          # Bottles and coach visits are approved without an amount. A
          # callable amount is read only once the checks passed.
          amount = if subject.is_a?(BottleKeep) || subject.is_a?(VehicleVisit) then nil
                   elsif amount.respond_to?(:call) then amount.call
                   else amount
                   end
          approval = Approval.create!(
            store: store, branch: branch, approver: approver, requester: requester,
            subject_type: subject.class.name, subject_id: subject.id, action: action,
            amount: amount, currency: amount ? store.default_currency : nil,
            revision: revision.to_s, expires_at: expires_at, status: 'active'
          )
          AuditEntry.record!(store: store, actor: approver, action: 'approval.grant', subject: approval,
                             metadata: { action: approval.action, revision: approval.revision })
          Realtime.publish(branch, 'approval.requested', id: approval.prefixed_id,
                                                         refs: { REFS.fetch(subject.class.name) => subject.prefixed_id })
          approval
        end

        def check_workspace!(store, branch, requester, subject, action, revision)
          requester_policy = AccessPolicy.new(store: store, staff: requester)
          # The cashier of the order, or for a table order anyone who may edit it.
          cashier = [subject.shift.owner_id, subject.lease_holder_id].include?(requester.id) &&
                    requester_policy.allows?(branch, Capabilities::OPEN_SHIFT)
          raise CanCan::AccessDenied unless cashier || (subject.shared_service? && requester_policy.can_edit_workspace?(subject))

          fresh!(subject, revision)
          # Credit approvals reserve exposure, so they only come from the credit approval endpoint.
          raise Conflict, 'Credit approvals are granted per workspace credit.' if action == Credit::ACTION
          # Returns and refund payouts are approved on their own record.
          if [ReturnOperation::ACTION, RefundRequest::ACTION, InventoryAdjustment::ACTION].include?(action)
            raise Conflict, 'Return, refund and stock count approvals are granted on their own record.'
          end
          raise Conflict, 'Deposit approvals are granted on their booking.' if Approval::RESERVATION_ACTIONS.include?(action)
          raise Conflict, 'Bottle level approvals are granted on the kept bottle.' if action == Approval::BOTTLE_KEEP_ADJUST_ACTION
          if (Approval::MEAL_ACTIONS + [Approval::MEAL_SPONSOR_ACTION]).include?(action)
            raise Conflict, 'Meal approvals are granted on the meal account.'
          end
          raise Conflict, 'Coach visit approvals are granted on the visit.' if action == Approval::VEHICLE_VISIT_ADJUST_ACTION
          raise Conflict, 'Prepaid card approvals are granted on the card.' if Approval::STORED_VALUE_ACTIONS.include?(action)
        end

        def allowed_action!(subject, action)
          case subject
          when Reservation
            raise Conflict, 'A booking takes deposit approvals only.' unless Approval::RESERVATION_ACTIONS.include?(action)
          when BottleKeep
            raise Conflict, 'A kept bottle takes level approvals only.' unless action == Approval::BOTTLE_KEEP_ADJUST_ACTION
          when MealAccount
            raise Conflict, 'A meal account takes wallet and meal limit approvals only.' unless Approval::MEAL_ACTIONS.include?(action)
          when VehicleVisit
            raise Conflict, 'A coach visit takes correction approvals only.' unless action == Approval::VEHICLE_VISIT_ADJUST_ACTION
          when StoredValueAccount
            raise Conflict, 'A prepaid card takes correction and refund approvals only.' unless Approval::STORED_VALUE_ACTIONS.include?(action)
          end
        end

        def fresh!(subject, revision)
          raise Conflict.new('Revision is stale.', revision: subject.revision) unless revision.to_s == subject.revision.to_s
        end
      end
    end
  end
end
