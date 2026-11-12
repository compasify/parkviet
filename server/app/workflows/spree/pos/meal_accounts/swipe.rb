# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # Records one meal at the counter and puts the eater on the order. The
      # server decides, under the account row lock, so two counters cannot
      # both take the last meal of the day:
      #   locked account -> revoked; the same account again within
      #   DUPLICATE_WINDOW -> duplicate; outside every meal time -> window;
      #   past the daily or the meal time's limit -> limit.
      # With `override` a window or limit refusal goes through on an
      # approval of `meal_account.override_limit` (or for a person who may
      # approve). Every attempt leaves a swipe row, refusals
      # too (they are reported by reason), and a refusal is answered with a
      # 409 carrying `reason` the client plays its sound for. Recording the
      # eater already on this order again is accepted and counts once.
      class Swipe
        DUPLICATE_WINDOW = 60.seconds
        COMMAND = 'meal_account.swipe'

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, code: nil, meal_account_id: nil,
                      input_method: 'code', approval_id: nil, override: false)
          method = input_method.to_s.presence || 'code'
          raise Conflict.new('The input method is invalid.', reason: 'meal_account_invalid') unless MealSwipe::INPUT_METHODS.include?(method)

          payload = {
            'command' => COMMAND, 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'code' => MealAccount.normalize_code(code),
            'meal_account_id' => meal_account_id.to_s.presence, 'input_method' => method, 'approval_id' => approval_id.to_s.presence,
            'override' => override ? true : nil
          }
          authorize = -> { Tenders::Guard.authorize_editor!(workspace, staff) }
          result = CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                                        authorize: authorize) do
            ModulePolicy.require!(workspace.branch, Guard::MODULE)
            Workspaces::AssignCustomer.validate!(workspace, staff, revision, lease_generation, editor_id)
            record(workspace, staff, find(workspace.store, code, meal_account_id), method, approval_id, override)
          end
          refuse!(result) unless result['result'] == 'ok'
          result
        end

        def self.find(store, code, meal_account_id)
          return MealAccount.locate(MealAccount.for_store(store), meal_account_id) if meal_account_id.present?

          normalized = MealAccount.normalize_code(code)
          normalized && MealAccount.for_store(store).find_by(employee_code: normalized)
        end

        def self.record(workspace, staff, account, method, approval_id, override)
          now = Workspace.business_now
          return respond(swipe!(workspace, staff, nil, method, now, 'unknown', nil), nil, workspace) if account.nil?

          account.lock!
          window = window_for(account, workspace.branch, now)
          return respond(nil, account, workspace) if counted_here?(account, workspace)

          result = verdict(account, workspace, now, window)
          overridden = %w[window limit].include?(result) && (override || approval_id.present?)
          if overridden
            Guard.approve!(account, staff, workspace.branch, Approval::MEAL_OVERRIDE_ACTION, nil, approval_id)
            account.bump!
            result = 'ok'
          end
          swipe = swipe!(workspace, staff, account, method, now, result, window&.dig('key'))
          if result == 'ok'
            Workspaces::AssignCustomer.assign!(workspace, staff, account.customer_profile)
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { meal_account_id: account.prefixed_id, swipe_id: swipe.prefixed_id,
                                           override: overridden || nil }.compact)
          end
          respond(swipe, account, workspace)
        end

        def self.verdict(account, workspace, now, window)
          return 'revoked' unless account.active?
          return 'duplicate' if MealSwipe.where(meal_account_id: account.id, result: 'ok').where(created_at: (now - DUPLICATE_WINDOW)..).exists?
          return 'window' if account.meal_windows.any? && window.nil?

          counting = MealSwipe.counting.where(meal_account_id: account.id, business_date: workspace.business_date)
          return 'limit' if account.daily_meal_limit && counting.count >= account.daily_meal_limit
          return 'limit' if window && window['limit'] && counting.where(meal_window: window['key']).count >= window['limit']

          'ok'
        end

        def self.counted_here?(account, workspace)
          MealSwipe.counting.where(meal_account_id: account.id, workspace_id: workspace.id).exists?
        end

        def self.window_for(account, branch, now)
          zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
          account.window_at(now.in_time_zone(zone).strftime('%H:%M'))
        end

        def self.swipe!(workspace, staff, account, method, now, result, window_key)
          MealSwipe.create!(store: workspace.store, meal_account: account, branch: workspace.branch, workspace: workspace,
                            actor: staff, input_method: method, business_date: workspace.business_date,
                            meal_window: window_key, result: result, created_at: now)
        end

        def self.respond(swipe, account, workspace)
          workspace.reload
          { 'result' => swipe&.result || 'ok', 'reason' => swipe && MealSwipe::REASONS[swipe.result],
            'meal' => Status.call(account, workspace), 'workspace' => workspace.to_pos }
        end

        def self.refuse!(result)
          raise Conflict.new('The meal was not recorded.', reason: result['reason'],
                                                           details: { result: result['result'], meal: result['meal'] }.compact)
        end
      end
    end
  end
end
