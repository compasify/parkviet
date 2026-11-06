# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class UpdateItems
        def self.add(**kwargs) = ManageLineItem.add(**kwargs)
        def self.update_quantity(**kwargs) = ManageLineItem.update_quantity(**kwargs)
        def self.remove(**kwargs) = ManageLineItem.remove(**kwargs)
      end
    end

    class SaleLineMapper
      def self.for_workspace(workspace)
        SaleLine.where(workspace_id: workspace.id).index_by(&:line_item_id)
      end

      def self.lossless?(workspace)
        core_ids = workspace.order.line_items.pluck(:id).sort
        mapped_ids = SaleLine.where(workspace_id: workspace.id).pluck(:line_item_id).sort
        core_ids == mapped_ids
      end
    end
  end
end
