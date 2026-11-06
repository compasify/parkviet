# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class LeasesController < BaseController
              scoped_resource :pos_workspaces

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ClaimLease.call(
                  workspace: workspace!,
                  staff: current_user,
                  key: key,
                  editor_id: params[:editor_id],
                  takeover: params[:takeover] == true
                )
                render json: { data: result }
              end

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                workspace = workspace!
                generation = params[:lease_generation].to_i
                editor_id = params[:editor_id]
                editor_digest = Spree::Pos::Workspace.editor_digest(editor_id)
                authorize = lambda do
                  allowed = policy.allows?(workspace.branch, Spree::Pos::Capabilities::OPEN_SHIFT) ||
                            policy.allows?(workspace.branch, Spree::Pos::Capabilities::TAKEOVER)
                  raise CanCan::AccessDenied if !allowed || workspace.branch.disabled? || workspace.register&.disabled? || workspace.lease_holder_id != current_user.id
                end
                result = Spree::Pos::CommandExecutor.call(
                  store: current_store,
                  actor: current_user,
                  key: key,
                  payload: { 'command' => 'refresh_lease', 'lease_generation' => generation, 'editor_digest' => editor_digest },
                  workspace: workspace,
                  authorize: authorize
                ) do
                  raise CanCan::AccessDenied unless workspace.lease_holder_id == current_user.id
                  unless workspace.lease_current?(current_user, editor_id) && workspace.lease_generation == generation
                    raise Spree::Pos::Conflict.new('Lease is stale.', revision: workspace.revision, reason: 'lease_stale')
                  end

                  workspace.update!(lease_expires_at: Spree::Pos::Workspace.database_now + Spree::Pos::Workspace::LEASE_TTL)
                  workspace.to_pos
                end
                render json: { data: result }
              end
            end
          end
        end
      end
    end
  end
end
