# frozen_string_literal: true

module Spree
  module Pos
    # POS administration (apps/pos-dashboard) at /pos-admin, built into the
    # production image (server/Dockerfile, POS_ADMIN_DIST_PATH). 404 while
    # unset, as in development, where Vite serves the app on its own port.
    class AdminAppController < Spree::Dashboard::SpaController
      private

      def dist_path
        ENV.fetch('POS_ADMIN_DIST_PATH', nil)
      end
    end
  end
end
