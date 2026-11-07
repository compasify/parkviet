# frozen_string_literal: true

module Spree
  module Pos
    module Displays
      # Explicitly shows one order (and optionally its prepared bank tender)
      # on the customer display, or clears it. Switching cashier tabs never
      # calls this. Each pin and clear starts a new generation, and each is a
      # compare-and-set on the generation the cashier saw: a delayed pin or
      # clear that was decided against an older generation is refused with
      # `generation_stale` instead of overwriting a later decision.
      #
      # A different customer may be pinned only once the display has
      # acknowledged the current generation after a clear (a fresh lease), so
      # the cashier never shows the next customer on a screen that may still
      # show the previous one. Re-pinning the same order (adding or dropping
      # its bank tender) needs no clear.
      class Pin
        def self.call(store:, staff:, key:, session_id:, expected_generation:, workspace_id:, tender_attempt_id: nil)
          session = Guard.session!(store, staff, session_id)
          payload = { 'command' => 'display.pin', 'session_id' => session.prefixed_id, 'workspace_id' => workspace_id.to_s,
                      'tender_attempt_id' => tender_attempt_id.to_s.presence, 'expected_generation' => expected_generation.to_s }
          run(store, staff, key, session, payload, expected_generation) do
            workspace = Workspace.locate(Workspace.for_store(store).where(shift_id: session.shift_id), workspace_id)
            raise ActiveRecord::RecordNotFound if workspace.nil?
            raise Conflict.new('Only an open order can be shown to the customer.', reason: 'display_order_closed') unless
              workspace.operational_status == 'editing'

            attempt = attempt!(workspace, tender_attempt_id)
            unless session.pinned_workspace_id == workspace.id
              raise Conflict.new('Clear the customer display before showing another order.', reason: 'display_busy') if
                session.pinned_workspace_id
              raise Conflict.new('The customer display has not confirmed it was cleared.', reason: 'display_ack_required') unless
                session.ack_current?
            end
            session.update!(generation: session.generation + 1, pinned_workspace: workspace, pinned_tender_attempt: attempt,
                            pinned_at: Time.current)
            session.to_pos
          end
        end

        def self.clear(store:, staff:, key:, session_id:, expected_generation:)
          session = Guard.session!(store, staff, session_id)
          payload = { 'command' => 'display.clear', 'session_id' => session.prefixed_id,
                      'expected_generation' => expected_generation.to_s }
          run(store, staff, key, session, payload, expected_generation) do
            session.update!(generation: session.generation + 1, pinned_workspace: nil, pinned_tender_attempt: nil, pinned_at: nil)
            session.to_pos
          end
        end

        def self.run(store, staff, key, session, payload, expected_generation)
          expected = Integer(expected_generation.to_s, exception: false)
          raise Conflict.new('The expected display generation is required.', reason: 'generation_required') if expected.nil?

          authorize = -> { Guard.authorize_branch!(store, staff, session.branch) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            session.lock!
            Guard.usable!(session)
            unless session.generation == expected
              raise Conflict.new('The customer display changed since this was decided.', reason: 'generation_stale',
                                                                                         revision: session.generation)
            end

            yield
          end
        end

        def self.attempt!(workspace, tender_attempt_id)
          return nil if tender_attempt_id.blank?

          attempt = TenderAttempt.locate(TenderAttempt.where(workspace_id: workspace.id), tender_attempt_id)
          raise ActiveRecord::RecordNotFound if attempt.nil?
          unless attempt.status == 'prepared' && attempt.pos_payment_method.kind == 'bank_manual'
            raise Conflict.new('Only a waiting bank transfer can be shown to the customer.', reason: 'display_attempt_invalid')
          end

          attempt
        end
      end
    end
  end
end
