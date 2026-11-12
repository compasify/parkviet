# frozen_string_literal: true

module Spree
  module Pos
    # Thin branch events over Action Cable. An event only says that something
    # changed; a client reads the change through the API, so permissions and
    # data stay there. Broadcasts leave after commit and never fail a command.
    module Realtime
      EVENTS = %w[
        workspace.updated
        kitchen_ticket.updated
        menu.sold_out
        payment.requested
        print_job.created
        resource.updated
        approval.requested
      ].freeze

      # `refs` may only point at other records, so no caller can slip money,
      # names or line contents into an event.
      REF_KEY = /\A[a-z][a-z_]*_id\z/
      REF_VALUE = /\A[a-z]+_[A-Za-z0-9]{1,40}\z/
      # Named alerts a `resource.updated` may carry, so devices can tell the
      # staff without reading anything else first: a clock's planned end or
      # package is near or over, or a pause has run too long.
      ALERTS = %w[ending_soon ended_package pause_too_long].freeze

      class << self
        def stream_name(branch)
          "pos:branch:#{branch.prefixed_id}"
        end

        # @param branch [Spree::Pos::Branch]
        # @param event [String] one of EVENTS; anything else raises
        # @param payload [Hash] :id (required), and optionally :revision, :lease_generation, :refs and :alert (one of ALERTS). Other keys are dropped.
        def publish(branch, event, payload = {})
          raise ArgumentError, "Unknown realtime event: #{event}" unless EVENTS.include?(event)
          raise ArgumentError, "Realtime event #{event} needs an id" if payload.to_h.symbolize_keys[:id].blank?

          after_commit(event) { broadcast(branch, event, payload) }
        end

        # One `workspace.updated` per workspace. The rows are read after commit
        # so the revision is the committed one, whichever object a workflow
        # happened to update.
        def announce_workspaces(ids)
          after_commit('workspace.updated') do
            Workspace.where(id: ids).includes(:branch).each do |workspace|
              broadcast(workspace.branch, 'workspace.updated', id: workspace.prefixed_id, revision: workspace.revision,
                                                              lease_generation: workspace.lease_generation)
            end
          end
        end

        # Drops the device's open sockets on every server. Call it when the
        # device is revoked or paired again; a reconnect then fails authentication.
        def disconnect_device(device)
          after_commit('disconnect') do
            ActionCable.server.remote_connections.where(device_id: device.prefixed_id).disconnect
          end
        end

        private

        def after_commit(label)
          ActiveRecord.after_all_transactions_commit do
            yield
          rescue StandardError => e
            Rails.logger.error("[pos] realtime #{label} failed: #{e.class}: #{e.message}")
          end
        end

        def broadcast(branch, event, payload)
          ActionCable.server.broadcast(stream_name(branch), message(branch, event, payload))
        end

        def message(branch, event, payload)
          fields = payload.to_h.symbolize_keys
          {
            event: event,
            id: fields[:id],
            branch_id: branch.prefixed_id,
            revision: fields[:revision],
            lease_generation: fields[:lease_generation],
            at: Time.current.iso8601(3),
            alert: ALERTS.include?(fields[:alert].to_s) ? fields[:alert].to_s : nil,
            refs: references(fields[:refs])
          }.compact
        end

        def references(refs)
          refs.to_h.stringify_keys.select { |key, value| key.match?(REF_KEY) && value.to_s.match?(REF_VALUE) }
        end
      end
    end
  end
end
