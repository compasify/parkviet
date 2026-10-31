# Spree 6 workflow hook catalog

Every `Spree::Workflow` in `spree_core` (`app/workflows/spree/**`) that declares hooks, generated from the source. Register with `Spree.hooks.register('<workflow key>.<hook>', 'MyHandler')`.

**Kind:** (V) validate — veto with `workflow.reject!` before anything is written · (C) context — return a Hash, merged across handlers · (L) lifecycle — return ignored; many `after_*` hooks run inside the flow's transaction.

**Readers available to a handler** = the `perform` keywords (each becomes a public reader via bare `super`) + the "extra readers" (`attr_reader`s). Extra readers are nil until the step that sets them has run — e.g. nil in `validate`.

**Twins** (`orders.add_item`, `orders.upsert_items`, `orders.recalculate`, `orders.recalculate_totals`) take `order:` but forward it as `cart:` — inside handlers read `workflow.cart` (it is the `Spree::Order`), not `workflow.order`. Note that `orders.recalculate` recalculates totals through `Spree.cart_recalculate_totals_workflow`, so `carts.recalculate_totals.set_tax_line_context` fires for draft-order edits too; `orders.recalculate_totals` fires on post-placement re-sums (order cancel, manual discounts/fees).

Workflows with **no hooks** (registering against them raises `UnknownHookError` at boot when `eager_load` is on): `orders.complete` (`order_complete_workflow`), `catalogs.set_price_list` (`catalog_price_list_workflow`). Checkout completion hooks live on `carts.complete`.

Default registrations shipped by core: `Spree::Returns::EligibilityValidator` on `returns.create.validate` and `exchanges.create.validate` (registered before app initializers — `Spree.hooks.unregister` it in a plain `config/initializers/*` file).

Verify against your installed version: `Spree.hooks.workflows`, `Spree::<Class>.declared_hooks`, or `grep -rn "hooks :" $(bundle show spree_core)/app/workflows`.

## carts

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `carts.add_item` | `Spree::Carts::AddItem` | `validate` (V)<br>`after_item_added` (L) | `cart_add_item_workflow` | `variant:, cart: nil, order: nil, quantity: nil, metadata: {}, options: {}, price: nil` | `line_item`, `line_item_created` |
| `carts.complete` | `Spree::Carts::Complete` | `validate` (V)<br>`before_finalize` (L)<br>`after_finalize` (L) | `carts_complete_workflow` | `cart:, expected_total: nil, payment_pending: false` | `order`, `order_group` |
| `carts.merge` | `Spree::Carts::Merge` | `validate` (V)<br>`after_merge` (L) | `cart_merge_workflow` | `cart:, other_cart: nil, customer: nil` | — |
| `carts.recalculate` | `Spree::Carts::Recalculate` | `set_promotion_context` (C)<br>`after_recalculate` (L) | `cart_recalculate_workflow` | `cart: nil, order: nil, line_item: nil, line_item_created: false, options: {}` | `promotion_context` |
| `carts.recalculate_totals` | `Spree::Carts::RecalculateTotals` | `set_tax_line_context` (C) | `cart_recalculate_totals_workflow` | `cart:, resum_only: false` | `tax_line_context` |
| `carts.upsert_items` | `Spree::Carts::UpsertItems` | `validate` (V)<br>`after_items_upserted` (L) | `cart_upsert_items_workflow` | `cart:, items:` | `variant`, `quantity`, `metadata`, `items`, `warnings`, `resolved_items` |

## catalogs

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `catalogs.activate` | `Spree::Catalogs::Activate` | `validate` (V)<br>`after_activate` (L) | `catalog_activate_workflow` | `catalog:` | — |
| `catalogs.create` | `Spree::Catalogs::Create` | `validate` (V)<br>`after_create` (L) | `catalog_create_workflow` | `store:, attributes: {}` | `catalog` |
| `catalogs.deactivate` | `Spree::Catalogs::Deactivate` | `validate` (V)<br>`after_deactivate` (L) | `catalog_deactivate_workflow` | `catalog:` | — |
| `catalogs.update` | `Spree::Catalogs::Update` | `validate` (V)<br>`after_update` (L) | `catalog_update_workflow` | `catalog:, attributes: {}` | — |

