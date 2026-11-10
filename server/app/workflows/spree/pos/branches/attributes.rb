# frozen_string_literal: true

module Spree
  module Pos
    module Branches
      # Branch attributes from request parameters, shared by POST/PATCH
      # /branches and the first-run setup. On create (`record` nil) name,
      # code, timezone, stock location and receiving note are always set; the
      # other fields only when sent, so a profile's branch defaults can fill
      # what the request left out. A stock location of another store is not
      # found (404).
      module Attributes
        module_function

        def call(store:, params:, record: nil)
          params = normalize(params)
          attrs = {}
          attrs[:name] = params[:name] if params.key?(:name) || record.nil?
          attrs[:code] = params[:code] if params.key?(:code) || record.nil?
          attrs[:timezone] = params[:timezone] if params.key?(:timezone) || record.nil?
          if params.key?(:business_day_cutoff)
            value = params[:business_day_cutoff].to_s.strip
            unless value.match?(/\A([01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?\z/)
              raise Conflict, 'Business day cutoff is invalid.'
            end

            attrs[:business_day_cutoff] = value.length == 5 ? "#{value}:00" : value
          end
          if params.key?(:staff_session_idle_minutes)
            minutes = Integer(params[:staff_session_idle_minutes], exception: false)
            unless minutes && minutes.between?(5, 240)
              raise Conflict, 'Staff session idle time is invalid.'
            end

            attrs[:staff_session_idle_minutes] = minutes
          end
          attrs[:stock_location] = location!(store, params[:stock_location_id]) if params.key?(:stock_location_id) || record.nil?
          if params.key?(:receiving_stock_location_id)
            prefixed = params[:receiving_stock_location_id]
            attrs[:receiving_stock_location] = prefixed.present? ? location!(store, prefixed) : nil
          end
          attrs[:receiving_config] = { 'note' => params[:receiving_note] } if params.key?(:receiving_note) || record.nil?
          # Blank turns returns off at the branch; a number of days turns them on.
          attrs[:return_window_days] = params[:return_window_days].presence if params.key?(:return_window_days)
          # Blank means every non-zero closing variance needs an approval.
          attrs[:variance_threshold] = params[:variance_threshold].presence if params.key?(:variance_threshold)
          # Blank means the default customer display freshness window.
          attrs[:display_freshness_ttl_seconds] = params[:display_freshness_ttl_seconds].presence if params.key?(:display_freshness_ttl_seconds)
          # FEFO only, or cashiers may name a valid lot at the counter.
          if params.key?(:lot_selection)
            raise Conflict, 'Lot selection is invalid.' unless Branch::LOT_SELECTIONS.include?(params[:lot_selection].to_s)

            attrs[:lot_selection] = params[:lot_selection].to_s
          end
          # Blank means every positive stock count change needs an approval.
          if params.key?(:adjustment_approval_threshold)
            value = params[:adjustment_approval_threshold].to_s.strip
            raise Conflict, 'Adjustment threshold is invalid.' unless value.empty? || value.match?(/\A\d{1,10}\z/)

            attrs[:adjustment_approval_threshold] = value.empty? ? nil : Integer(value, 10)
          end
          attrs
        end

        def normalize(params)
          hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
          hash.with_indifferent_access
        end

        def location!(store, prefixed)
          location = Spree::StockLocation.find_by_prefix_id(prefixed.to_s)
          raise ActiveRecord::RecordNotFound if location.nil? || location.store_id != store.id

          location
        end
      end
    end
  end
end
