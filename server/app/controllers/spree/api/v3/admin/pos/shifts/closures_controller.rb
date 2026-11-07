# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Shifts
            # Close a shift: checklist and status, blind count, variance
            # approval and the immutable closing snapshot.
            class ClosuresController < BaseController
              scoped_resource :pos_shifts
              pos_permissions show: %w[read_pos_shifts write_pos_shifts], pending: %w[read_pos_shifts write_pos_shifts],
                              open: %w[read_pos_shifts write_pos_shifts]

              rescue_from Spree::Pos::Shifts::CloseBlocked, with: :render_close_blocked

              # Checklist, the pending count preview (expected only after a
              # count) and, once closed, the snapshot.
              def show
                return if channel_rejected?

                shift = readable_shift!
                render json: { data: state(shift) }
              end

              def count
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Shifts::Count.call(store: current_store, staff: current_user, key: key,
                                                        shift_id: params[:id], counted: params[:counted], reason: params[:reason])
                render json: { data: result }
              end

              def approve
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Shifts::ApproveClose.call(store: current_store, staff: current_user, key: key,
                                                               shift_id: params[:id], revision: params[:revision])
                render json: { data: result }, status: :created
              end

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Shifts::Close.call(store: current_store, staff: current_user, key: key,
                                                        shift_id: params[:id], reason: params[:reason],
                                                        approval_id: params[:approval_id])
                render json: { data: result }, status: :created
              end

              # Open shifts at the branch a manager with recovery rights may
              # close for an absent cashier.
              def open
                return if channel_rejected?

                branch = branch!(params[:branch_id])
                raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::RECOVER)

                shifts = Spree::Pos::Shift.for_store(current_store).open_now.where(branch_id: branch.id).
                         includes(:owner, :register, :branch).order(:opened_at).limit(PAGE_MAX)
                data = shifts.map do |shift|
                  shift.to_pos.merge(register: shift.register&.code, owner_name: Spree::Pos::StaffName.call(shift.owner))
                end
                render json: { data: data, meta: { count: data.length } }
              end

              # Counts waiting for an approver at the branch.
              def pending
                return if channel_rejected?

                branch = branch!(params[:branch_id])
                raise CanCan::AccessDenied unless policy.allows?(branch, Spree::Pos::Capabilities::APPROVE)

                shifts = Spree::Pos::Shift.for_store(current_store).open_now.where(branch_id: branch.id).
                         where.not(closing_counted: nil).includes(:owner, :register, :closing_counted_by).order(:closing_counted_at)
                data = shifts.filter_map do |shift|
                  preview = Spree::Pos::Shifts::Guard.preview(shift)
                  next unless preview[:requires_approval] && !preview[:stale]

                  preview.merge(register: shift.register&.code, owner_name: Spree::Pos::StaffName.call(shift.owner),
                                counted_by_name: Spree::Pos::StaffName.call(shift.closing_counted_by),
                                opened_at: shift.opened_at.iso8601, self_count: shift.closing_counted_by_id == current_user.id)
                end
                render json: { data: data, meta: { count: data.length } }
              end

              private

              def guard
                Spree::Pos::Shifts::Guard
              end

              # Closers see their shift; approvers and report readers at the
              # branch see any shift there.
              def readable_shift!
                shift = guard.shift!(current_store, params[:id])
                return shift if guard.closer?(current_store, current_user, shift)
                return shift if [Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::REPORT_READ].any? do |capability|
                  policy.allows?(shift.branch, capability)
                end

                raise ActiveRecord::RecordNotFound
              end

              def state(shift)
                closure = shift.closure
                checklist = shift.open? ? Spree::Pos::ShiftChecklist.new(shift).to_pos : { blocking: [], warnings: [] }
                {
                  shift: shift.to_pos, checklist: checklist, count: guard.preview(shift),
                  closure: closure&.to_pos,
                  can_close: shift.open? && guard.closer?(current_store, current_user, shift),
                  can_approve: shift.open? && policy.allows?(shift.branch, Spree::Pos::Capabilities::APPROVE) &&
                    shift.closing_counted_by_id != current_user.id
                }
              end

              def render_close_blocked(error)
                render_error(code: 'conflict', message: error.message, status: :conflict,
                             details: { reason: error.reason, checklist: error.checklist.to_pos })
              end
            end
          end
        end
      end
    end
  end
end
