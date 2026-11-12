# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Prepaid money and minutes cards: sell one (`create`, with its first
          # top-up), find it by what its QR code or tag reads (`lookup`), its
          # history, more money or minutes, a refund and a correction (both
          # with an approval). The reading of a card is never stored.
          class StoredValueAccountsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            lookup: %w[read_pos_orders write_pos_orders], entries: %w[read_pos_orders write_pos_orders]

            def index
              return if channel_rejected?

              readable_branch!
              scope = Spree::Pos::StoredValueAccount.for_store(current_store).cards.includes(:branch, :customer_profile).order(id: :desc)
              scope = scope.where(kind: params[:kind].to_s) if params[:kind].present?
              render_page(scope)
            end

            def show
              return if channel_rejected?

              readable_branch!
              render json: { data: guard.card!(current_store, params[:id]).to_pos }
            end

            # `card_token`: what the card's QR code or tag reads.
            def lookup
              return if channel_rejected?

              readable_branch!
              card = Spree::Pos::StoredValueAccount.find_card(current_store, params[:card_token])
              render json: { data: card&.to_pos }
            end

            def entries
              return if channel_rejected?

              readable_branch!
              card = guard.card!(current_store, params[:id])
              scope = card.entries.includes(:received_funds, :liability_payout, :actor, workspace: :order).order(id: :desc)
              render_page(scope)
            end

            def create
              top_up(card_id: nil)
            end

            def top_up(card_id: params[:id])
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::StoredValueCards::TopUp.call(
                store: current_store, staff: current_user, key: key, branch_id: params[:branch_id], card_id: card_id,
                card_kind: params[:card_kind], card_token: params[:card_token], minutes: params[:minutes], holder_name: params[:holder_name],
                kind: params[:kind], amount: params[:amount], handed_amount: params[:handed_amount], reference: params[:reference],
                receiving_account: params[:receiving_account], confirm_duplicate: params[:confirm_duplicate]
              )
              render json: { data: data }, status: :created
            end

            def refund
              command do |key|
                Spree::Pos::StoredValueCards::Refund.call(
                  store: current_store, staff: current_user, key: key, branch_id: params[:branch_id], card_id: params[:id],
                  amount: params[:amount], beneficiary_name: params[:beneficiary_name],
                  beneficiary_reference: params[:beneficiary_reference], reason: params[:reason], approval_id: params[:approval_id]
                )
              end
            end

            def adjust
              command do |key|
                Spree::Pos::StoredValueCards::Adjust.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                          card_id: params[:id], amount: params[:amount], minutes: params[:minutes],
                                                          note: params[:note], approval_id: params[:approval_id])
              end
            end

            private

            def guard
              Spree::Pos::StoredValueCards::Guard
            end

            def readable_branch!
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              branch
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
