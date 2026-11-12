# frozen_string_literal: true

module Spree
  module Pos
    module OfflineSales
      # What a counter keeps so it can go on selling cash sales while the
      # server is out of reach: who sells, on which shift and register, the
      # menu with today's prices and sold-out marks, and the receipt header.
      # `offline` says whether this counter may sell offline at all and, if
      # not, why. Nothing secret: no token, no email, no customer.
      module Snapshot
        # How long a counter may sell from one snapshot without the server.
        MAX_AGE = 12.hours

        module_function

        def call(store:, staff:, register:)
          branch = register.branch
          shift = Shift.for_store(store).open_now.find_by(register_id: register.id, owner_id: staff.id)
          profile = ReceiptBuilder.store_profile(store)
          body = {
            store: { id: store.prefixed_id, name: store.name, currency: store.default_currency,
                     profile: ReceiptBuilder::STORE_PROFILE_FIELDS.index_with { |field| profile[field] } },
            branch: { id: branch.prefixed_id, name: branch.name, code: branch.code, timezone: branch.timezone },
            register: { id: register.prefixed_id, name: register.name, code: register.code },
            staff: { id: staff.prefixed_id, name: StaffName.call(staff) },
            shift: shift && { id: shift.prefixed_id, opened_at: shift.opened_at&.iso8601 },
            offline: availability(branch, register, shift),
            menu: ModulePolicy.enabled?(branch, SaleLineKinds::Menu::MODULE) ? Menu::Reader.call(branch: branch) : nil
          }
          body.merge(etag: Digest::SHA256.hexdigest(body.to_json)[0, 32], generated_at: Time.current.iso8601,
                     max_age_seconds: MAX_AGE.to_i)
        end

        # Offline selling needs the menu, cash at the branch, a counter
        # register and the cashier's shift already open on it.
        def availability(branch, register, shift)
          reason = if !ModulePolicy.enabled?(branch, SaleLineKinds::Menu::MODULE) then 'menu_disabled'
                   elsif register.kind != 'counter' then 'register_not_counter'
                   elsif shift.nil? then 'shift_closed'
                   elsif PaymentMethodResolver.new(store: branch.store).available(branch: branch).none? { |row| row.kind == 'cash' }
                     'cash_unavailable'
                   end
          { allowed: reason.nil?, reason: reason }
        end
      end
    end
  end
end
