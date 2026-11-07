# frozen_string_literal: true

module Spree
  module Pos
    # A tracked variant opened for typed stock at one stock location. It is
    # created only from an opening balance whose typed total matched the core
    # count; from then on core stock writes of the pair must come from the POS
    # trace workflows (see StockIntegration).
    class TraceEnrollment < Record
      self.table_name = 'spree_pos_trace_enrollments'
      has_prefix_id :postraceopen

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :opened_by, class_name: staff_class_name

      validates :tracked_mode, inclusion: { in: %w[serial lot] }

      after_save { TraceCurrent.forget! }
      after_destroy { TraceCurrent.forget! }
    end
  end
end
