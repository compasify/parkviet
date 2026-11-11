# frozen_string_literal: true

module Spree
  module Pos
    module Tips
      # Pays the held tips of a branch (one business day, optionally one
      # shift) to the staff, split by the branch's rule. Every share becomes
      # LiabilityPayout rows reserved on the receipts that hold the tips, so
      # the money leaves through the ordinary payout confirmation (by another
      # person, with evidence) and the cashbook sees it there.
      module Payout
        module_function

        def call(store:, staff:, key:, branch_id:, business_date:, recipients:, shift_id: nil, mode: nil)
          branch = Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
          day = date!(business_date)
          rows = Array(recipients).map { |row| row.to_h.stringify_keys }
          payload = { 'command' => 'tips.payout', 'branch_id' => branch.prefixed_id, 'business_date' => day.iso8601,
                      'shift_id' => shift_id.to_s.presence, 'mode' => mode.to_s.presence,
                      'recipients' => rows.map { |row| row.slice('staff_id', 'hours', 'amount').transform_values(&:to_s) } }
          authorize = lambda do
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::RESOLVE)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            ModulePolicy.require!(branch, Fnb::Tips::MODULE)
            rule = TipSplitRule.for(branch)
            split_mode = mode.presence || rule.mode
            records = held(branch, day, shift_id).lock.to_a
            raise Conflict.new('There are no tips to pay out.', reason: 'tips_none') if records.empty?

            currency = records.first.currency
            raise Conflict, 'Tips in several currencies are paid out one at a time.' if records.any? { |record| record.currency != currency }

            people = recipients!(store, branch, rows, rule)
            total = records.sum(&:amount)
            shares = Fnb::Tips.split(total, people, mode: split_mode, currency: currency)
            payouts = pay!(store, staff, records, shares)
            AuditEntry.record!(store: store, actor: staff, action: 'tips.payout', subject: branch,
                               metadata: { business_date: day.iso8601, mode: split_mode, total: total.to_s('F'),
                                           shares: shares.map { |person, amount| { staff_id: person.prefixed_id, amount: amount.to_s('F') } },
                                           payout_ids: payouts.map(&:prefixed_id) })
            { business_date: day.iso8601, mode: split_mode, total: total.to_s('F'), currency: currency,
              shares: shares.map { |person, amount| { staff_id: person.prefixed_id, name: KitchenSend.staff_name(person), amount: amount.to_s('F') } },
              payouts: payouts.map(&:to_pos) }
          end
        end

        def held(branch, day, shift_id)
          scope = TipRecord.held.where(branch_id: branch.id, business_date: day).order(:id)
          return scope if shift_id.blank?

          shift = Shift.locate(Shift.where(branch_id: branch.id), shift_id) || raise(ActiveRecord::RecordNotFound)
          scope.where(shift_id: shift.id)
        end

        def date!(value)
          Date.iso8601(value.to_s)
        rescue ArgumentError
          raise Conflict.new('The business date is invalid.', reason: 'business_date_invalid')
        end

        # Staff of the branch, limited to the rule's roles when it names any.
        def recipients!(store, branch, rows, rule)
          raise Conflict.new('Name who shares the tips.', reason: 'tip_recipients_required') if rows.empty? || rows.size > 100

          roles = Array(rule.role_codes)
          seen = {}
          rows.map do |row|
            person = Spree.admin_user_class.find_by_prefix_id(row['staff_id'].to_s)
            membership = person && StaffMembership.for_store(store).find_by(branch_id: branch.id, staff_id: person.id, status: 'active')
            raise Conflict.new('Tips go to staff of the branch.', reason: 'tip_recipient_invalid') if membership.nil? || seen[person.id]
            if roles.any? && !roles.include?(membership.staff_role&.prefixed_id)
              raise Conflict.new('This person\'s role does not share tips.', reason: 'tip_recipient_invalid')
            end

            seen[person.id] = true
            { staff: person, hours: row['hours'], amount: row['amount'] }
          end
        end

        # Takes each share from the receipts in order: one payout per share and
        # receipt it touches. Every record is paid out in full.
        def pay!(store, staff, records, shares)
          left = records.map { |record| [record, record.amount] }
          payouts = []
          shares.each do |person, amount|
            owed = amount
            left.each do |entry|
              break unless owed.positive?
              next unless entry[1].positive?

              part = [owed, entry[1]].min
              payouts << reserve!(store, staff, entry[0], person, part)
              entry[1] -= part
              owed -= part
              entry[0].liability_payout = payouts.last if entry[1].zero?
            end
          end
          now = Time.current
          records.each { |record| record.update!(status: 'paid_out', paid_out_at: now) }
          payouts
        end

        def reserve!(store, staff, record, person, amount)
          funds = record.received_funds
          funds.with_lock do
            raise Conflict.new('The tip money was already used.', reason: 'tips_unavailable') if FundsBalance.new(funds).available < amount

            LiabilityPayout.create!(store: store, received_funds: funds, branch: record.branch, requester: staff, status: 'reserved',
                                    amount: amount, currency: record.currency, beneficiary_name: KitchenSend.staff_name(person),
                                    beneficiary_reference: person.prefixed_id, reason: "Tip #{record.business_date.iso8601}")
          end
        end
      end
    end
  end
end
