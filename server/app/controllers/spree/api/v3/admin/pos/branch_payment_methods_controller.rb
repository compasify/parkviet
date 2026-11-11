# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Which payment methods a branch offers. Without a selection the
          # branch offers every active method of the store; PUT with
          # `payment_method_ids` makes it offer only those, and with
          # `payment_method_ids: null` returns it to every method.
          class BranchPaymentMethodsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[read_pos_topology write_pos_topology]

            def show
              return if channel_rejected?

              render_selection(branch!(params[:branch_id]))
            end

            def update
              return if channel_rejected?

              branch = branch!(params[:branch_id])
              unless params.key?(:payment_method_ids)
                return render_error(code: 'parameter_invalid', message: 'payment_method_ids is required.',
                                    status: :unprocessable_content)
              end

              rows = selected_rows
              return if rows.nil?

              Spree::Pos::BranchPaymentMethod.transaction do
                branch.lock!
                current = Spree::Pos::BranchPaymentMethod.where(branch_id: branch.id)
                current.where.not(pos_payment_method_id: rows.map(&:id)).delete_all
                kept = current.pluck(:pos_payment_method_id)
                rows.reject { |row| kept.include?(row.id) }.each do |row|
                  Spree::Pos::BranchPaymentMethod.create!(store: current_store, branch: branch, pos_payment_method: row)
                end
                audit!('branch.payment_methods', branch, payment_method_ids: rows.map(&:prefixed_id))
              end
              render_selection(branch)
            end

            private

            # Every store method with whether this branch offers it.
            # `customized` is false while the branch offers every method.
            def render_selection(branch)
              resolver = Spree::Pos::PaymentMethodResolver.new(store: current_store)
              rows = resolver.materialize!
              customized = Spree::Pos::BranchPaymentMethod.where(branch_id: branch.id).exists?
              render json: {
                data: {
                  branch_id: branch.prefixed_id,
                  customized: customized,
                  payment_methods: rows.map { |row| row.to_pos.merge(enabled: row.active? && resolver.offered_at?(row, branch)) }
                }
              }
            end

            # nil clears the selection; otherwise a non-empty list of active
            # store methods. Renders the error and returns nil when invalid.
            def selected_rows
              return [] if params[:payment_method_ids].nil?

              ids = Array(params[:payment_method_ids]).map(&:to_s).uniq
              if ids.empty?
                render_error(code: 'parameter_invalid', message: 'A branch needs at least one payment method.',
                             status: :unprocessable_content)
                return nil
              end
              ids.map do |prefixed|
                row = Spree::Pos::PosPaymentMethod.locate(Spree::Pos::PosPaymentMethod.for_store(current_store).counter, prefixed)
                raise ActiveRecord::RecordNotFound if row.nil?
                raise Spree::Pos::Conflict, 'A disabled payment method cannot be offered.' unless row.active?

                row
              end
            end
          end
        end
      end
    end
  end
end
