# Spree 6 event catalogue

Every event below reaches both subscribers and webhook endpoints. Payloads are the API v3 serializer output for the record (prefixed IDs, money as strings, ISO 8601 timestamps); associations the API only returns via `expand` are not included. Canonical, with example payloads: `node_modules/@spree/docs/dist/api-reference/webhooks-events.md`.

`*.created / .updated / .deleted` = lifecycle events from `publishes_lifecycle_events` (fire after commit; `.deleted` payload captured before destroy; a bare `touch` emits nothing).

## Orders and carts

| Resource | Events |
|---|---|
| Order (`or_`) | lifecycle, `order.placed`, `order.paid`, `order.fulfilled`, `order.delivered`, `order.canceled`, `order.approved`, `order.resend_confirmation_email`, `order.resend_digital_links_email` |
| Cart (`cart_`) | lifecycle only — a checked-out cart's order carries `cart_id` |
| Order group | lifecycle, `order_group.completed` (every order of a multi-seller checkout placed; carries the purchase's `notify_customer` — the child `order.placed` events are sent with `notify_customer: false`, so send split-checkout confirmations from this event) |
| Line item | lifecycle |

## Payments

| Resource | Events |
|---|---|
| Payment (`py_`) | lifecycle, `payment.completed`, `payment.captured`, `payment.paid`, `payment.voided`, `payment.refunded` |
| Payment session | lifecycle, `payment_session.processing`, `.completed`, `.failed`, `.canceled`, `.expired` |
| Payment setup session | lifecycle, `payment_setup_session.processing`, `.completed`, `.failed`, `.canceled`, `.expired` |
| Refund | lifecycle |
| Gift card | lifecycle, `gift_card.redeemed`, `gift_card.partially_redeemed`, `gift_card.canceled` |
| Gift card batch, store credit | lifecycle |

## Fulfillment, inventory, post-purchase

| Resource | Events |
|---|---|
| Fulfillment (`ful_`) | lifecycle, `fulfillment.fulfilled`, `fulfillment.delivered`, `fulfillment.canceled` |
| Shipping label | lifecycle, `shipping_label.purchased`, `shipping_label.refunded` |
| Delivery | lifecycle |
| Stock level (`sl_`) | lifecycle |
| Stock movement, stock receipt, stock reservation | lifecycle |
| Stock transfer | lifecycle, `stock_transfer.draft`, `.ready_to_ship`, `.shipped`, `.partially_received`, `.over_received`, `.received`, `.canceled` |
| Purchase order | lifecycle, `purchase_order.draft`, `.ordered`, `.partially_received`, `.over_received`, `.received`, `.canceled` |
| Supplier | lifecycle |
| Return | lifecycle, `return.requested`, `.approved`, `.received`, `.refunded`, `.canceled` |
| Exchange | lifecycle, `exchange.requested`, `.approved`, `.received`, `.fulfilled`, `.canceled` |
| Claim | lifecycle, `claim.opened`, `.approved`, `.denied`, `.resolved`, `.canceled` |

## Catalog

| Resource | Events |
|---|---|
| Product (`prod_`) | lifecycle, `product.activated`, `.archived`, `.drafted`, `.out_of_stock`, `.back_in_stock`, `.proposed`, `.approved`, `.rejected` (last three: marketplace submissions) |
| Variant, price, media, catalog, promotion | lifecycle |
| Product submission | lifecycle |
| Digital asset | lifecycle |
| Digital link | lifecycle, `digital_link.downloaded` |

## Customers and B2B

| Resource | Events |
|---|---|
| Customer (`cust_`) | `user.created`, `user.updated`, `user.deleted`, `customer.password_reset_requested` (carries the reset token — delivered only to endpoints that list it by name, never via `*`/`customer.*`), `customer.password_reset`, `customer.anonymized`. There is no `customer.created`/`updated`/`deleted` |
| Admin / seller users | no lifecycle events; `admin_user.password_reset_requested` and `seller_user.password_reset_requested` exist but are never delivered to webhooks |
| Wishlist, wishlist item | lifecycle |
| Newsletter subscriber | lifecycle, `newsletter_subscriber.subscription_requested`, `.verified`, `.unsubscribe_requested` |
| Company | lifecycle |
| Company invitation | lifecycle, `company_invitation.accepted`, `.revoked` |
| Tax exemption certificate | `tax_exemption_certificate.verified` |
| Tax identifier | `tax_identifier.number_changed` |
| Data request (GDPR) | lifecycle, `data_request.completed` |
| Invitation (staff) | `invitation.created`, `.accepted`, `.resent` |

## Marketplace

| Resource | Events |
|---|---|
| Seller (`sel_`) | lifecycle, `seller.invited`, `.onboarding_started`, `.onboarding_reopened`, `.submitted_for_review`, `.approved`, `.rejected`, `.suspended` |
| Seller requirement submission | lifecycle, `.accepted`, `.rejected`, `.waived` |
| Seller payout | `seller_payout.completed` |

## Bulk operations and reports

| Resource | Events |
|---|---|
| Import | lifecycle, `import.progress`, `import.completed` |
| Import row | `import_row.completed`, `import_row.failed` |
| Export | lifecycle |
| Saved report | lifecycle (`saved_report.*`) |

## Special

- `webhook.test` — synthetic, only sent by "Send test" / `endpoint.send_test!`.

## Deprecated aliases (dual-published until 6.1; only `order.completed` carries `metadata.deprecated_alias_of`)

| Old | New |
|---|---|
| `order.completed` | `order.placed` |
| `order.shipped` | `order.fulfilled` |
| `shipment.shipped` | `fulfillment.fulfilled` |
| `shipment.canceled` | `fulfillment.canceled` |
| `stock_item.*` | `stock_level.*` |
| `wished_item.*` | `wishlist_item.*` |
| `digital.*` | `digital_asset.*` |

## Removed (never published)

`order.resumed`, `fulfillment.resumed` (cancellation is final), `shipment.created/updated` (use `fulfillment.*`), `image.*` (use `media.*`), `report.*` (use `saved_report.*`), `reimbursement.*`, `return_authorization.*`, `return_item.*`, `customer_return.*` (use `return.*` / `exchange.*` / `claim.*`), `post.*`, `post_category.*`.
