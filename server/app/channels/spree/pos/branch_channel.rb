# frozen_string_literal: true

module Spree
  module Pos
    # One stream per branch. Clients filter by payload and read through the API.
    class BranchChannel < ApplicationCable::Channel
      # Events carry ids only, so a few minutes of a lost permission exposes
      # nothing. The admin JWT lives five minutes and is checked at connect;
      # expiring the socket with it would force a reconnect and full refetch
      # every five minutes, so the membership it stood for is checked instead.
      REVALIDATE_SECONDS = 300

      periodically :revalidate, every: REVALIDATE_SECONDS

      def subscribed
        branch = Branch.find_by_prefix_id(params[:branch_id].to_s)
        return reject unless branch && connection.principal.may_read?(branch)

        @branch = branch
        stream_from Realtime.stream_name(branch)
      end

      private

      # The client reconnects with its current credentials; if those no
      # longer pass, the new connection is refused for good.
      def revalidate
        return if @branch.nil? || connection.principal.still_valid?(@branch)

        connection.close(reason: ActionCable::INTERNAL[:disconnect_reasons][:unauthorized], reconnect: true)
      end
    end
  end
end
