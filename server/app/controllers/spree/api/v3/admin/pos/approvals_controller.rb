# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Grants an action-bound approval. There is no consume or shared-PIN route.
          class ApprovalsController < BaseController
            scoped_resource :pos_topology

            # Granting is decided per branch by the approve capability, so a
            # branch manager needs no store-level setup permission for it.
            pos_permissions create: %w[write_pos_orders write_pos_topology]

            def index
              return if channel_rejected?

              render_page(Spree::Pos::Approval.for_store(current_store).order(id: :desc))
            end

            def show
              return if channel_rejected?

              render json: { data: approval!(params[:id]).to_pos }
            end

            def create
              return if channel_rejected? || currency_rejected?

              branch = branch!(params[:branch_id])
              raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)

              requester = staff!(params[:requester_id])
              return create_for_reservation(branch, requester) if params[:reservation_id].present?
              return create_for_bottle_keep(branch, requester) if params[:bottle_keep_id].present?
              return create_for_meal_account(branch, requester) if params[:meal_account_id].present?

              subject = Spree::Pos::Workspace.locate(
                Spree::Pos::Workspace.for_store(current_store).where(branch_id: branch.id), params[:workspace_id]
              )
              raise ActiveRecord::RecordNotFound if subject.nil?
              requester_policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: requester)
              # The cashier of the order, or for a table order anyone who may edit it.
              cashier = [subject.shift.owner_id, subject.lease_holder_id].include?(requester.id) &&
                        requester_policy.allows?(branch, Spree::Pos::Capabilities::OPEN_SHIFT)
              raise CanCan::AccessDenied unless cashier || (subject.shared_service? && requester_policy.can_edit_workspace?(subject))
              raise Spree::Pos::Conflict.new('Revision is stale.', revision: subject.revision) unless params[:revision].to_s == subject.revision.to_s
              # Credit approvals reserve exposure, so they only come from the credit approval endpoint.
              if params[:action_name].to_s == Spree::Pos::Credit::ACTION
                raise Spree::Pos::Conflict, 'Credit approvals are granted per workspace credit.'
              end
              # Returns and refund payouts are approved on their own record.
              if [Spree::Pos::ReturnOperation::ACTION, Spree::Pos::RefundRequest::ACTION,
                  Spree::Pos::InventoryAdjustment::ACTION].include?(params[:action_name].to_s)
                raise Spree::Pos::Conflict, 'Return, refund and stock count approvals are granted on their own record.'
              end

              if Spree::Pos::Approval::RESERVATION_ACTIONS.include?(params[:action_name].to_s)
                raise Spree::Pos::Conflict, 'Deposit approvals are granted on their booking.'
              end
              if params[:action_name].to_s == Spree::Pos::Approval::BOTTLE_KEEP_ADJUST_ACTION
                raise Spree::Pos::Conflict, 'Bottle level approvals are granted on the kept bottle.'
              end
              if (Spree::Pos::Approval::MEAL_ACTIONS + [Spree::Pos::Approval::MEAL_SPONSOR_ACTION]).include?(params[:action_name].to_s)
                raise Spree::Pos::Conflict, 'Meal approvals are granted on the meal account.'
              end

              amount = money_or_nil
              approval = Spree::Pos::Approval.create!(
                store: current_store,
                branch: branch,
                approver: current_user,
                requester: requester,
                subject_type: subject.class.name,
                subject_id: subject.id,
                action: params[:action_name],
                amount: amount,
                currency: amount ? current_store.default_currency : nil,
                revision: params[:revision].to_s,
                expires_at: params[:expires_at],
                status: 'active'
              )
              audit!('approval.grant', approval, action: approval.action, revision: approval.revision)
              Spree::Pos::Realtime.publish(branch, 'approval.requested', id: approval.prefixed_id,
                                                                         refs: { workspace_id: subject.prefixed_id })
              render json: { data: approval.to_pos }, status: :created
            end

            def revoke
              approval = approval!(params[:id])
              raise CanCan::AccessDenied unless policy.allows?(approval.branch, Spree::Pos::Capabilities::APPROVE)

              Spree::Pos::Approvals::Revoke.call(approval: approval, staff: current_user)
              render json: { data: approval.to_pos }
            end

            private

            # A booking's deposit refund or forfeit, bound to the booking's
            # version and the deposit amount.
            def create_for_reservation(branch, requester)
              subject = Spree::Pos::Reservation.locate(Spree::Pos::Reservation.for_store(current_store).where(branch_id: branch.id),
                                                       params[:reservation_id])
              raise ActiveRecord::RecordNotFound if subject.nil?
              unless Spree::Pos::Approval::RESERVATION_ACTIONS.include?(params[:action_name].to_s)
                raise Spree::Pos::Conflict, 'A booking takes deposit approvals only.'
              end

              requester_policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: requester)
              allowed = Spree::Pos::Approval::REQUESTER_CAPABILITIES.fetch(subject.class.name).any? { |key| requester_policy.allows?(branch, key) }
              raise CanCan::AccessDenied unless allowed
              raise Spree::Pos::Conflict.new('Revision is stale.', revision: subject.revision) unless params[:revision].to_s == subject.revision.to_s

              amount = money_or_nil
              approval = Spree::Pos::Approval.create!(
                store: current_store, branch: branch, approver: current_user, requester: requester,
                subject_type: subject.class.name, subject_id: subject.id, action: params[:action_name],
                amount: amount, currency: amount ? current_store.default_currency : nil,
                revision: params[:revision].to_s, expires_at: params[:expires_at], status: 'active'
              )
              audit!('approval.grant', approval, action: approval.action, revision: approval.revision)
              Spree::Pos::Realtime.publish(branch, 'approval.requested', id: approval.prefixed_id,
                                                                         refs: { reservation_id: subject.prefixed_id })
              render json: { data: approval.to_pos }, status: :created
            end

            # A kept bottle's level correction, bound to the bottle's version.
            def create_for_bottle_keep(branch, requester)
              subject = Spree::Pos::BottleKeep.locate(Spree::Pos::BottleKeep.where(store_id: current_store.id, branch_id: branch.id),
                                                      params[:bottle_keep_id])
              raise ActiveRecord::RecordNotFound if subject.nil?
              unless params[:action_name].to_s == Spree::Pos::Approval::BOTTLE_KEEP_ADJUST_ACTION
                raise Spree::Pos::Conflict, 'A kept bottle takes level approvals only.'
              end

              requester_policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: requester)
              allowed = Spree::Pos::Approval::REQUESTER_CAPABILITIES.fetch(subject.class.name).any? { |key| requester_policy.allows?(branch, key) }
              raise CanCan::AccessDenied unless allowed
              raise Spree::Pos::Conflict.new('Revision is stale.', revision: subject.revision) unless params[:revision].to_s == subject.revision.to_s

              approval = Spree::Pos::Approval.create!(
                store: current_store, branch: branch, approver: current_user, requester: requester,
                subject_type: subject.class.name, subject_id: subject.id, action: params[:action_name],
                revision: params[:revision].to_s, expires_at: params[:expires_at], status: 'active'
              )
              audit!('approval.grant', approval, action: approval.action, revision: approval.revision)
              Spree::Pos::Realtime.publish(branch, 'approval.requested', id: approval.prefixed_id,
                                                                         refs: { bottle_keep_id: subject.prefixed_id })
              render json: { data: approval.to_pos }, status: :created
            end

            # A meal wallet refund or correction (with its amount), or a meal
            # past the account's limits, bound to the account's version.
            def create_for_meal_account(branch, requester)
              subject = Spree::Pos::MealAccount.locate(Spree::Pos::MealAccount.for_store(current_store), params[:meal_account_id])
              raise ActiveRecord::RecordNotFound if subject.nil?
              unless Spree::Pos::Approval::MEAL_ACTIONS.include?(params[:action_name].to_s)
                raise Spree::Pos::Conflict, 'A meal account takes wallet and meal limit approvals only.'
              end

              requester_policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: requester)
              allowed = Spree::Pos::Approval::REQUESTER_CAPABILITIES.fetch(subject.class.name).any? { |key| requester_policy.allows?(branch, key) }
              raise CanCan::AccessDenied unless allowed
              raise Spree::Pos::Conflict.new('Revision is stale.', revision: subject.revision) unless params[:revision].to_s == subject.revision.to_s

              amount = money_or_nil
              approval = Spree::Pos::Approval.create!(
                store: current_store, branch: branch, approver: current_user, requester: requester,
                subject_type: subject.class.name, subject_id: subject.id, action: params[:action_name],
                amount: amount, currency: amount ? current_store.default_currency : nil,
                revision: params[:revision].to_s, expires_at: params[:expires_at], status: 'active'
              )
              audit!('approval.grant', approval, action: approval.action, revision: approval.revision)
              Spree::Pos::Realtime.publish(branch, 'approval.requested', id: approval.prefixed_id,
                                                                         refs: { meal_account_id: subject.prefixed_id })
              render json: { data: approval.to_pos }, status: :created
            end

            def money_or_nil
              return if params[:amount].blank?

              amount = Spree::Pos::Record.money(params[:amount])
              raise ActiveRecord::RecordInvalid, invalid_amount if amount.nil?

              amount
            end

            def invalid_amount
              record = Spree::Pos::Approval.new
              record.errors.add(:amount, :invalid)
              record
            end

            def approval!(prefixed)
              approval = Spree::Pos::Approval.locate(Spree::Pos::Approval.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if approval.nil?

              approval
            end
          end
        end
      end
    end
  end
end
