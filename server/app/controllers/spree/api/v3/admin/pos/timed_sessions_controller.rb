# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Clocks of karaoke rooms and billiard tables: start on a room (with a
          # prepaid package or a minutes card), pause and resume, stop, move to
          # another room, correct a stretch's times (with an approval) and read
          # the running quote. Every time is the server's.
          class TimedSessionsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders write_pos_orders], quote: %w[read_pos_orders write_pos_orders]

            def create
              command(status: :created) do |key|
                Spree::Pos::Timed::Start.call(store: current_store, staff: current_user, key: key, editor_id: params[:editor_id],
                                              branch_id: params[:branch_id], resource_id: params[:resource_id],
                                              workspace_id: params[:workspace_id], guest_count: params[:guest_count],
                                              planned_end_at: params[:planned_end_at], package_code: params[:package_code],
                                              card_token: params[:card_token], device: @pos_device)
              end
            end

            def show
              return if channel_rejected?

              session = readable_session!
              render json: { data: Spree::Pos::Timed::Sessions.to_pos(session) }
            end

            # The running quote up to now; the same as `show`, named for clients
            # that refresh the price every minute.
            def quote
              show
            end

            def stop
              command do |key|
                Spree::Pos::Timed::Stop.call(session: session!, staff: current_user, key: key, approval_id: params[:approval_id])
              end
            end

            def pause
              command { |key| Spree::Pos::Timed::Pause.call(session: session!, staff: current_user, key: key) }
            end

            def resume
              command do |key|
                Spree::Pos::Timed::Resume.call(session: session!, staff: current_user, key: key, approval_id: params[:approval_id])
              end
            end

            # Puts a minutes card read at the counter on the clock; it pays when the clock stops.
            def minutes_card
              command do |key|
                Spree::Pos::Timed::ApplyMinutesCard.call(session: session!, staff: current_user, key: key, card_token: params[:card_token])
              end
            end

            def move
              command do |key|
                Spree::Pos::Timed::MoveResource.call(session: session!, staff: current_user, key: key, resource_id: params[:resource_id])
              end
            end

            def update_segment
              command do |key|
                Spree::Pos::Timed::EditSegment.call(session: session!, staff: current_user, key: key, segment_id: params[:segment_id],
                                                    started_at: params[:started_at], ended_at: params[:ended_at],
                                                    reason: params[:reason], approval_id: params[:approval_id])
              end
            end

            private

            def session!
              Spree::Pos::Timed::Guard.session!(current_store, params[:id])
            end

            def readable_session!
              session = session!
              policy = Spree::Pos::AccessPolicy.new(store: current_store, staff: current_user)
              raise CanCan::AccessDenied unless policy.can_edit_workspace?(session.workspace) ||
                                                policy.allows?(session.branch, Spree::Pos::Capabilities::TIMED_OPERATE)

              session
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end
          end
        end
      end
    end
  end
end
