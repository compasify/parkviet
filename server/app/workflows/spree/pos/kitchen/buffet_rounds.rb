# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # The rules of a buffet round, checked when its dishes go to the
      # kitchen. Per cover line (one tier, `sale_quantity` guests):
      # - every dish is on the tier;
      # - the dishes of one send are at most `round_item_limit` per guest,
      #   and each dish at most its `max_per_round` per guest;
      # - a new round starts `round_interval_minutes` after the last one.
      # A round past these limits goes through only for someone who may
      # approve, or with an approval of `buffet.override_round`.
      module BuffetRounds
        REASON = 'buffet_round_limit'

        module_function

        def check!(workspace:, lines:, actor:, approval_id: nil)
          buffet = lines.select(&:buffet_cover_line_id)
          return if buffet.empty?

          now = Workspace.database_now
          problems = buffet.group_by(&:buffet_cover_line_id).flat_map do |cover_id, group|
            cover = SaleLine.find_by(id: cover_id, workspace_id: workspace.id)
            problems_of(cover, group, now)
          end
          return if problems.empty?
          return if override!(workspace, actor, approval_id)

          raise Conflict.new('This buffet round is over its limit.', revision: workspace.revision, reason: REASON,
                                                                     details: { problems: problems })
        end

        def problems_of(cover, lines, now)
          tier = cover&.buffet_tier
          return [{ kind: 'cover_missing' }] if tier.nil?

          guests = cover.sale_quantity.to_i
          problems = []
          lines.each do |line|
            problems << { kind: 'not_in_tier', sale_line_id: line.prefixed_id } if tier.item_for(line.variant.product_id).nil?
          end
          count = lines.sum { |line| line.sale_quantity - line.kitchen_sent_quantity }
          if tier.round_item_limit && count > tier.round_item_limit * guests
            problems << { kind: 'round_item_limit', limit: tier.round_item_limit * guests, requested: count.to_s('F') }
          end
          lines.group_by { |line| line.variant.product_id }.each do |product_id, group|
            item = tier.item_for(product_id)
            next if item&.max_per_round.nil?

            asked = group.sum { |line| line.sale_quantity - line.kitchen_sent_quantity }
            next unless asked > item.max_per_round * guests

            problems << { kind: 'max_per_round', product_id: item.product.prefixed_id, limit: item.max_per_round * guests,
                          requested: asked.to_s('F') }
          end
          last = last_round_at(cover)
          next_round = last && (last + tier.round_interval_minutes.minutes)
          problems << { kind: 'round_interval', next_round_at: next_round.iso8601 } if next_round && next_round > now
          problems
        end

        # When the last dishes of this cover were sent.
        def last_round_at(cover)
          KitchenTicket.joins(items: :sale_line).where(spree_pos_sale_lines: { buffet_cover_line_id: cover.id }).maximum(:sent_at)
        end

        # True when the round may go past its limits: the actor approves,
        # or brings an approval for this order as it is now.
        def override!(workspace, actor, approval_id)
          return false unless actor.is_a?(Spree.admin_user_class)

          Workspaces::ApplyDiscount.approve!(workspace, actor, workspace.revision, approval_id, amount: nil,
                                                                                                action: Approval::BUFFET_OVERRIDE_ACTION,
                                                                                                capability: Capabilities::APPROVE,
                                                                                                message: 'Buffet round approval is required.')
          true
        rescue Conflict => e
          raise unless e.message == 'Buffet round approval is required.'

          false
        end
      end
    end
  end
end
