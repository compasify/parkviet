# frozen_string_literal: true

require_relative 'pos_return_helpers'

# Drives shift close, drawer movements and late-cash reconciliation through
# the real workflows, shared by workflow, request and race specs.
module PosShiftHelpers
  include PosReturnHelpers

  CAPS = Spree::Pos::Capabilities
  LEAD = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::RESOLVE, CAPS::CREDIT_SELL, CAPS::RETURN, CAPS::CASH_MOVE].freeze
  MANAGER = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::RESOLVE, CAPS::APPROVE, CAPS::CREDIT_MANAGE, CAPS::RETURN,
             CAPS::CASH_MOVE, CAPS::RECOVER].freeze

  def open_shift(store, branch, staff, float: 0)
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quầy', code: "q#{SecureRandom.hex(4)}", status: 'active')
    Spree::Pos::Shifts::Open.call(store: store, staff: staff, register: register, opening_float: float.to_s)
  end

  def count_shift(shift, staff, counted, reason: nil, key: SecureRandom.uuid)
    Spree::Pos::Shifts::Count.call(store: shift.store, staff: staff, key: key, shift_id: shift.prefixed_id,
                                   counted: counted.to_s, reason: reason)
  end

  def close_shift(shift, staff, reason: nil, approval_id: nil, key: SecureRandom.uuid)
    Spree::Pos::Shifts::Close.call(store: shift.store, staff: staff, key: key, shift_id: shift.prefixed_id,
                                   reason: reason, approval_id: approval_id)
  end

  def approve_close(shift, staff, key: SecureRandom.uuid)
    Spree::Pos::Shifts::ApproveClose.call(store: shift.store, staff: staff, key: key, shift_id: shift.prefixed_id,
                                          revision: shift.reload.revision)
  end

  # Cash in posts at once; cash out and safe drops are requested and, when a
  # confirmer is given, confirmed by that second person.
  def move_cash(shift, staff, kind, amount, reason: 'Đổi tiền lẻ', evidence: nil, confirmer: nil, key: SecureRandom.uuid)
    evidence ||= 'PHIEU-1' unless kind == 'cash_in'
    result = Spree::Pos::Shifts::PostCashMovement.call(store: shift.store, staff: staff, key: key, shift_id: shift.prefixed_id,
                                                       kind: kind, amount: amount.to_s, reason: reason, evidence_reference: evidence)
    return result if confirmer.nil? || result['status'] != 'requested'

    decide_cash(shift.store, confirmer, result['id'], 'confirm')
  end

  def decide_cash(store, staff, request_id, decision, note: nil, key: SecureRandom.uuid)
    Spree::Pos::Shifts::ConfirmCashMovement.call(store: store, staff: staff, key: key, request_id: request_id,
                                                 decision: decision, note: note)
  end

  def expected_cash(shift)
    Spree::Pos::CashbookProjection.new(shift.reload).expected
  end

  def held_cash(store, branch, shift, staff, amount, note: 'Tiền khách gửi lại sau ca')
    result = Spree::Pos::RecordUnsolicitedFunds.call(
      store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id, shift_id: shift.prefixed_id,
      kind: 'cash', handed_amount: amount.to_s, custody: 'held', custody_note: note
    )
    Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['id'])
  end

  def drawer_cash(store, branch, shift, staff, amount)
    result = Spree::Pos::RecordUnsolicitedFunds.call(
      store: store, staff: staff, key: SecureRandom.uuid, branch_id: branch.prefixed_id, shift_id: shift.prefixed_id,
      kind: 'cash', handed_amount: amount.to_s
    )
    Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['id'])
  end

  def reconcile(store, branch, staff, outcome:, reason: 'Tiền mặt nhận cuối ca chưa ghi', key: SecureRandom.uuid, **links)
    Spree::Pos::Shifts::ReconcileLateCash.call(store: store, staff: staff, key: key, branch_id: branch.prefixed_id,
                                               outcome: outcome, reason: reason, **links)
  end

  # A cash tender with change: `handed` given, `amount` kept.
  def cash_tender(sale, amount, handed)
    method = Spree::Pos::PaymentMethodResolver.new(store: sale.workspace.store).available.find { |row| row.kind == 'cash' }
    Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method.prefixed_id || 'posmethod-cash',
                                                            amount: amount.to_s)
    attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).order(:id).last
    Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                            handed_amount: handed.to_s)
  end
end
