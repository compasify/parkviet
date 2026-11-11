# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Kitchen
            # "Done" for a whole ticket: every open item becomes ready.
            class TicketsController < BaseController
              scoped_resource :pos_orders
              pos_permissions bump: %w[write_pos_orders]

              def bump
                ticket = Spree::Pos::Kitchen::Guard.staff_ticket!(current_store, current_user, params[:id])
                Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: current_user)
                render json: { data: ticket.reload.to_pos }
              end
            end
          end
        end
      end
    end
  end
end