## claims

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `claims.approve` | `Spree::Claims::Approve` | `validate` (V)<br>`after_approve` (L) | `claim_approve_workflow` | `claim:, approver: nil` | — |
| `claims.cancel` | `Spree::Claims::Cancel` | `validate` (V)<br>`after_cancel` (L) | `claim_cancel_workflow` | `claim:, reason: nil` | — |
| `claims.create` | `Spree::Claims::Create` | `validate` (V)<br>`after_create` (L) | `claim_create_workflow` | `order:, items:, reason: nil, memo: nil, created_by: nil` | `claim` |
| `claims.deny` | `Spree::Claims::Deny` | `validate` (V)<br>`after_deny` (L) | `claim_deny_workflow` | `claim:, reason: nil` | — |
| `claims.resolve` | `Spree::Claims::Resolve` | `validate` (V)<br>`before_settle` (L)<br>`after_resolve` (L) | `claim_resolve_workflow` | `claim:, resolution:, refund_method: 'store_credit', amount: nil, replacement_line_item_ids: nil, resolver: nil` | `refunds`, `fulfillments` |

## customers

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `customers.anonymize` | `Spree::Customers::Anonymize` | `validate` (V)<br>`after_anonymize` (L) | `customer_anonymize_workflow` | `customer:, store: nil, requested_by: nil` | — |
| `customers.create` | `Spree::Customers::Create` | `validate` (V)<br>`after_create` (L) | `customer_create_workflow` | `store:, email: nil, password: nil, password_confirmation: nil, first_name: nil, last_name: nil, phone: nil, accepts_email_marketing: nil, metadata: nil, order: nil, password_required: nil, created_by: nil, terms_of_service: nil, ip_address: nil, user_agent: nil` | `customer` |

## data_requests

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `data_requests.fulfill` | `Spree::DataRequests::Fulfill` | `before_fulfill` (L)<br>`extend_payload` (C)<br>`after_fulfill` (L) | — | `data_request:` | — |

## deliveries

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `deliveries.update_tracking` | `Spree::Deliveries::UpdateTracking` | `validate` (V)<br>`after_update_tracking` (L) | `delivery_update_tracking_workflow` | `delivery:, tracking_status: nil, estimated_delivery_at: nil, delivered_at: nil, details: nil, notify_customer: true` | — |

## exchanges

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `exchanges.approve` | `Spree::Exchanges::Approve` | `validate` (V)<br>`after_approve` (L) | `exchange_approve_workflow` | `exchange:, approver: nil` | — |
| `exchanges.cancel` | `Spree::Exchanges::Cancel` | `validate` (V)<br>`after_cancel` (L) | `exchange_cancel_workflow` | `exchange:, reason: nil` | — |
| `exchanges.create` | `Spree::Exchanges::Create` | `validate` (V)<br>`after_create` (L) | `exchange_create_workflow` | `order:, items:, stock_location: nil, reason: nil, memo: nil, created_by: nil` | `exchange` |
| `exchanges.fulfill` | `Spree::Exchanges::Fulfill` | `validate` (V)<br>`before_settle` (L)<br>`after_fulfill` (L) | `exchange_fulfill_workflow` | `exchange:, refund_method: 'store_credit', refunder: nil` | `fulfillments`, `refunds` |
| `exchanges.receive` | `Spree::Exchanges::Receive` | `validate` (V)<br>`before_restock` (L)<br>`after_receive` (L) | `exchange_receive_workflow` | `exchange:, items: nil, received_by: nil` | — |

## fulfillments

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `fulfillments.cancel` | `Spree::Fulfillments::Cancel` | `validate` (V)<br>`after_cancel` (L) | `fulfillment_cancel_workflow` | `fulfillment:, notify_provider: true` | — |
| `fulfillments.create` | `Spree::Fulfillments::Create` | `validate` (V)<br>`get_provider_data` (C)<br>`after_create` (L) | `fulfillment_create_workflow` | `order:, stock_location:, items: nil, tracking: nil, delivery_method: nil, cost: nil, status: nil, metadata: nil` | `fulfillment`, `provider_data` |
| `fulfillments.fulfill` | `Spree::Fulfillments::Fulfill` | `validate` (V)<br>`after_fulfill` (L) | `fulfillment_fulfill_workflow` | `fulfillment:, items: nil, tracking: nil, tracking_carrier: nil, notify_customer: true, force: false` | `fulfillment` |
| `fulfillments.mark_delivered` | `Spree::Fulfillments::MarkDelivered` | `validate` (V)<br>`after_mark_delivered` (L) | `fulfillment_mark_delivered_workflow` | `fulfillment:, delivered_at: nil, notify_customer: true` | — |
| `fulfillments.purchase_label` | `Spree::Fulfillments::PurchaseLabel` | `validate` (V)<br>`after_purchase_label` (L) | `fulfillment_purchase_label_workflow` | `fulfillment:` | — |
| `fulfillments.update` | `Spree::Fulfillments::Update` | `validate` (V)<br>`after_update` (L) | `fulfillment_update_workflow` | `fulfillment: nil, fulfillment_attributes: nil, shipment: nil, shipment_attributes: nil` | `fulfillment` |

