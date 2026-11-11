# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Server health for store administrators (`read_pos_topology` or
          # `write_pos_topology`): the address devices pair with, TLS mode,
          # database, jobs, realtime, failed prints, outbound work and the
          # last backup. Store-wide, read-only, counts and ages only.
          class SystemStatusController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_topology write_pos_topology]

            def show
              response.headers['Cache-Control'] = 'no-store'
              render json: { data: Spree::Pos::SystemStatus.new(store: current_store).call }
            end
          end
        end
      end
    end
  end
end
