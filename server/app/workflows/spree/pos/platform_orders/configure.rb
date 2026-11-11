# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # Turns a delivery platform on or off at a branch and sets the percent
      # it keeps. A new rate applies to orders entered afterwards; entered
      # orders keep the rate they were entered with. Turning one on needs
      # `fnb.delivery_platforms` on at the branch; turning it off does not.
      module Configure
        module_function

        def call(store:, staff:, key:, branch:, platform:, status:, commission_rate:)
          platform = platform.to_s
          status = status.to_s
          rate = Record.money(commission_rate.to_s)
          payload = { 'command' => 'platform_setting.change', 'branch_id' => branch.prefixed_id, 'platform' => platform,
                      'status' => status, 'commission_rate' => rate&.to_s('F') }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.manage!(store, staff, branch) }) do
            raise Conflict.new('Choose GrabFood or ShopeeFood.', reason: 'platform_invalid') unless PlatformSetting::PLATFORMS.include?(platform)
            raise Conflict, 'Status must be active or disabled.' unless PlatformSetting::STATUSES.include?(status)
            if rate.nil? || rate > 100 || rate.round(2) != rate
              raise Conflict.new('The commission is a percent from 0 to 100.', reason: 'platform_rate_invalid')
            end

            ModulePolicy.require!(branch, Enter::MODULE) if status == 'active'
            setting = PlatformSetting.lock.find_or_initialize_by(branch_id: branch.id, platform: platform)
            before = setting.persisted? ? setting.to_pos.except(:updated_at) : nil
            setting.assign_attributes(store: store, status: status, commission_rate: rate)
            setting.save!
            AuditEntry.record!(store: store, actor: staff, action: 'platform_setting.change', subject: setting,
                               metadata: { before: before, after: setting.to_pos.except(:updated_at) })
            setting.to_pos
          end
        rescue ActiveRecord::RecordNotUnique
          raise Conflict.new('The platform setting changed meanwhile; try again.', reason: 'retry')
        end
      end
    end
  end
end