## gift_cards

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `gift_cards.apply` | `Spree::GiftCards::Apply` | `validate` (V)<br>`release_holds` (L)<br>`after_apply` (L) | `gift_card_apply_workflow` | `gift_card:, order:` | `released_holds`, `store_credit`, `payment` |
| `gift_cards.cancel` | `Spree::GiftCards::Cancel` | `validate` (V)<br>`after_cancel` (L) | `gift_card_cancel_workflow` | `gift_card:` | — |
| `gift_cards.redeem` | `Spree::GiftCards::Redeem` | `validate` (V)<br>`after_redeem` (L) | `gift_card_redeem_workflow` | `gift_card:` | — |
| `gift_cards.remove` | `Spree::GiftCards::Remove` | `validate` (V)<br>`after_remove` (L) | `gift_card_remove_workflow` | `order:` | — |

## imports

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `imports.complete` | `Spree::Imports::Complete` | `validate` (V)<br>`after_complete` (L) | `import_complete_workflow` | `import:` | — |
| `imports.complete_mapping` | `Spree::Imports::CompleteMapping` | `validate` (V)<br>`after_complete_mapping` (L) | `import_complete_mapping_workflow` | `import:` | — |
| `imports.retry_failed_rows` | `Spree::Imports::RetryFailedRows` | `validate` (V)<br>`after_retry` (L) | `import_retry_failed_rows_workflow` | `import:` | — |
| `imports.start_mapping` | `Spree::Imports::StartMapping` | `validate` (V)<br>`after_start_mapping` (L) | `import_start_mapping_workflow` | `import:` | — |
| `imports.start_processing` | `Spree::Imports::StartProcessing` | `validate` (V)<br>`after_start_processing` (L) | `import_start_processing_workflow` | `import:` | — |

## invitations

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `invitations.accept` | `Spree::Invitations::Accept` | `validate` (V)<br>`after_accept` (L) | `invitation_accept_workflow` | `invitation:` | — |

## orders

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `orders.add_item` | `Spree::Orders::AddItem` (twin of `Spree::Carts::AddItem`) | `validate` (V)<br>`after_item_added` (L) | `order_add_item_service` | `order:, **rest` | — |
| `orders.cancel` | `Spree::Orders::Cancel` | `before_cancel` (V)<br>`after_cancel` (L) | `order_cancel_workflow` | `order:, canceler: nil, canceled_at: nil, reason: nil, note: nil, refund_payments: false, refund_amount: nil, notify_customer: false, restock_items: nil` | — |
| `orders.recalculate` | `Spree::Orders::Recalculate` (twin of `Spree::Carts::Recalculate`) | `set_promotion_context` (C)<br>`after_recalculate` (L) | — | `order:, **rest` | — |
| `orders.recalculate_totals` | `Spree::Orders::RecalculateTotals` (twin of `Spree::Carts::RecalculateTotals`) | `set_tax_line_context` (C) | `order_recalculate_totals_workflow` | `order:, resum_only: false` | — |
| `orders.upsert_items` | `Spree::Orders::UpsertItems` (twin of `Spree::Carts::UpsertItems`) | `validate` (V)<br>`after_items_upserted` (L) | `order_upsert_items_workflow` | `order:, **rest` | — |

## payment_sessions

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `payment_sessions.complete` | `Spree::PaymentSessions::Complete` | `validate` (V)<br>`after_complete` (L) | `payment_session_complete_workflow` | `payment_session:, params: {}` | — |

## payments

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `payments.capture` | `Spree::Payments::Capture` | `validate` (V)<br>`before_capture` (L)<br>`after_capture` (L) | `payment_capture_workflow` | `payment:, amount: nil` | `response`, `remainder` |
| `payments.handle_webhook` | `Spree::Payments::HandleWebhook` | `after_handle` (L) | `payments_handle_webhook_workflow` | `payment_method:, action:, payment_session:, metadata: {}` | `payment` |
| `payments.process` | `Spree::Payments::Process` | `validate` (V)<br>`before_process` (L)<br>`after_process` (L) | `payment_process_workflow` | `payment:, action: nil` | — |
| `payments.void` | `Spree::Payments::Void` | `validate` (V)<br>`before_void` (L)<br>`after_void` (L) | `payment_void_workflow` | `payment:` | — |

