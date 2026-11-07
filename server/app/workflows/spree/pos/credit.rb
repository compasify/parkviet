# frozen_string_literal: true

module Spree
  module Pos
    # Credit sales: approval-bound reservations of credit exposure that a
    # completed sale turns into an immutable receivable debit.
    module Credit
      ACTION = 'credit.sale'
      STALE = 'credit_approval_stale'
    end
  end
end
