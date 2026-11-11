# frozen_string_literal: true

module Spree
  module Pos
    # The counter app (apps/pos) at /pos, built into the production image
    # (server/Dockerfile, POS_WEB_DIST_PATH). Same origin as the API, so the
    # staff session cookie and the realtime socket need no CORS. 404 while
    # unset, as in development, where Vite serves the app on its own port.
    class SellingAppController < Spree::Dashboard::SpaController
      private

      def dist_path
        ENV.fetch('POS_WEB_DIST_PATH', nil)
      end
    end
  end
end