## price_lists

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `price_lists.activate` | `Spree::PriceLists::Activate` | `validate` (V)<br>`after_activate` (L) | `price_list_activate_workflow` | `price_list:` | — |
| `price_lists.create` | `Spree::PriceLists::Create` | `validate` (V)<br>`after_create` (L) | `price_list_create_workflow` | `store:, attributes: {}` | `price_list` |
| `price_lists.deactivate` | `Spree::PriceLists::Deactivate` | `validate` (V)<br>`after_deactivate` (L) | `price_list_deactivate_workflow` | `price_list:` | — |
| `price_lists.update` | `Spree::PriceLists::Update` | `validate` (V)<br>`after_update` (L) | `price_list_update_workflow` | `price_list:, attributes: {}` | — |

## products

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `products.activate` | `Spree::Products::Activate` | `validate` (V)<br>`after_activate` (L) | `product_activate_workflow` | `product:` | — |
| `products.approve` | `Spree::Products::Approve` | `validate` (V)<br>`after_approve` (L) | `product_approve_workflow` | `product:, reviewer: nil, note: nil, auto: false` | — |
| `products.archive` | `Spree::Products::Archive` | `validate` (V)<br>`after_archive` (L) | `product_archive_workflow` | `product:` | — |
| `products.create` | `Spree::Products::Create` | `validate` (V)<br>`after_create` (L) | `product_create_workflow` | `store:, attributes: {}, record: nil` | `product` |
| `products.destroy` | `Spree::Products::Destroy` | `validate` (V)<br>`after_destroy` (L) | `product_destroy_workflow` | `product:` | — |
| `products.draft` | `Spree::Products::Draft` | `validate` (V)<br>`after_draft` (L) | `product_draft_workflow` | `product:` | — |
| `products.propose` | `Spree::Products::Propose` | `validate` (V)<br>`after_propose` (L) | `product_propose_workflow` | `product:, submitted_by: nil` | — |
| `products.reject` | `Spree::Products::Reject` | `validate` (V)<br>`after_reject` (L) | `product_reject_workflow` | `product:, reason: nil, reviewer: nil` | — |
| `products.update` | `Spree::Products::Update` | `validate` (V)<br>`after_update` (L) | `product_update_workflow` | `product:, attributes: {}` | — |

## purchase_orders

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `purchase_orders.cancel` | `Spree::PurchaseOrders::Cancel` | `validate` (V)<br>`after_cancel` (L) | `purchase_order_cancel_workflow` | `purchase_order:, reason: nil, canceler: nil` | — |
| `purchase_orders.close` | `Spree::PurchaseOrders::Close` | `validate` (V)<br>`after_close` (L) | `purchase_order_close_workflow` | `purchase_order:, reason: nil` | `purchase_order`, `reason` |
| `purchase_orders.create` | `Spree::PurchaseOrders::Create` | `validate` (V)<br>`after_create` (L) | `purchase_order_create_workflow` | `store:, supplier:, destination_location:, items: [], currency: nil, expected_at: nil, cancel_by: nil, reference: nil, notes: nil, created_by: nil` | `purchase_order` |
| `purchase_orders.mark_draft` | `Spree::PurchaseOrders::MarkDraft` | `validate` (V)<br>`after_mark_draft` (L) | `purchase_order_mark_draft_workflow` | `purchase_order:` | `purchase_order` |
| `purchase_orders.mark_ordered` | `Spree::PurchaseOrders::MarkOrdered` | `validate` (V)<br>`after_mark_ordered` (L) | `purchase_order_mark_ordered_workflow` | `purchase_order:` | — |
| `purchase_orders.receive` | `Spree::PurchaseOrders::Receive` | `validate` (V)<br>`before_restock` (L)<br>`after_receive` (L) | `purchase_order_receive_workflow` | `purchase_order:, items: nil, received_at: nil, reference: nil, notes: nil, received_by: nil` | `purchase_order`, `items`, `received_at`, `reference`, `notes`, `received_by` |
| `purchase_orders.update` | `Spree::PurchaseOrders::Update` | `validate` (V)<br>`after_update` (L) | `purchase_order_update_workflow` | `purchase_order:, attributes: {}, items: nil` | — |

