# frozen_string_literal: true

module Spree
  module Pos
    # The guests' QR order page (apps/table-order) at /table, built into the
    # production image (server/Dockerfile, TABLE_ORDER_DIST_PATH). Same origin
    # as the guest API, so the page needs no CORS and the sticker one link.
    # 404 while unset, as in development, where Vite serves the page itself.
    class TableOrderAppController < Spree::Dashboard::SpaController
      # The first address holds the table's code: never sent on as a referrer.
      before_action { response.headers['Referrer-Policy'] = 'no-referrer' }

      private

      def dist_path
        ENV.fetch('TABLE_ORDER_DIST_PATH', nil)
      end
    end
  end
end