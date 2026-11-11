# frozen_string_literal: true

module Spree
  module Pos
    module PrintDocuments
      # A posted receipt from its snapshot and the template it prints with.
      module Receipt
        module_function

        def call(receipt:, print:, config:)
          banner = print && print['copy'] ? Text.t('receiptCopyBanner', number: print['copy_number']) : nil
          Renderer.call(config, TemplateData.snapshot(receipt), banner: banner)
        end
      end
    end
  end
end