## refunds

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `refunds.create` | `Spree::Refunds::Create` | `validate` (V)<br>`before_refund` (L)<br>`after_refund` (L) | `refund_create_workflow` | `payment:, amount: nil, reason: nil, refunder: nil, originator: nil, order: nil` | `refund` |

## returns

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `returns.approve` | `Spree::Returns::Approve` | `validate` (V)<br>`after_approve` (L) | `return_approve_workflow` | `return_record:, approver: nil` | — |
| `returns.cancel` | `Spree::Returns::Cancel` | `validate` (V)<br>`after_cancel` (L) | `return_cancel_workflow` | `return_record:, reason: nil` | — |
| `returns.create` | `Spree::Returns::Create` | `validate` (V)<br>`after_create` (L) | `return_create_workflow` | `order:, items:, stock_location: nil, reason: nil, memo: nil, created_by: nil` | `return_record` |
| `returns.purchase_label` | `Spree::Returns::PurchaseLabel` | `validate` (V)<br>`after_purchase_label` (L) | `return_purchase_label_workflow` | `return_record:` | — |
| `returns.receive` | `Spree::Returns::Receive` | `validate` (V)<br>`before_restock` (L)<br>`after_receive` (L) | `return_receive_workflow` | `return_record:, items: nil, received_by: nil` | — |
| `returns.refund` | `Spree::Returns::Refund` | `validate` (V)<br>`before_refund` (L)<br>`after_refund` (L) | `return_refund_workflow` | `return_record:, amount: nil, refund_method: 'original_payment', refunder: nil` | `refunds` |

## seller_payouts

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `seller_payouts.complete` | `Spree::SellerPayouts::Complete` | `validate` (V)<br>`after_complete` (L) | `seller_payout_complete_workflow` | `seller_payout:, reference: nil` | — |
| `seller_payouts.sweep` | `Spree::SellerPayouts::Sweep` | `validate` (V)<br>`after_sweep` (L) | `seller_payout_sweep_workflow` | `seller:, currency:` | `payout` |

## seller_requirement_submissions

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `seller_requirement_submissions.accept` | `Spree::SellerRequirementSubmissions::Accept` | `validate` (V)<br>`after_accept` (L) | `seller_requirement_submission_accept_workflow` | `submission:, reviewed_by: nil, review_note: nil` | — |
| `seller_requirement_submissions.create` | `Spree::SellerRequirementSubmissions::Create` | `validate` (V)<br>`after_create` (L) | `seller_requirement_submission_create_workflow` | `seller:, requirement:, note: nil, reference: nil, file: nil, submitted_by: nil` | `submission` |
| `seller_requirement_submissions.reject` | `Spree::SellerRequirementSubmissions::Reject` | `validate` (V)<br>`after_reject` (L) | `seller_requirement_submission_reject_workflow` | `submission:, reviewed_by: nil, review_note: nil` | — |
| `seller_requirement_submissions.waive` | `Spree::SellerRequirementSubmissions::Waive` | `validate` (V)<br>`after_waive` (L) | `seller_requirement_submission_waive_workflow` | `seller:, requirement:, reviewed_by: nil, review_note: nil` | `submission` |

## seller_transfers

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `seller_transfers.create` | `Spree::SellerTransfers::Create` | `validate` (V)<br>`after_create` (L) | `seller_transfer_create_workflow` | `order:` | `seller_transfer` |
| `seller_transfers.reverse` | `Spree::SellerTransfers::Reverse` | `validate` (V)<br>`after_reverse` (L) | `seller_transfer_reverse_workflow` | `order:, amount:, refund: nil` | `reversal` |

## sellers

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `sellers.approve` | `Spree::Sellers::Approve` | `validate` (V)<br>`after_approve` (L) | `seller_approve_workflow` | `seller:, approver: nil, override_requirements: false` | `unmet_requirements` |
| `sellers.create` | `Spree::Sellers::Create` | `validate` (V)<br>`after_create` (L) | `seller_create_workflow` | `store:, attributes: {}` | `seller`, `stock_location` |
| `sellers.invite` | `Spree::Sellers::Invite` | `validate` (V)<br>`after_invite` (L) | `seller_invite_workflow` | `seller:, email:, inviter:, role: nil` | `invitation` |
| `sellers.reject` | `Spree::Sellers::Reject` | `validate` (V)<br>`after_reject` (L) | `seller_reject_workflow` | `seller:, reason: nil, rejected_by: nil` | — |
| `sellers.reopen_onboarding` | `Spree::Sellers::ReopenOnboarding` | `validate` (V)<br>`after_reopen` (L) | `seller_reopen_onboarding_workflow` | `seller:, note: nil, reopened_by: nil` | — |
| `sellers.start_onboarding` | `Spree::Sellers::StartOnboarding` | `validate` (V)<br>`after_start_onboarding` (L) | `seller_start_onboarding_workflow` | `seller:` | — |
| `sellers.submit_for_review` | `Spree::Sellers::SubmitForReview` | `validate` (V)<br>`after_submit` (L) | `seller_submit_for_review_workflow` | `seller:, submitted_by: nil` | `blocking_requirements` |
| `sellers.suspend` | `Spree::Sellers::Suspend` | `validate` (V)<br>`after_suspend` (L) | `seller_suspend_workflow` | `seller:, reason: nil, suspended_by: nil` | — |

