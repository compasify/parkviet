# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Time-of-day menus. Saving one replaces its item list.
          class MenuSchedulesController < MenuResourcesController
            private

            def model
              Spree::Pos::MenuSchedule
            end

            def scope
              model.for_store(current_store).includes(:branch, menu_schedule_items: %i[menu_item variant]).order(:starts_at, :id)
            end

            def save(key, record)
              attributes = params.permit(:branch_id, :name, :label, :starts_at, :ends_at, :active, days_of_week: [],
                                                                                          items: %i[menu_item_id variant_id price hidden]).to_h
              attributes['days_of_week'] = days(attributes['days_of_week']) if attributes.key?('days_of_week')
              menu_save.schedule(store: current_store, staff: current_user, key: key, attributes: attributes, schedule: record)
            end

            def days(values)
              Array(values).map do |day|
                text = day.to_s
                raise Spree::Pos::Conflict.new('Days of week are invalid.', reason: 'menu_schedule_days_invalid') unless text.match?(/\A[0-6]\z/)

                text.to_i
              end
            end
          end
        end
      end
    end
  end
end
