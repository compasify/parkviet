# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Who may read a posted document, and whether its customer is masked
          # for them. Printing a document needs the same right as reading it.
          module ReceiptAccess
            private

            def member?(branch)
              policy.membership_for(branch)&.status == 'active'
            end

            def returns_reader?(*branches)
              branches.compact.any? { |branch| Spree::Pos::Masking.returns_visible?(policy, branch) }
            end

            def readable?(type, record)
              case type
              when 'sale' then member?(record.branch)
              when 'return', 'return_supplement' then returns_reader?(record.branch, record.sale_branch)
              when 'refund' then returns_reader?(record.branch, record.return_operation.sale_branch)
              when 'shift_closure' then closure_reader?(record)
              else false
              end
            end

            def closure_reader?(closure)
              return false unless member?(closure.branch)

              [closure.closer_id, closure.approver_id].include?(current_user.id) ||
                policy.allows?(closure.branch, Spree::Pos::Capabilities::REPORT_READ)
            end

            def snapshot!(prefixed)
              snapshot = Spree::Pos::ReceiptSnapshot.locate(Spree::Pos::ReceiptSnapshot.for_store(current_store), prefixed)
              raise ActiveRecord::RecordNotFound if snapshot.nil? || !readable?(snapshot.source_type, snapshot.source_record)

              snapshot
            end

            def mask?(branch)
              ReceivablesController::UNMASKED.none? { |capability| policy.allows?(branch, capability) }
            end
          end
        end
      end
    end
  end
end
