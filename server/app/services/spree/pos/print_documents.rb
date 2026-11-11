# frozen_string_literal: true

module Spree
  module Pos
    # Builds PrintDocument v1, the neutral document a print station prints. It
    # is the same structure the TypeScript renderer in
    # packages/pos-shared/src/receipt-template/render.ts produces, plus
    # `version` and `kind`. Golden files in spec/fixtures/print_documents are
    # asserted by both sides, so the two renderers cannot drift apart.
    # Documents that only exist on the server have no TypeScript counterpart.
    module PrintDocuments
      VERSION = 1
      REPRINT_BANNER = 'IN LẠI'

      module_function

      # `receipt` is ReceiptSnapshot#to_pos as JSON. `print` is the recorded
      # print's `copy` and `copy_number`, which decide the copy banner.
      def receipt(receipt:, print:, config:)
        wrap('receipt', Receipt.call(receipt: receipt, print: print, config: config))
      end

      # `workspace` is Workspace#to_pos as JSON. `place` names the store, branch
      # and register. `banner` marks a reprint.
      def prebill(workspace:, place:, config:, now:, time_zone:, banner: nil)
        wrap('prebill', Prebill.call(workspace: workspace, place: place, config: config, now: now, time_zone: time_zone, banner: banner))
      end

      def test_page(printer:, now:)
        wrap('test', TestPage.call(printer: printer, now: now))
      end

      # A previously queued document stamped as a reprint.
      def reprint(document)
        banners = Array(document['banners'])
        document.merge('banners' => banners.include?(REPRINT_BANNER) ? banners : banners + [REPRINT_BANNER])
      end

      # The place of a workspace as `prebill` wants it, read now.
      def place_of(workspace)
        store = workspace.store
        branch = workspace.branch
        { 'storeName' => store.name, 'storeProfile' => ReceiptBuilder.store_profile(store), 'branchName' => branch.name,
          'branchCode' => branch.code, 'returnWindowDays' => branch.return_window_days, 'registerName' => workspace.register&.name }
      end

      def wrap(kind, document)
        { 'version' => VERSION, 'kind' => kind }.merge(document)
      end
    end
  end
end
