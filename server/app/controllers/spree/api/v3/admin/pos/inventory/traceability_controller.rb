# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Inventory
            # Typed stock at a branch: tracked variants and their reconciliation,
            # opening balances, receipts, transfers, counts and recall search.
            # Writes need pos.inventory.manage at the branch (both branches for a
            # transfer); recall needs pos.inventory.trace.
            class TraceabilityController < BaseController
              scoped_resource :pos_orders
              pos_permissions variants: %w[read_pos_orders], recall: %w[read_pos_orders], adjustments: %w[read_pos_orders]

              ADJUSTMENT_STATUSES = %w[pending_approval applied canceled].freeze

              def variants
                return if channel_rejected?

                branch = branch!(params[:branch_id])
                authorize_reader!(branch)
                product_ids = Spree::Pos::BranchProduct.where(branch_id: branch.id).select(:product_id)
                units = Spree::Pos::VariantUnit.for_store(current_store).where(status: 'active', tracked_mode: %w[serial lot]).
                        joins(:variant).where(spree_variants: { product_id: product_ids }).includes(variant: :product).order(:id).limit(PAGE_MAX)
                render json: { data: units.map { |unit| Spree::Pos::StockIntegration.status(branch, unit.variant, with_lots: false) } }
              end

              def opening_balance
                command do |key|
                  Spree::Pos::Inventory::OpenBalance.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                          variant_id: params[:variant_id], serials: params[:serials], lots: params[:lots])
                end
              end

              def receipt
                command do |key|
                  Spree::Pos::Inventory::ReceiveTraceability.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                                  variant_id: params[:variant_id], serials: params[:serials], lots: params[:lots])
                end
              end

              def transfer
                command do |key|
                  Spree::Pos::Inventory::TransferTraceability.call(store: current_store, staff: current_user, key: key,
                                                                   from_branch_id: params[:from_branch_id], to_branch_id: params[:to_branch_id],
                                                                   variant_id: params[:variant_id], serials: params[:serials], lots: params[:lots])
                end
              end

              def adjustments
                return if channel_rejected?

                branch = branch!(params[:branch_id])
                unless [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::APPROVE].any? { |cap| policy.allows?(branch, cap) }
                  raise CanCan::AccessDenied
                end

                statuses = Array(params[:status].presence || ADJUSTMENT_STATUSES).flat_map { |value| value.to_s.split(',') }
                raise Spree::Pos::Conflict, 'Status filter is invalid.' unless (statuses - ADJUSTMENT_STATUSES).empty?

                scope = Spree::Pos::InventoryAdjustment.for_store(current_store).where(branch_id: branch.id, status: statuses).
                        includes(:branch, :requester, :approval, variant: :product).order(id: :desc)
                render_page(scope)
              end

              def create_adjustment
                command do |key|
                  Spree::Pos::Inventory::AdjustTraceability.create(
                    store: current_store, staff: current_user, key: key, branch_id: params[:branch_id], variant_id: params[:variant_id],
                    reason: params[:reason], lots: params[:lots], missing_serials: params[:missing_serials], found_serials: params[:found_serials]
                  )
                end
              end

              def approve_adjustment
                command(status: :ok) do |key|
                  Spree::Pos::Inventory::AdjustTraceability.approve(store: current_store, staff: current_user, key: key, adjustment_id: params[:id])
                end
              end

              def apply_adjustment
                command(status: :ok) do |key|
                  Spree::Pos::Inventory::AdjustTraceability.apply(store: current_store, staff: current_user, key: key, adjustment_id: params[:id],
                                                                  approval_id: params[:approval_id])
                end
              end

              def cancel_adjustment
                command(status: :ok) do |key|
                  Spree::Pos::Inventory::AdjustTraceability.cancel(store: current_store, staff: current_user, key: key, adjustment_id: params[:id],
                                                                   reason: params[:reason])
                end
              end

              def recall
                return if channel_rejected?

                data, meta = Spree::Pos::TraceRecall.new(store: current_store, policy: policy).call(
                  lot_code: params[:lot_code], serial: params[:serial], variant_id: params[:variant_id],
                  page: params[:page] || 1, limit: params[:limit].presence || 25
                )
                render json: { data: data, meta: meta }
              end

              private

              def command(status: :created)
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                render json: { data: yield(key) }, status: status
              end

              def authorize_reader!(branch)
                readers = [Spree::Pos::Capabilities::INVENTORY_MANAGE, Spree::Pos::Capabilities::INVENTORY_TRACE]
                raise CanCan::AccessDenied unless readers.any? { |capability| policy.allows?(branch, capability) }
              end
            end
          end
        end
      end
    end
  end
end
