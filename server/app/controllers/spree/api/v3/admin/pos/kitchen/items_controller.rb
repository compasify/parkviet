# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Kitchen
            # Start, finish, serve or recall one kitchen item.
            class ItemsController < BaseController
              scoped_resource :pos_orders
              pos_permissions start: %w[write_pos_orders], ready: %w[write_pos_orders], serve: %w[write_pos_orders],
                              recall: %w[write_pos_orders]

              def start = change('start')
              def ready = change('ready')
              def serve = change('serve')
              def recall = change('recall')

              private

              def change(action)
                item = Spree::Pos::Kitchen::Guard.staff_item!(current_store, current_user, params[:id])
                Spree::Pos::Kitchen::ChangeItemStatus.call(item: item, action: action, actor: current_user)
                render json: { data: item.kitchen_ticket.reload.to_pos }
              end
            end
          end
        end
      end
    end
  end
end