## shipping_labels

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `shipping_labels.purchase` | `Spree::ShippingLabels::Purchase` | `validate` (V)<br>`after_purchase` (L) | `shipping_label_purchase_workflow` | `owner:` | `shipping_label` |
| `shipping_labels.record` | `Spree::ShippingLabels::Record` | `validate` (V)<br>`after_record` (L) | `shipping_label_record_workflow` | `owner:, file:, tracking_number:, carrier: nil, service: nil, cost: nil, currency: nil, file_format: nil, tracking_url: nil` | `shipping_label` |
| `shipping_labels.refund` | `Spree::ShippingLabels::Refund` | `validate` (V)<br>`after_refund` (L) | `shipping_label_refund_workflow` | `shipping_label:` | — |

## stock_transfers

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `stock_transfers.cancel` | `Spree::StockTransfers::Cancel` | `validate` (V)<br>`after_cancel` (L) | `stock_transfer_cancel_workflow` | `stock_transfer:, on_in_transit: nil, reason: nil, canceler: nil` | — |
| `stock_transfers.close` | `Spree::StockTransfers::Close` | `validate` (V)<br>`after_close` (L) | `stock_transfer_close_workflow` | `stock_transfer:, reason: nil` | `stock_transfer`, `reason` |
| `stock_transfers.create` | `Spree::StockTransfers::Create` | `validate` (V)<br>`after_create` (L) | `stock_transfer_create_workflow` | `store:, source_location:, destination_location:, items: [], reference: nil, notes: nil, created_by: nil` | `stock_transfer` |
| `stock_transfers.mark_draft` | `Spree::StockTransfers::MarkDraft` | `validate` (V)<br>`after_mark_draft` (L) | `stock_transfer_mark_draft_workflow` | `stock_transfer:` | `stock_transfer` |
| `stock_transfers.mark_in_transit` | `Spree::StockTransfers::MarkInTransit` | `validate` (V)<br>`before_unstock` (L)<br>`after_mark_in_transit` (L) | `stock_transfer_mark_in_transit_workflow` | `stock_transfer:, force: false` | — |
| `stock_transfers.mark_ready` | `Spree::StockTransfers::MarkReady` | `validate` (V)<br>`after_mark_ready` (L) | `stock_transfer_mark_ready_workflow` | `stock_transfer:` | — |
| `stock_transfers.receive` | `Spree::StockTransfers::Receive` | `validate` (V)<br>`before_restock` (L)<br>`after_receive` (L) | `stock_transfer_receive_workflow` | `stock_transfer:, items: nil, received_at: nil, reference: nil, notes: nil, received_by: nil` | `stock_transfer`, `items`, `received_at`, `reference`, `notes`, `received_by` |
| `stock_transfers.update` | `Spree::StockTransfers::Update` | `validate` (V)<br>`after_update` (L) | `stock_transfer_update_workflow` | `stock_transfer:, attributes: {}, items: nil` | — |

## tax_exemption_certificates

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `tax_exemption_certificates.verify` | `Spree::TaxExemptionCertificates::Verify` | `validate` (V)<br>`after_verify` (L) | `tax_exemption_certificate_verify_workflow` | `certificate:, verified_by: nil` | — |

## variants

| Workflow key | Class | Hooks | DI key | `perform` keywords | Extra readers |
|---|---|---|---|---|---|
| `variants.create` | `Spree::Variants::Create` | `validate` (V)<br>`after_create` (L) | `variant_create_workflow` | `product:, attributes: {}` | `variant` |
| `variants.update` | `Spree::Variants::Update` | `validate` (V)<br>`after_update` (L) | `variant_update_workflow` | `variant:, attributes: {}` | — |
