# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # A branch's play-time settings beside its prices: the operating
      # hours a clock is started in without a warning, and how many minutes
      # a clock may stay paused before ending the pause needs an approval.
      module SaveSettings
        COMMAND = 'timed.settings'

        module_function

        def call(store:, staff:, key:, branch_id:, operating_windows: nil, max_pause_minutes: nil)
          branch = Guard.branch!(store, branch_id)
          windows = operating_windows.nil? ? nil : OperatingHours.normalize!(operating_windows)
          pause = max_pause_minutes.nil? ? nil : minutes!(max_pause_minutes)
          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'operating_windows' => windows,
                      'max_pause_minutes' => pause }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.manage!(store, staff, branch) }) do
            ModulePolicy.require!(branch, Guard::MODULE)
            branch.lock!
            before = to_pos(branch)
            branch.operating_windows = windows unless windows.nil?
            branch.max_pause_minutes = pause unless pause.nil?
            branch.save!
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: branch, metadata: { before: before, after: to_pos(branch) })
            to_pos(branch)
          end
        end

        def to_pos(branch)
          { branch_id: branch.prefixed_id, operating_windows: branch.operating_windows, max_pause_minutes: branch.max_pause_minutes }
        end

        def minutes!(value)
          minutes = Integer(value.to_s, 10)
          raise ArgumentError unless minutes.between?(1, 240)

          minutes
        rescue ArgumentError
          raise Conflict.new('The pause limit is 1 to 240 minutes.', reason: 'timed_settings_invalid', details: { fields: ['max_pause_minutes'] })
        end
      end
    end
  end
end
