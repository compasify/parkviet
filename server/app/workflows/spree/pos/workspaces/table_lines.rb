# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # What a table order's line may carry besides the item: its course
      # (held back from the kitchen until fired), the seat that ate it, and
      # its buffet. A buffet cover is a `cover` line of the tier's ticket
      # product, one per guest; a dish of the buffet is a free menu line
      # pointing at its cover, and only dishes of the cover's tier qualify.
      module TableLines
        COVER_KIND = 'cover'

        module_function

        # The course, seat and buffet keys of one appended row, checked.
        def normalize(row)
          entry = {}
          entry['course'] = small!(row['course'], 1, CourseLabel::MAX, 'course_invalid') if row['course'].present?
          entry['seat'] = small!(row['seat'], 1, 99, 'seat_invalid') if row['seat'].present?
          if [true, 'true'].include?(row['hold'])
            raise Conflict.new('Only a dish with a course can be held.', reason: 'course_invalid') unless entry['course']

            entry['hold'] = true
          end
          entry['buffet_tier_id'] = row['buffet_tier_id'].to_s if row['buffet_tier_id'].present?
          entry['buffet_cover_line_id'] = row['buffet_cover_line_id'].to_s if row['buffet_cover_line_id'].present?
          entry
        end

        def course_attributes(row)
          { course: row['course'], seat: row['seat'], course_status: row['hold'] ? 'held' : 'none' }
        end

        # Covers of a buffet tier: the tier's ticket at its price, one per guest.
        def add_cover!(workspace:, staff:, row:, attributes:)
          ModulePolicy.require!(workspace.branch, Tables::Guard::MODULE)
          tier = BuffetTier.locate(BuffetTier.active.where(branch_id: workspace.branch_id), row['buffet_tier_id'])
          raise Conflict.new('This buffet tier is not offered here.', reason: 'buffet_tier_invalid') if tier.nil?

          result = LineBuilder.add!(workspace: workspace, staff: staff, variant_id: tier.product.default_variant.prefixed_id,
                                    quantity: row['quantity'], merge: false,
                                    attributes: attributes.merge(course: nil, course_status: 'none'))
          line = result.sale_line
          line.line_modifiers.delete_all
          line.update!(kind: COVER_KIND, buffet_tier: tier,
                       merge_key: SaleLine.build_merge_key(variant_id: line.variant_id, kind: COVER_KIND, unit_price: line.line_price,
                                                           sale_unit_code: line.sale_unit_code))
          result.audit[:buffet_tier_id] = tier.prefixed_id
          result
        end

        # The cover a buffet dish is eaten on; the dish must be on its tier.
        def buffet_cover!(workspace, row)
          cover = SaleLine.locate(SaleLine.where(workspace_id: workspace.id, kind: COVER_KIND), row['buffet_cover_line_id'])
          raise Conflict.new('This buffet ticket is not on the order.', reason: 'buffet_cover_invalid') if cover.nil?

          variant = Spree::Variant.find_by_prefix_id(row['variant_id'].to_s)
          tier = cover.buffet_tier
          if variant.nil? || tier.nil? || tier.item_for(variant.product_id).nil?
            raise Conflict.new('This dish is not on the buffet tier.', reason: 'buffet_item_not_in_tier',
                                                                       details: { buffet_tier_id: tier&.prefixed_id })
          end

          cover
        end

        def small!(value, min, max, reason)
          number = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('A course or seat number is invalid.', reason: reason) unless number&.between?(min, max)

          number
        end
      end
    end
  end
end
