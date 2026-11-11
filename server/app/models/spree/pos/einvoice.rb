# frozen_string_literal: true

module Spree
  module Pos
    # The e-invoice of a completed POS order, issued after completion through
    # the store's provider (Einvoices::Issue) and never during it. Lines,
    # totals, buyer and seller are snapshots; the provider's number, symbol
    # and lookup code are copied back once it is issued.
    #
    # An issued invoice is never edited or cancelled: the rules in force
    # (docs/legal/hddt-nd254-tt91.md) only allow replacing or adjusting it.
    # A replacement is a new row pointing at the invoice it replaces, which
    # becomes `replaced` once the replacement is issued. `canceled` is only
    # for an invoice that never reached the provider.
    class Einvoice < Record
      self.table_name = 'spree_pos_einvoices'
      has_prefix_id :poseinv

      STATUSES = %w[pending issuing issued failed canceled replaced adjusted].freeze
      # Still waiting to be issued: the "no invoice yet" list.
      OUTSTANDING = %w[pending issuing failed].freeze
      FINAL = %w[issued canceled replaced adjusted].freeze
      TYPES = %w[cash_register coded].freeze
      RELATIONS = %w[original replacement].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :original_einvoice, class_name: 'Spree::Pos::Einvoice', optional: true
      belongs_to :created_by, class_name: staff_class_name
      has_many :replacements, class_name: 'Spree::Pos::Einvoice', foreign_key: :original_einvoice_id,
                              inverse_of: :original_einvoice, dependent: :restrict_with_error

      validates :status, inclusion: { in: STATUSES }
      validates :invoice_type, inclusion: { in: TYPES }
      validates :relation, inclusion: { in: RELATIONS }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :outstanding, -> { where(status: OUTSTANDING) }

      def outstanding?
        OUTSTANDING.include?(status)
      end

      # The buyer may still change what the invoice will carry.
      def buyer_editable?
        %w[pending failed].include?(status)
      end

      def buyer_link_open?(now = Time.current)
        buyer_editable? && buyer_token_expires_at.present? && buyer_token_expires_at > now
      end

      def to_pos
        {
          id: prefixed_id, order_id: order.prefixed_id, order_number: order.number, workspace_id: workspace.prefixed_id,
          branch_id: branch.prefixed_id, branch_name: branch.name, relation: relation,
          original_einvoice_id: original_einvoice&.prefixed_id, invoice_type: invoice_type, provider: provider,
          status: status, buyer: buyer, seller: seller, lines: lines_snapshot, totals: totals_snapshot,
          payment_method: payment_method, currency: currency, template_code: template_code, symbol: symbol,
          number: number, cqt_code: cqt_code, lookup_code: lookup_code, lookup_url: lookup_url,
          issued_at: issued_at&.iso8601, attempts: attempts, next_attempt_at: next_attempt_at&.iso8601,
          last_error: last_error, buyer_link_open: buyer_link_open?, buyer_token_expires_at: buyer_token_expires_at&.iso8601,
          buyer_submitted_at: buyer_submitted_at&.iso8601, canceled_at: canceled_at&.iso8601, cancel_reason: cancel_reason,
          completed_at: order.completed_at&.iso8601, total: totals_snapshot['total'], created_at: created_at.iso8601
        }
      end
    end
  end
end
