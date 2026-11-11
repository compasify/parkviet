# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Called by Workspaces::Complete inside its transaction: records the
      # order's invoice and one outbox entry to issue it. Nothing here talks
      # to a provider, so completing never waits on or fails with one; a
      # store issuing no e-invoice (`none`) gets neither row.
      #
      # A sale without buyer details waits a few minutes before it is issued,
      # so a buyer scanning the QR on the bill still lands on the original
      # invoice; never past the calendar day, by which a cash-register
      # invoice must reach the tax authority.
      module Enqueue
        BUYER_WINDOW = 10.minutes

        module_function

        def call(workspace:, staff:, buyer: {})
          store = workspace.store
          type = StoreProfile.einvoice_type_for(store)
          return nil if type == 'none'

          order = workspace.order
          existing = Einvoice.find_by(order_id: order.id, relation: 'original')
          return existing if existing

          now = Time.current
          setting = EinvoiceSetting.for_branch(workspace.branch)
          snapshot = snapshot(workspace)
          einvoice = Einvoice.create!(
            store: store, branch: workspace.branch, order: order, workspace: workspace, created_by: staff,
            relation: 'original', invoice_type: type, provider: setting&.provider, status: 'pending', buyer: buyer,
            lines_snapshot: snapshot[:lines], totals_snapshot: snapshot[:totals], payment_method: snapshot[:payment_method],
            currency: order.currency, buyer_token_expires_at: BuyerLink.expires_at(workspace.branch, setting, now)
          )
          Einvoices.queue!(einvoice, at: issue_at(workspace.branch, buyer, now))
          einvoice
        end

        # A snapshot that cannot be built is rebuilt when the invoice issues;
        # it never costs the sale.
        def snapshot(workspace)
          Builder.call(workspace)
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { einvoice_workspace_id: workspace.id })
          { lines: [], totals: {}, payment_method: nil }
        end

        def issue_at(branch, buyer, now)
          return now unless Buyer.consumer?(buyer) && BuyerLink.base_url

          [now + BUYER_WINDOW, Einvoices.calendar_day_end(branch, now)].min.then { |at| [at, now].max }
        end
      end
    end
  end
end
