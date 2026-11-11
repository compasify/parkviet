# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The store's POS payment methods. Listing saves the built-in rows
          # the store currently gets (cash, bank transfer, VietQR), so every
          # method can be renamed, ordered, disabled and chosen per branch.
          # A method a tender attempt used is disabled, never deleted, and
          # the store keeps at least one active cash method.
          class PaymentMethodsController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_topology write_pos_topology]

            Row = Spree::Pos::PosPaymentMethod

            def index
              return if channel_rejected?

              rows = resolver.materialize!
              rows = rows.select(&:active?) unless ActiveModel::Type::Boolean.new.cast(params[:include_disabled]) == true
              render json: { data: rows.map(&:to_pos) }
            end

            def create
              return if channel_rejected?

              kind = params[:kind].to_s
              return invalid!("Kind must be one of #{Row::COUNTER_KINDS.join(', ')}.") unless Row::COUNTER_KINDS.include?(kind)

              core = core_attributes(kind)
              return if core.nil?

              resolver.materialize!
              code = params[:code].to_s.strip.downcase.presence || "#{kind}_#{SecureRandom.hex(3)}"
              row = Row.create!(store: current_store, kind: kind, code: code, name: params[:name].to_s.strip,
                                position: params.key?(:position) ? params[:position] : next_position,
                                status: 'active', **core)
              audit!('payment_method.create', row, row.to_pos)
              render json: { data: row.to_pos }, status: :created
            rescue ActiveRecord::RecordNotUnique
              raise Spree::Pos::Conflict, 'Another payment method uses this code.'
            end

            # Name, position, status and the core method; kind and code are fixed.
            def update
              return if channel_rejected?

              row = method!
              status = params[:status].to_s if params.key?(:status)
              return invalid!('Status must be active or disabled.') if status && %w[active disabled].exclude?(status)

              core = params.key?(:payment_method_id) ? core_attributes(row.kind) : {}
              return if core.nil?

              row.with_lock do
                row.name = params[:name].to_s.strip if params.key?(:name)
                row.position = params[:position] if params.key?(:position)
                row.status = status if status
                row.assign_attributes(core)
                keep_cash!(row) if row.status_changed? && !row.active?
                if row.changed?
                  row.save!
                  audit!('payment_method.update', row, row.to_pos)
                end
              end
              render json: { data: row.to_pos }
            end

            def destroy
              row = method!
              row.with_lock do
                if row.tender_attempts.exists?
                  raise Spree::Pos::Conflict.new('This payment method has been used; disable it instead.',
                                                 reason: 'payment_method_in_use')
                end
                keep_cash!(row) if row.active?
                audit!('payment_method.delete', row, row.to_pos)
                row.destroy!
              end
              head :no_content
            end

            private

            def resolver
              @resolver ||= Spree::Pos::PaymentMethodResolver.new(store: current_store)
            end

            def method!
              row = Row.locate(Row.for_store(current_store).counter, params[:id])
              raise ActiveRecord::RecordNotFound if row.nil?

              row
            end

            def next_position
              (Row.for_store(current_store).maximum(:position) || -1) + 1
            end

            # `payment_method_id` (a core payment method, or null for the
            # automatic choice) must suit the kind. Renders the error and
            # returns nil when it does not.
            def core_attributes(kind)
              prefixed = params[:payment_method_id].presence
              return { payment_method_id: nil, payment_method_type: nil } if prefixed.nil?

              core = resolver.core_choice(kind, prefixed)
              return { payment_method_id: core.id, payment_method_type: core.type } if core

              invalid!('This payment method cannot settle this kind of POS tender.')
              nil
            end

            def keep_cash!(row)
              return unless row.kind == 'cash'
              return if Row.for_store(current_store).where(kind: 'cash', status: 'active').where.not(id: row.id).exists?

              raise Spree::Pos::Conflict.new('The store needs at least one active cash method.', reason: 'last_cash_method')
            end

            def invalid!(message)
              render_error(code: 'parameter_invalid', message: message, status: :unprocessable_content)
            end
          end
        end
      end
    end
  end
end
