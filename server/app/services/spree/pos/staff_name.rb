# frozen_string_literal: true

module Spree
  module Pos
    # Display name for staff in shift and report output: the full name, or the
    # local part of the email so reports never list full addresses.
    module StaffName
      module_function

      def call(staff)
        return if staff.nil?

        staff.try(:full_name).presence || staff.email.to_s.split('@').first
      end
    end
  end
end
