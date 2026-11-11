# frozen_string_literal: true

module Spree
  module Pos
    module PrintDocuments
      # A provisional bill of an open order: always labelled as not paid and
      # never numbered as a receipt.
      module Prebill
        module_function

        def call(workspace:, place:, config:, now:, time_zone:, banner: nil)
          Renderer.call(config, TemplateData.prebill(workspace, place, now, time_zone), banner: banner)
        end
      end
    end
  end
end
