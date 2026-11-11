# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_12_040500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", null: false
    t.index ["record_type", "record_id", "name", "locale"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.bigint "store_id"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    t.index ["store_id"], name: "index_active_storage_blobs_on_store_id"
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.string "locale"
    t.index ["deleted_at"], name: "index_friendly_id_slugs_on_deleted_at"
    t.index ["locale"], name: "index_friendly_id_slugs_on_locale"
    t.index ["slug", "sluggable_type", "locale"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_locale"
    t.index ["slug", "sluggable_type", "scope", "locale"], name: "index_friendly_id_slugs_unique", unique: true
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "pos_walk_in_orders", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_pos_walk_in_orders_on_order_id", unique: true
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.string "description"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_failure"
    t.text "metadata"
    t.integer "total_jobs", default: 0, null: false
    t.integer "completed_jobs", default: 0, null: false
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "failed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "batch_id"
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "spree_addresses", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "postal_code"
    t.string "phone"
    t.string "state_name"
    t.string "alternative_phone"
    t.string "company"
    t.bigint "state_id"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "label"
    t.jsonb "metadata"
    t.boolean "quick_checkout", default: false
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "country_code"
    t.string "state_code"
    t.string "owner_type"
    t.bigint "owner_id"
    t.index ["country_code"], name: "index_spree_addresses_on_country_code"
    t.index ["country_id"], name: "index_spree_addresses_on_country_id"
    t.index ["deleted_at"], name: "index_spree_addresses_on_deleted_at"
    t.index ["first_name"], name: "index_addresses_on_first_name"
    t.index ["last_name"], name: "index_addresses_on_last_name"
    t.index ["owner_type", "owner_id"], name: "index_spree_addresses_on_owner"
    t.index ["quick_checkout"], name: "index_spree_addresses_on_quick_checkout"
    t.index ["state_id"], name: "index_spree_addresses_on_state_id"
  end

  create_table "spree_adjustments", force: :cascade do |t|
    t.string "source_type"
    t.bigint "source_id"
    t.string "adjustable_type"
    t.bigint "adjustable_id"
    t.decimal "amount", precision: 19, scale: 4
    t.string "label"
    t.boolean "mandatory"
    t.boolean "eligible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.bigint "order_id", null: false
    t.boolean "included", default: false
    t.index ["adjustable_id", "adjustable_type"], name: "index_spree_adjustments_on_adjustable_id_and_adjustable_type"
    t.index ["adjustable_type", "adjustable_id", "source_type"], name: "index_spree_adjustments_on_adjustable_and_source_type"
    t.index ["amount"], name: "index_spree_adjustments_on_amount"
    t.index ["eligible"], name: "index_spree_adjustments_on_eligible"
    t.index ["order_id", "eligible", "source_type"], name: "index_spree_adjustments_on_order_eligible_source_type"
    t.index ["order_id", "state"], name: "index_spree_adjustments_on_order_id_and_state"
    t.index ["order_id"], name: "index_spree_adjustments_on_order_id"
    t.index ["source_id", "source_type"], name: "index_spree_adjustments_on_source_id_and_source_type"
    t.index ["source_type"], name: "index_spree_adjustments_on_source_type"
  end

  create_table "spree_admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "selected_locale"
    t.integer "failed_attempts"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deactivated_at"
    t.datetime "last_active_at"
    t.index ["email"], name: "index_spree_admin_users_on_email", unique: true
  end

  create_table "spree_allowed_origins", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "origin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "origin"], name: "index_spree_allowed_origins_on_store_id_and_origin", unique: true
    t.index ["store_id"], name: "index_spree_allowed_origins_on_store_id"
  end

  create_table "spree_api_keys", force: :cascade do |t|
    t.string "name", null: false
    t.string "key_type", null: false
    t.string "token"
    t.bigint "store_id", null: false
    t.string "created_by_type"
    t.bigint "created_by_id"
    t.datetime "last_used_at"
    t.datetime "revoked_at"
    t.string "revoked_by_type"
    t.bigint "revoked_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_digest"
    t.string "token_prefix"
    t.jsonb "scopes"
    t.bigint "channel_id"
    t.index ["channel_id"], name: "index_spree_api_keys_on_channel_id"
    t.index ["created_by_type", "created_by_id"], name: "index_spree_api_keys_on_created_by"
    t.index ["key_type"], name: "index_spree_api_keys_on_key_type"
    t.index ["revoked_by_type", "revoked_by_id"], name: "index_spree_api_keys_on_revoked_by"
    t.index ["store_id", "key_type"], name: "index_spree_api_keys_on_store_id_and_key_type"
    t.index ["store_id"], name: "index_spree_api_keys_on_store_id"
    t.index ["token"], name: "index_spree_api_keys_on_token", unique: true, where: "(token IS NOT NULL)"
    t.index ["token_digest"], name: "index_spree_api_keys_on_token_digest", unique: true
  end

  create_table "spree_calculators", force: :cascade do |t|
    t.string "type"
    t.string "calculable_type"
    t.bigint "calculable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.jsonb "preferences"
    t.index ["calculable_id", "calculable_type"], name: "index_spree_calculators_on_calculable_id_and_calculable_type"
    t.index ["deleted_at"], name: "index_spree_calculators_on_deleted_at"
    t.index ["id", "type"], name: "index_spree_calculators_on_id_and_type"
  end

  create_table "spree_carts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "market_id", null: false
    t.bigint "channel_id", null: false
    t.bigint "customer_id"
    t.string "currency", null: false
    t.string "locale", null: false
    t.string "email"
    t.bigint "ship_address_id"
    t.bigint "bill_address_id"
    t.boolean "accept_marketing"
    t.text "customer_note"
    t.string "last_ip_address"
    t.string "token", null: false
    t.integer "lock_version", default: 0
    t.datetime "completed_at"
    t.datetime "completing_at"
    t.string "coupon_code"
    t.bigint "gift_card_id"
    t.bigint "preferred_stock_location_id"
    t.decimal "item_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "adjustment_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "taxable_adjustment_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "non_taxable_adjustment_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "discount_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "fee_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "delivery_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "total", precision: 19, scale: 4, default: "0.0"
    t.decimal "payment_total", precision: 19, scale: 4, default: "0.0"
    t.integer "total_quantity", default: 0
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.string "po_number"
    t.index ["channel_id"], name: "index_spree_carts_on_channel_id"
    t.index ["company_id"], name: "index_spree_carts_on_company_id"
    t.index ["completed_at"], name: "index_spree_carts_on_completed_at"
    t.index ["customer_id"], name: "index_spree_carts_on_customer_id"
    t.index ["gift_card_id"], name: "index_spree_carts_on_gift_card_id"
    t.index ["market_id"], name: "index_spree_carts_on_market_id"
    t.index ["store_id", "created_at"], name: "index_spree_carts_on_store_id_and_created_at"
    t.index ["store_id"], name: "index_spree_carts_on_store_id"
    t.index ["token"], name: "index_spree_carts_on_token", unique: true
    t.index ["updated_at"], name: "index_spree_carts_on_updated_at"
  end

  create_table "spree_catalog_assignments", force: :cascade do |t|
    t.bigint "catalog_id", null: false
    t.string "assignable_type", null: false
    t.bigint "assignable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignable_type", "assignable_id"], name: "index_spree_catalog_assignments_on_assignable"
    t.index ["catalog_id", "assignable_type", "assignable_id"], name: "idx_catalog_assignments_uniqueness", unique: true
    t.index ["catalog_id"], name: "index_spree_catalog_assignments_on_catalog_id"
  end

  create_table "spree_catalog_order_minimums", force: :cascade do |t|
    t.bigint "catalog_id", null: false
    t.string "currency", null: false
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_id", "currency"], name: "idx_catalog_order_minimums_on_catalog_and_currency", unique: true
  end

  create_table "spree_catalog_products", force: :cascade do |t|
    t.bigint "catalog_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_id", "product_id"], name: "idx_catalog_products_on_catalog_and_product", unique: true
    t.index ["catalog_id"], name: "index_spree_catalog_products_on_catalog_id"
    t.index ["product_id"], name: "index_spree_catalog_products_on_product_id"
  end

  create_table "spree_catalog_quantity_rules", force: :cascade do |t|
    t.bigint "catalog_id", null: false
    t.bigint "variant_id", null: false
    t.integer "minimum_order_quantity"
    t.integer "order_multiple"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_id", "variant_id"], name: "idx_catalog_quantity_rules_on_catalog_and_variant", unique: true
    t.index ["variant_id"], name: "index_spree_catalog_quantity_rules_on_variant_id"
  end

  create_table "spree_catalogs", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.integer "position"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "minimum_order_quantity"
    t.integer "order_multiple"
    t.index ["store_id"], name: "index_spree_catalogs_on_store_id"
  end

  create_table "spree_categories", force: :cascade do |t|
    t.bigint "parent_id"
    t.integer "position", default: 0
    t.string "name", null: false
    t.string "permalink"
    t.bigint "taxonomy_id"
    t.bigint "lft"
    t.bigint "rgt"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_title"
    t.string "meta_description"
    t.string "meta_keywords"
    t.integer "depth"
    t.boolean "hide_from_nav", default: false
    t.jsonb "metadata"
    t.string "pretty_name"
    t.string "rules_match_policy", default: "all", null: false
    t.string "sort_order", default: "manual", null: false
    t.boolean "automatic", default: false, null: false
    t.integer "children_count", default: 0, null: false
    t.bigint "store_id"
    t.integer "products_count", default: 0, null: false
    t.index ["children_count"], name: "index_spree_categories_on_children_count"
    t.index ["lft"], name: "index_spree_categories_on_lft"
    t.index ["name"], name: "index_spree_categories_on_name"
    t.index ["parent_id"], name: "index_taxons_on_parent_id"
    t.index ["permalink", "store_id"], name: "index_spree_categories_on_permalink_and_store_id", unique: true
    t.index ["permalink"], name: "index_taxons_on_permalink"
    t.index ["position"], name: "index_spree_categories_on_position"
    t.index ["pretty_name"], name: "index_spree_categories_on_pretty_name"
    t.index ["products_count"], name: "index_spree_categories_on_products_count"
    t.index ["rgt"], name: "index_spree_categories_on_rgt"
    t.index ["store_id"], name: "index_spree_categories_on_store_id"
    t.index ["taxonomy_id"], name: "index_taxons_on_taxonomy_id"
  end

  create_table "spree_category_translations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "locale", null: false
    t.bigint "spree_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_title"
    t.string "meta_description"
    t.string "meta_keywords"
    t.string "permalink"
    t.string "pretty_name"
    t.index ["locale"], name: "index_spree_category_translations_on_locale"
    t.index ["pretty_name"], name: "index_spree_category_translations_on_pretty_name"
    t.index ["spree_category_id", "locale"], name: "idx_on_spree_category_id_locale_5fb02d0070", unique: true
  end

  create_table "spree_channel_stock_locations", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "stock_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "stock_location_id"], name: "idx_channel_stock_locations_uniqueness", unique: true
    t.index ["channel_id"], name: "index_spree_channel_stock_locations_on_channel_id"
    t.index ["stock_location_id"], name: "index_spree_channel_stock_locations_on_stock_location_id"
  end

  create_table "spree_channels", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "code", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false, null: false
    t.bigint "default_catalog_id"
    t.jsonb "preferences"
    t.index ["default_catalog_id"], name: "index_spree_channels_on_default_catalog_id"
    t.index ["store_id", "code"], name: "index_spree_channels_on_store_id_and_code", unique: true
    t.index ["store_id"], name: "index_spree_channels_default_per_store", unique: true, where: "(\"default\" = true)"
    t.index ["store_id"], name: "index_spree_channels_on_store_id"
  end

  create_table "spree_claim_line_items", force: :cascade do |t|
    t.bigint "claim_id", null: false
    t.bigint "line_item_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "replacement_variant_id"
    t.integer "quantity", default: 1, null: false
    t.boolean "send_replacement", default: false, null: false
    t.decimal "refund_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.index ["claim_id"], name: "index_spree_claim_line_items_on_claim_id"
    t.index ["line_item_id"], name: "index_spree_claim_line_items_on_line_item_id"
    t.index ["replacement_variant_id"], name: "index_spree_claim_line_items_on_replacement_variant_id"
    t.index ["variant_id"], name: "index_spree_claim_line_items_on_variant_id"
  end

  create_table "spree_claim_reasons", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "store_id", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "name"], name: "index_spree_claim_reasons_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_spree_claim_reasons_on_store_id"
  end

  create_table "spree_claims", force: :cascade do |t|
    t.string "number", null: false
    t.bigint "store_id", null: false
    t.bigint "order_id", null: false
    t.bigint "reason_id"
    t.bigint "created_by_id"
    t.string "status", null: false
    t.string "resolution"
    t.text "memo"
    t.datetime "approved_at"
    t.datetime "resolved_at"
    t.datetime "denied_at"
    t.datetime "canceled_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_by_type"
    t.index ["created_by_id"], name: "index_spree_claims_on_created_by_id"
    t.index ["created_by_type", "created_by_id"], name: "index_spree_claims_on_created_by_actor"
    t.index ["number"], name: "index_spree_claims_on_number", unique: true
    t.index ["order_id"], name: "index_spree_claims_on_order_id"
    t.index ["reason_id"], name: "index_spree_claims_on_reason_id"
    t.index ["status"], name: "index_spree_claims_on_status"
    t.index ["store_id"], name: "index_spree_claims_on_store_id"
  end

  create_table "spree_collection_rules", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.string "type", null: false
    t.string "value"
    t.string "match_policy", default: "is_equal_to", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "type"], name: "index_spree_collection_rules_on_collection_id_and_type"
    t.index ["collection_id"], name: "index_spree_collection_rules_on_collection_id"
  end

  create_table "spree_collection_translations", force: :cascade do |t|
    t.string "name"
    t.string "permalink"
    t.string "meta_title"
    t.string "meta_description"
    t.string "meta_keywords"
    t.string "locale", null: false
    t.bigint "spree_collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["locale"], name: "index_spree_collection_translations_on_locale"
    t.index ["spree_collection_id", "locale"], name: "index_collection_translations_on_collection_and_locale", unique: true
  end

  create_table "spree_collections", force: :cascade do |t|
    t.string "name", null: false
    t.string "permalink"
    t.boolean "automatic", default: false, null: false
    t.string "rules_match_policy", default: "all", null: false
    t.string "sort_order", default: "manual", null: false
    t.integer "position"
    t.integer "products_count", default: 0, null: false
    t.bigint "store_id", null: false
    t.string "meta_title"
    t.string "meta_description"
    t.string "meta_keywords"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["store_id", "permalink"], name: "index_spree_collections_on_store_id_and_permalink", unique: true
    t.index ["store_id"], name: "index_spree_collections_on_store_id"
  end

  create_table "spree_commission_lines", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "line_item_id"
    t.bigint "fulfillment_id"
    t.bigint "commission_rate_id"
    t.decimal "rate", precision: 8, scale: 5, default: "0.0", null: false
    t.string "kind", null: false
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "tax_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "tax_rate", precision: 8, scale: 5, default: "0.0", null: false
    t.decimal "total", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", null: false
    t.string "taxability_reason"
    t.string "country_code"
    t.string "state_code"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commission_rate_id"], name: "index_spree_commission_lines_on_commission_rate_id"
    t.index ["country_code", "state_code"], name: "index_spree_commission_lines_on_country_code_and_state_code"
    t.index ["fulfillment_id"], name: "index_commission_lines_on_fulfillment", unique: true
    t.index ["line_item_id"], name: "index_commission_lines_on_line_item", unique: true
    t.index ["order_id"], name: "index_spree_commission_lines_on_order_id"
    t.index ["seller_id", "created_at"], name: "index_spree_commission_lines_on_seller_id_and_created_at"
    t.index ["seller_id"], name: "index_spree_commission_lines_on_seller_id"
    t.index ["taxability_reason"], name: "index_spree_commission_lines_on_taxability_reason"
    t.check_constraint "(line_item_id IS NULL) <> (fulfillment_id IS NULL)", name: "chk_spree_commission_lines_one_subject"
  end

  create_table "spree_commission_rate_values", force: :cascade do |t|
    t.bigint "commission_rate_id", null: false
    t.string "currency", null: false
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "min_amount", precision: 19, scale: 4
    t.decimal "max_amount", precision: 19, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["commission_rate_id", "currency"], name: "index_commission_rate_values_on_rate_and_currency", unique: true, where: "(deleted_at IS NULL)"
    t.index ["commission_rate_id"], name: "index_spree_commission_rate_values_on_commission_rate_id"
    t.index ["deleted_at"], name: "index_spree_commission_rate_values_on_deleted_at"
  end

  create_table "spree_commission_rates", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "code"
    t.boolean "enabled", default: true, null: false
    t.integer "position", default: 0, null: false
    t.string "kind", null: false
    t.decimal "value", precision: 10, scale: 5, default: "0.0", null: false
    t.boolean "tax_inclusive", default: false, null: false
    t.boolean "include_shipping", default: false, null: false
    t.decimal "commission_tax_rate", precision: 8, scale: 5
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_spree_commission_rates_on_deleted_at"
    t.index ["store_id", "code"], name: "index_spree_commission_rates_on_store_id_and_code", unique: true, where: "(deleted_at IS NULL)"
    t.index ["store_id", "enabled", "position"], name: "idx_on_store_id_enabled_position_2e416afa00"
    t.index ["store_id"], name: "index_spree_commission_rates_on_store_id"
  end

  create_table "spree_commission_rule_products", force: :cascade do |t|
    t.bigint "commission_rule_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["commission_rule_id", "product_id"], name: "index_commission_rule_products_on_rule_and_product", unique: true, where: "(deleted_at IS NULL)"
    t.index ["commission_rule_id"], name: "index_spree_commission_rule_products_on_commission_rule_id"
    t.index ["deleted_at"], name: "index_spree_commission_rule_products_on_deleted_at"
    t.index ["product_id"], name: "index_spree_commission_rule_products_on_product_id"
  end

  create_table "spree_commission_rules", force: :cascade do |t|
    t.bigint "commission_rate_id", null: false
    t.string "type", null: false
    t.jsonb "preferences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["commission_rate_id", "type"], name: "index_commission_rules_on_rate_and_type", unique: true, where: "(deleted_at IS NULL)"
    t.index ["commission_rate_id"], name: "index_spree_commission_rules_on_commission_rate_id"
    t.index ["deleted_at"], name: "index_spree_commission_rules_on_deleted_at"
  end

  create_table "spree_companies", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "parent_id"
    t.string "name", null: false
    t.string "kind", null: false
    t.jsonb "metadata"
    t.bigint "default_bill_address_id"
    t.bigint "default_ship_address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "po_number_required", default: false, null: false
    t.index ["parent_id"], name: "index_spree_companies_on_parent_id"
    t.index ["store_id"], name: "index_spree_companies_on_store_id"
  end

  create_table "spree_company_invitations", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "inviter_id"
    t.bigint "customer_id"
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.datetime "revoked_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "email"], name: "index_spree_company_invitations_on_company_id_and_email"
    t.index ["company_id"], name: "index_spree_company_invitations_on_company_id"
    t.index ["customer_id"], name: "index_spree_company_invitations_on_customer_id"
    t.index ["inviter_id"], name: "index_spree_company_invitations_on_inviter_id"
    t.index ["token"], name: "index_spree_company_invitations_on_token", unique: true
  end

  create_table "spree_company_memberships", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "customer_id"], name: "idx_company_memberships_on_company_and_customer", unique: true
    t.index ["company_id"], name: "index_spree_company_memberships_on_company_id"
    t.index ["customer_id"], name: "index_spree_company_memberships_on_customer_id"
  end

  create_table "spree_consent_records", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "purpose", null: false
    t.string "source", null: false
    t.boolean "accepted", default: true, null: false
    t.string "email"
    t.string "ip_address"
    t.string "user_agent"
    t.jsonb "documents"
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_spree_consent_records_on_lower_email"
    t.index ["owner_type", "owner_id"], name: "index_spree_consent_records_on_owner"
    t.index ["store_id", "purpose", "recorded_at"], name: "index_spree_consent_records_on_store_purpose_recorded"
    t.index ["store_id"], name: "index_spree_consent_records_on_store_id"
  end

  create_table "spree_consolidated_metadata_tables", force: :cascade do |t|
    t.string "table_name", null: false
  end

  create_table "spree_converted_preference_tables", force: :cascade do |t|
    t.string "table_name", null: false
  end

  create_table "spree_countries", force: :cascade do |t|
    t.string "iso_name"
    t.string "iso", null: false
    t.string "iso3", null: false
    t.string "name"
    t.integer "numcode"
    t.boolean "states_required", default: false
    t.datetime "updated_at", precision: nil
    t.boolean "zipcode_required", default: true
    t.datetime "created_at", precision: nil
    t.index ["iso"], name: "index_spree_countries_on_iso", unique: true
    t.index ["iso3"], name: "index_spree_countries_on_iso3", unique: true
    t.index ["iso_name"], name: "index_spree_countries_on_iso_name", unique: true
    t.index ["name"], name: "index_spree_countries_on_name", unique: true
  end

  create_table "spree_coupon_codes", force: :cascade do |t|
    t.string "code"
    t.bigint "promotion_id"
    t.bigint "order_id"
    t.integer "state", default: 0, null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cart_id"
    t.index ["cart_id"], name: "index_spree_coupon_codes_on_cart_id"
    t.index ["code"], name: "index_spree_coupon_codes_on_code", unique: true
    t.index ["deleted_at"], name: "index_spree_coupon_codes_on_deleted_at"
    t.index ["order_id"], name: "index_spree_coupon_codes_on_order_id"
    t.index ["promotion_id"], name: "index_spree_coupon_codes_on_promotion_id"
    t.index ["state"], name: "index_spree_coupon_codes_on_state"
  end

  create_table "spree_credit_cards", force: :cascade do |t|
    t.string "month"
    t.string "year"
    t.string "cc_type"
    t.string "last_digits"
    t.bigint "address_id"
    t.string "gateway_customer_profile_id"
    t.string "gateway_payment_profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "customer_id"
    t.bigint "payment_method_id"
    t.boolean "default", default: false, null: false
    t.datetime "deleted_at", precision: nil
    t.jsonb "metadata"
    t.bigint "gateway_customer_id"
    t.string "fingerprint"
    t.index ["address_id"], name: "index_spree_credit_cards_on_address_id"
    t.index ["customer_id", "payment_method_id", "fingerprint", "month", "year"], name: "index_spree_credit_cards_unique_fingerprint", unique: true, where: "((fingerprint IS NOT NULL) AND (deleted_at IS NULL))"
    t.index ["customer_id"], name: "index_spree_credit_cards_on_customer_id"
    t.index ["deleted_at"], name: "index_spree_credit_cards_on_deleted_at"
    t.index ["gateway_customer_id"], name: "index_spree_credit_cards_on_gateway_customer_id"
    t.index ["payment_method_id"], name: "index_spree_credit_cards_on_payment_method_id"
  end

  create_table "spree_custom_domains", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "url", null: false
    t.boolean "status", default: false
    t.boolean "default", default: false, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_spree_custom_domains_on_store_id"
    t.index ["url"], name: "index_spree_custom_domains_on_url", unique: true
  end

  create_table "spree_custom_field_definitions", force: :cascade do |t|
    t.string "namespace", null: false
    t.string "key", null: false
    t.string "label", null: false
    t.string "field_type", null: false
    t.string "resource_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "searchable"
    t.boolean "sortable"
    t.boolean "storefront_visible", default: true, null: false
    t.bigint "store_id", null: false
    t.string "filter_key", null: false
    t.index ["namespace", "key"], name: "index_spree_custom_field_definitions_on_namespace_and_key"
    t.index ["resource_type"], name: "index_spree_custom_field_definitions_on_resource_type"
    t.index ["store_id", "resource_type", "filter_key"], name: "index_custom_field_definitions_on_store_and_filter_key", unique: true
    t.index ["store_id", "resource_type", "namespace", "key"], name: "index_custom_field_definitions_on_store_and_key", unique: true
    t.index ["store_id"], name: "index_spree_custom_field_definitions_on_store_id"
  end

  create_table "spree_custom_fields", force: :cascade do |t|
    t.string "type", null: false
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.bigint "custom_field_definition_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_definition_id"], name: "index_spree_custom_fields_on_custom_field_definition_id"
    t.index ["resource_type", "resource_id", "custom_field_definition_id"], name: "index_custom_fields_on_resource_and_definition", unique: true
    t.index ["resource_type", "resource_id"], name: "index_spree_metafields_on_resource"
    t.index ["type"], name: "index_spree_custom_fields_on_type"
  end

  create_table "spree_customer_group_users", force: :cascade do |t|
    t.bigint "customer_group_id", null: false
    t.string "customer_type", null: false
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_group_id", "customer_id", "customer_type"], name: "index_spree_customer_group_users_unique", unique: true
    t.index ["customer_group_id"], name: "index_spree_customer_group_users_on_customer_group_id"
    t.index ["customer_type", "customer_id"], name: "index_spree_customer_group_users_on_user"
  end

  create_table "spree_customer_groups", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_spree_customer_groups_on_deleted_at"
    t.index ["store_id", "name"], name: "index_spree_customer_groups_on_store_id_and_name", unique: true, where: "(deleted_at IS NULL)"
    t.index ["store_id"], name: "index_spree_customer_groups_on_store_id"
  end

  create_table "spree_customer_returns", force: :cascade do |t|
    t.string "number"
    t.bigint "stock_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.jsonb "metadata"
    t.index ["number"], name: "index_spree_customer_returns_on_number", unique: true
    t.index ["stock_location_id"], name: "index_spree_customer_returns_on_stock_location_id"
    t.index ["store_id"], name: "index_spree_customer_returns_on_store_id"
  end

  create_table "spree_customers", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "selected_locale"
    t.boolean "accepts_email_marketing", null: false
    t.bigint "bill_address_id"
    t.bigint "ship_address_id"
    t.integer "failed_attempts"
    t.datetime "locked_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "internal_note"
    t.datetime "email_marketing_consent_updated_at"
    t.string "email_marketing_consent_source"
    t.datetime "anonymized_at"
    t.index ["accepts_email_marketing"], name: "index_spree_customers_on_accepts_email_marketing"
    t.index ["anonymized_at"], name: "index_spree_customers_on_anonymized_at"
    t.index ["bill_address_id"], name: "index_spree_customers_on_bill_address_id"
    t.index ["email"], name: "index_spree_customers_on_email", unique: true
    t.index ["ship_address_id"], name: "index_spree_customers_on_ship_address_id"
  end

  create_table "spree_data_feeds", force: :cascade do |t|
    t.bigint "store_id"
    t.string "name"
    t.string "type"
    t.string "slug"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "name"], name: "index_spree_data_feeds_on_store_id_and_name", unique: true
    t.index ["store_id", "slug", "type"], name: "index_spree_data_feeds_on_store_id_and_slug_and_type"
    t.index ["store_id", "slug"], name: "index_spree_data_feeds_on_store_id_and_slug", unique: true
    t.index ["store_id"], name: "index_spree_data_feeds_on_store_id"
  end

  create_table "spree_data_requests", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "customer_id", null: false
    t.string "number", null: false
    t.string "download_token"
    t.string "kind", null: false
    t.string "status", null: false
    t.string "email", null: false
    t.datetime "requested_at", null: false
    t.datetime "completed_at"
    t.datetime "expires_at"
    t.text "error_message"
    t.bigint "requested_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "kind", "status"], name: "index_spree_data_requests_on_customer_kind_status"
    t.index ["customer_id"], name: "index_spree_data_requests_on_customer_id"
    t.index ["download_token"], name: "index_spree_data_requests_on_download_token", unique: true
    t.index ["requested_by_id"], name: "index_spree_data_requests_on_requested_by_id"
    t.index ["store_id", "number"], name: "index_spree_data_requests_on_store_id_and_number", unique: true
    t.index ["store_id"], name: "index_spree_data_requests_on_store_id"
  end

  create_table "spree_deliveries", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.bigint "store_id", null: false
    t.bigint "shipping_label_id"
    t.string "tracking_number", null: false
    t.string "tracking_url"
    t.string "carrier"
    t.string "service"
    t.string "status", null: false
    t.datetime "estimated_delivery_at"
    t.datetime "delivered_at"
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "tracking_number"], name: "index_spree_deliveries_on_owner_and_tracking_number", unique: true
    t.index ["owner_type", "owner_id"], name: "index_spree_deliveries_on_owner"
    t.index ["shipping_label_id"], name: "index_spree_deliveries_on_shipping_label_id", unique: true
    t.index ["store_id", "tracking_number"], name: "index_spree_deliveries_on_store_id_and_tracking_number"
    t.index ["store_id"], name: "index_spree_deliveries_on_store_id"
  end

  create_table "spree_delivery_method_rule_products", force: :cascade do |t|
    t.bigint "delivery_method_rule_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_method_rule_id", "product_id"], name: "idx_delivery_method_rule_products_uniqueness", unique: true
    t.index ["product_id"], name: "index_spree_delivery_method_rule_products_on_product_id"
  end

  create_table "spree_delivery_method_rules", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "delivery_method_id", null: false
    t.boolean "active"
    t.jsonb "preferences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_method_id", "type"], name: "idx_delivery_method_rules_uniqueness", unique: true
    t.index ["delivery_method_id"], name: "index_spree_delivery_method_rules_on_delivery_method_id"
  end

  create_table "spree_delivery_method_services", force: :cascade do |t|
    t.bigint "delivery_method_id", null: false
    t.string "carrier", null: false
    t.string "service", null: false
    t.string "label"
    t.decimal "markup_flat", precision: 19, scale: 4
    t.decimal "markup_percent", precision: 8, scale: 2
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_method_id", "carrier", "service"], name: "idx_delivery_method_services_uniqueness", unique: true
    t.index ["delivery_method_id"], name: "index_spree_delivery_method_services_on_delivery_method_id"
  end

  create_table "spree_delivery_method_stock_locations", force: :cascade do |t|
    t.bigint "delivery_method_id", null: false
    t.bigint "stock_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_method_id", "stock_location_id"], name: "idx_delivery_method_stock_locations_uniqueness", unique: true
    t.index ["stock_location_id"], name: "idx_on_stock_location_id_74b70de887"
  end

  create_table "spree_delivery_methods", force: :cascade do |t|
    t.string "name"
    t.string "display_on"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tracking_url"
    t.string "admin_name"
    t.bigint "tax_category_id"
    t.string "code"
    t.jsonb "metadata"
    t.integer "estimated_transit_business_days_min"
    t.integer "estimated_transit_business_days_max"
    t.boolean "storefront_visible", default: true, null: false
    t.string "fulfillment_provider"
    t.string "pickup_point_provider"
    t.bigint "store_id"
    t.string "rate_provider"
    t.decimal "markup_flat", precision: 19, scale: 4, default: "0.0"
    t.decimal "markup_percent", precision: 8, scale: 2, default: "0.0"
    t.bigint "delivery_profile_id"
    t.bigint "delivery_origin_group_id"
    t.bigint "delivery_zone_id"
    t.bigint "seller_id"
    t.boolean "available_to_sellers", default: false, null: false
    t.index ["deleted_at"], name: "index_spree_delivery_methods_on_deleted_at"
    t.index ["delivery_origin_group_id"], name: "index_spree_delivery_methods_on_delivery_origin_group_id"
    t.index ["delivery_profile_id"], name: "index_spree_delivery_methods_on_delivery_profile_id"
    t.index ["delivery_zone_id"], name: "index_spree_delivery_methods_on_delivery_zone_id"
    t.index ["seller_id"], name: "index_spree_delivery_methods_on_seller_id"
    t.index ["store_id"], name: "index_spree_delivery_methods_on_store_id"
    t.index ["tax_category_id"], name: "index_spree_delivery_methods_on_tax_category_id"
  end

  create_table "spree_delivery_origin_group_locations", force: :cascade do |t|
    t.bigint "delivery_origin_group_id", null: false
    t.bigint "stock_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_origin_group_id", "stock_location_id"], name: "idx_delivery_origin_group_locations_uniqueness", unique: true
    t.index ["delivery_origin_group_id"], name: "idx_on_delivery_origin_group_id_01bd160cac"
    t.index ["stock_location_id"], name: "idx_on_stock_location_id_7029c947c2"
  end

  create_table "spree_delivery_origin_groups", force: :cascade do |t|
    t.bigint "delivery_profile_id", null: false
    t.string "name"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_profile_id"], name: "index_spree_delivery_origin_groups_on_delivery_profile_id"
  end

  create_table "spree_delivery_profiles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.boolean "default", default: false, null: false
    t.string "type"
    t.integer "position", default: 0
    t.index ["name"], name: "index_spree_delivery_profiles_on_name"
    t.index ["store_id"], name: "index_spree_delivery_profiles_on_store_id"
    t.index ["type"], name: "index_spree_delivery_profiles_on_type"
  end

  create_table "spree_delivery_rates", force: :cascade do |t|
    t.bigint "fulfillment_id"
    t.bigint "delivery_method_id"
    t.boolean "selected", default: false
    t.decimal "cost", precision: 19, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tax_rate_id"
    t.string "carrier"
    t.string "service_level"
    t.date "estimated_delivery_date"
    t.jsonb "metadata"
    t.string "name"
    t.boolean "unpriced", default: false, null: false
    t.index ["delivery_method_id"], name: "index_spree_delivery_rates_on_delivery_method_id"
    t.index ["fulfillment_id", "delivery_method_id"], name: "spree_delivery_rates_join_index"
    t.index ["fulfillment_id"], name: "index_spree_delivery_rates_on_fulfillment_id"
    t.index ["selected"], name: "index_spree_delivery_rates_on_selected"
    t.index ["tax_rate_id"], name: "index_spree_delivery_rates_on_tax_rate_id"
  end

  create_table "spree_delivery_zone_members", force: :cascade do |t|
    t.bigint "delivery_zone_id", null: false
    t.string "member_type", null: false
    t.bigint "country_id"
    t.bigint "state_id"
    t.string "postal_code_prefix"
    t.string "postal_code_from"
    t.string "postal_code_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code"
    t.string "state_code"
    t.index ["country_code"], name: "index_spree_delivery_zone_members_on_country_code"
    t.index ["country_id"], name: "index_spree_delivery_zone_members_on_country_id"
    t.index ["delivery_zone_id"], name: "index_spree_delivery_zone_members_on_delivery_zone_id"
    t.index ["state_id"], name: "index_spree_delivery_zone_members_on_state_id"
  end

  create_table "spree_delivery_zones", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "description"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "delivery_profile_id"
    t.bigint "delivery_origin_group_id"
    t.index ["delivery_origin_group_id"], name: "index_spree_delivery_zones_on_delivery_origin_group_id"
    t.index ["delivery_profile_id"], name: "index_spree_delivery_zones_on_delivery_profile_id"
    t.index ["store_id", "name"], name: "index_spree_delivery_zones_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_spree_delivery_zones_on_store_id"
  end

  create_table "spree_digital_assets", force: :cascade do |t|
    t.bigint "variant_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "authorized_clicks"
    t.integer "authorized_days"
    t.string "provider_type"
    t.jsonb "metadata"
    t.index ["variant_id"], name: "index_spree_digital_assets_on_variant_id"
  end

  create_table "spree_digital_links", force: :cascade do |t|
    t.bigint "digital_asset_id"
    t.bigint "line_item_id"
    t.string "token"
    t.integer "access_counter"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["digital_asset_id"], name: "index_spree_digital_links_on_digital_asset_id"
    t.index ["line_item_id"], name: "index_spree_digital_links_on_line_item_id"
    t.index ["token"], name: "index_spree_digital_links_on_token", unique: true
  end

  create_table "spree_discounts", force: :cascade do |t|
    t.bigint "cart_id"
    t.bigint "order_id"
    t.bigint "promotion_action_id"
    t.bigint "promotion_id"
    t.bigint "line_item_id"
    t.bigint "fulfillment_id"
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "label", null: false
    t.string "kind", null: false
    t.string "code"
    t.decimal "value", precision: 19, scale: 4
    t.string "value_type"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_spree_discounts_on_cart_id"
    t.index ["code"], name: "index_spree_discounts_on_code"
    t.index ["fulfillment_id"], name: "index_spree_discounts_on_fulfillment_id"
    t.index ["line_item_id", "kind"], name: "index_spree_discounts_on_line_item_id_and_kind"
    t.index ["line_item_id"], name: "index_spree_discounts_on_line_item_id"
    t.index ["order_id"], name: "index_spree_discounts_on_order_id"
    t.index ["promotion_action_id"], name: "index_spree_discounts_on_promotion_action_id"
    t.index ["promotion_id"], name: "index_spree_discounts_on_promotion_id"
    t.check_constraint "amount <= 0::numeric", name: "chk_spree_discounts_amount_nonpositive"
  end

  create_table "spree_email_template_drafts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "key", null: false
    t.string "locale", null: false
    t.text "subject"
    t.text "body", null: false
    t.text "base_subject"
    t.text "base_body", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "updated_by_type"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "key", "locale"], name: "index_spree_email_template_drafts_on_store_key_locale", unique: true
    t.index ["updated_by_type", "updated_by_id"], name: "index_spree_email_template_drafts_on_updated_by"
  end

  create_table "spree_email_template_revisions", force: :cascade do |t|
    t.bigint "email_template_id", null: false
    t.text "subject"
    t.text "body", null: false
    t.string "published_by_type"
    t.bigint "published_by_id"
    t.datetime "created_at", null: false
    t.index ["email_template_id", "created_at"], name: "index_spree_email_template_revisions_on_template_and_created"
    t.index ["published_by_type", "published_by_id"], name: "index_spree_email_template_revisions_on_published_by"
  end

  create_table "spree_email_templates", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "key", null: false
    t.string "locale", null: false
    t.string "status", null: false
    t.text "subject"
    t.text "body", null: false
    t.text "base_subject"
    t.text "base_body", null: false
    t.datetime "published_at", null: false
    t.string "published_by_type"
    t.bigint "published_by_id"
    t.datetime "reverted_at"
    t.string "reverted_by_type"
    t.bigint "reverted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published_by_type", "published_by_id"], name: "index_spree_email_templates_on_published_by"
    t.index ["reverted_by_type", "reverted_by_id"], name: "index_spree_email_templates_on_reverted_by"
    t.index ["status"], name: "index_spree_email_templates_on_status"
    t.index ["store_id", "key", "locale"], name: "index_spree_email_templates_on_store_key_locale", unique: true
  end

  create_table "spree_exchange_line_items", force: :cascade do |t|
    t.bigint "exchange_id", null: false
    t.bigint "fulfillment_item_id", null: false
    t.bigint "line_item_id", null: false
    t.bigint "original_variant_id", null: false
    t.bigint "new_variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "received_quantity", default: 0, null: false
    t.boolean "resellable", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "original_included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "original_additional_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "new_included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "new_additional_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.index ["exchange_id"], name: "index_spree_exchange_line_items_on_exchange_id"
    t.index ["fulfillment_item_id"], name: "index_spree_exchange_line_items_on_fulfillment_item_id"
    t.index ["line_item_id"], name: "index_spree_exchange_line_items_on_line_item_id"
    t.index ["new_variant_id"], name: "index_spree_exchange_line_items_on_new_variant_id"
    t.index ["original_variant_id"], name: "index_spree_exchange_line_items_on_original_variant_id"
  end

  create_table "spree_exchanges", force: :cascade do |t|
    t.string "number", null: false
    t.bigint "store_id", null: false
    t.bigint "order_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "reason_id"
    t.bigint "created_by_id"
    t.string "status", null: false
    t.text "memo"
    t.datetime "approved_at"
    t.datetime "received_at"
    t.datetime "fulfilled_at"
    t.datetime "canceled_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_by_type"
    t.index ["created_by_id"], name: "index_spree_exchanges_on_created_by_id"
    t.index ["created_by_type", "created_by_id"], name: "index_spree_exchanges_on_created_by_actor"
    t.index ["number"], name: "index_spree_exchanges_on_number", unique: true
    t.index ["order_id"], name: "index_spree_exchanges_on_order_id"
    t.index ["reason_id"], name: "index_spree_exchanges_on_reason_id"
    t.index ["status"], name: "index_spree_exchanges_on_status"
    t.index ["stock_location_id"], name: "index_spree_exchanges_on_stock_location_id"
    t.index ["store_id"], name: "index_spree_exchanges_on_store_id"
  end

  create_table "spree_exports", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "store_id", null: false
    t.string "number", limit: 32, null: false
    t.string "type", null: false
    t.jsonb "search_params"
    t.integer "format", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "seller_id"
    t.jsonb "preferences"
    t.index ["format"], name: "index_spree_exports_on_format"
    t.index ["number"], name: "index_spree_exports_on_number", unique: true
    t.index ["seller_id"], name: "index_spree_exports_on_seller_id"
    t.index ["store_id", "seller_id"], name: "index_spree_exports_on_store_id_and_seller_id"
    t.index ["store_id"], name: "index_spree_exports_on_store_id"
    t.index ["user_id"], name: "index_spree_exports_on_user_id"
  end

  create_table "spree_external_references", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "system", null: false
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "external_id", null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "idx_external_references_on_resource_lookup"
    t.index ["store_id", "system", "resource_type", "external_id"], name: "idx_external_references_on_external_id", unique: true
    t.index ["store_id", "system", "resource_type", "resource_id"], name: "idx_external_references_on_resource", unique: true
  end

  create_table "spree_fees", force: :cascade do |t|
    t.bigint "cart_id"
    t.bigint "order_id"
    t.bigint "line_item_id"
    t.bigint "fulfillment_id"
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "label", null: false
    t.string "kind", null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_spree_fees_on_cart_id"
    t.index ["fulfillment_id"], name: "index_spree_fees_on_fulfillment_id"
    t.index ["line_item_id"], name: "index_spree_fees_on_line_item_id"
    t.index ["order_id", "kind"], name: "index_spree_fees_on_order_id_and_kind"
    t.check_constraint "amount >= 0::numeric", name: "chk_spree_fees_amount_nonnegative"
  end

  create_table "spree_fulfillment_items", force: :cascade do |t|
    t.string "status"
    t.bigint "variant_id"
    t.bigint "order_id"
    t.bigint "fulfillment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pending", default: true
    t.bigint "line_item_id"
    t.integer "quantity", default: 1
    t.bigint "original_return_item_id"
    t.boolean "replacement", default: false, null: false
    t.index ["fulfillment_id"], name: "index_spree_fulfillment_items_on_fulfillment_id"
    t.index ["line_item_id"], name: "index_spree_fulfillment_items_on_line_item_id"
    t.index ["order_id"], name: "index_spree_fulfillment_items_on_order_id"
    t.index ["original_return_item_id"], name: "index_spree_fulfillment_items_on_original_return_item_id"
    t.index ["variant_id"], name: "index_spree_fulfillment_items_on_variant_id"
  end

  create_table "spree_fulfillments", force: :cascade do |t|
    t.string "tracking"
    t.string "number"
    t.decimal "cost", precision: 19, scale: 4, default: "0.0"
    t.datetime "fulfilled_at", precision: nil
    t.bigint "order_id"
    t.bigint "address_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "stock_location_id"
    t.decimal "adjustment_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "discount_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "pre_tax_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "taxable_adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "non_taxable_adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.jsonb "metadata"
    t.string "fulfillment_type"
    t.jsonb "pickup_point_data"
    t.bigint "cart_id"
    t.datetime "delivered_at"
    t.index ["address_id"], name: "index_spree_fulfillments_on_address_id"
    t.index ["cart_id"], name: "index_spree_fulfillments_on_cart_id"
    t.index ["number"], name: "index_spree_fulfillments_on_number", unique: true
    t.index ["order_id"], name: "index_spree_fulfillments_on_order_id"
    t.index ["status"], name: "index_spree_fulfillments_on_status"
    t.index ["stock_location_id"], name: "index_spree_fulfillments_on_stock_location_id"
    t.index ["tracking"], name: "index_spree_fulfillments_on_tracking"
  end

  create_table "spree_gateway_customers", force: :cascade do |t|
    t.string "profile_id", null: false
    t.bigint "payment_method_id", null: false
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "payment_method_id"], name: "idx_on_customer_id_payment_method_id_75005644af", unique: true
    t.index ["customer_id"], name: "index_spree_gateway_customers_on_customer_id"
    t.index ["payment_method_id"], name: "index_spree_gateway_customers_on_payment_method_id"
  end

  create_table "spree_gateways", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.text "description"
    t.boolean "active", default: true
    t.string "environment", default: "development"
    t.string "server", default: "test"
    t.boolean "test_mode", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "preferences"
    t.index ["active"], name: "index_spree_gateways_on_active"
    t.index ["test_mode"], name: "index_spree_gateways_on_test_mode"
  end

  create_table "spree_gift_card_batches", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "created_by_id"
    t.integer "codes_count", default: 1, null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", null: false
    t.string "prefix"
    t.date "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_spree_gift_card_batches_on_created_by_id"
    t.index ["store_id"], name: "index_spree_gift_card_batches_on_store_id"
  end

  create_table "spree_gift_cards", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "customer_id"
    t.bigint "gift_card_batch_id"
    t.bigint "created_by_id"
    t.string "code", null: false
    t.string "status", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.decimal "amount_authorized", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "amount_used", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", null: false
    t.date "expires_at"
    t.datetime "redeemed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_spree_gift_cards_on_code", unique: true
    t.index ["created_by_id"], name: "index_spree_gift_cards_on_created_by_id"
    t.index ["customer_id"], name: "index_spree_gift_cards_on_customer_id"
    t.index ["expires_at"], name: "index_spree_gift_cards_on_expires_at"
    t.index ["gift_card_batch_id"], name: "index_spree_gift_cards_on_gift_card_batch_id"
    t.index ["redeemed_at"], name: "index_spree_gift_cards_on_redeemed_at"
    t.index ["status"], name: "index_spree_gift_cards_on_status"
    t.index ["store_id"], name: "index_spree_gift_cards_on_store_id"
  end

  create_table "spree_import_mappings", force: :cascade do |t|
    t.bigint "import_id", null: false
    t.string "schema_field", null: false
    t.string "file_column"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_column"], name: "index_spree_import_mappings_on_file_column"
    t.index ["import_id", "schema_field"], name: "index_spree_import_mappings_on_import_id_and_schema_field", unique: true
    t.index ["import_id"], name: "index_spree_import_mappings_on_import_id"
  end

  create_table "spree_import_rows", force: :cascade do |t|
    t.bigint "import_id", null: false
    t.string "item_type"
    t.bigint "item_id"
    t.string "status", null: false
    t.integer "row_number", null: false
    t.text "data", null: false
    t.text "validation_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id", "row_number"], name: "index_spree_import_rows_on_import_id_and_row_number", unique: true
    t.index ["import_id", "status"], name: "index_spree_import_rows_on_import_id_and_status"
    t.index ["import_id"], name: "index_spree_import_rows_on_import_id"
    t.index ["item_type", "item_id"], name: "index_spree_import_rows_on_item"
    t.index ["status"], name: "index_spree_import_rows_on_status"
  end

  create_table "spree_imports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "status", null: false
    t.string "number", limit: 32, null: false
    t.string "type", null: false
    t.text "processing_errors"
    t.integer "rows_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "processing_groups_count", default: 0
    t.integer "completed_groups_count", default: 0
    t.bigint "store_id"
    t.bigint "seller_id"
    t.jsonb "preferences"
    t.index ["number"], name: "index_spree_imports_on_number", unique: true
    t.index ["owner_type", "owner_id"], name: "index_spree_imports_on_owner"
    t.index ["seller_id"], name: "index_spree_imports_on_seller_id"
    t.index ["status"], name: "index_spree_imports_on_status"
    t.index ["store_id", "seller_id"], name: "index_spree_imports_on_store_id_and_seller_id"
    t.index ["store_id"], name: "index_spree_imports_on_store_id"
    t.index ["type"], name: "index_spree_imports_on_type"
    t.index ["user_id"], name: "index_spree_imports_on_user_id"
  end

  create_table "spree_integrations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "type", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "secret_preferences"
    t.jsonb "preferences"
    t.index ["active"], name: "index_spree_integrations_on_active"
    t.index ["store_id", "type"], name: "index_spree_integrations_on_store_id_and_type", unique: true
    t.index ["store_id"], name: "index_spree_integrations_on_store_id"
    t.index ["type"], name: "index_spree_integrations_on_type"
  end

  create_table "spree_invitations", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.string "status", null: false
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "inviter_type", null: false
    t.bigint "inviter_id", null: false
    t.string "invitee_type"
    t.bigint "invitee_id"
    t.bigint "role_id", null: false
    t.datetime "accepted_at"
    t.datetime "expires_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_spree_invitations_on_deleted_at"
    t.index ["email"], name: "index_spree_invitations_on_email"
    t.index ["expires_at"], name: "index_spree_invitations_on_expires_at"
    t.index ["invitee_type", "invitee_id"], name: "index_spree_invitations_on_invitee"
    t.index ["inviter_type", "inviter_id"], name: "index_spree_invitations_on_inviter"
    t.index ["resource_type", "resource_id"], name: "index_spree_invitations_on_resource"
    t.index ["role_id"], name: "index_spree_invitations_on_role_id"
    t.index ["status"], name: "index_spree_invitations_on_status"
    t.index ["token"], name: "index_spree_invitations_on_token", unique: true
  end

  create_table "spree_line_items", force: :cascade do |t|
    t.bigint "variant_id"
    t.bigint "order_id"
    t.integer "quantity", null: false
    t.decimal "price", precision: 19, scale: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency"
    t.decimal "cost_price", precision: 19, scale: 4
    t.bigint "tax_category_id"
    t.decimal "adjustment_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "discount_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "pre_tax_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "taxable_adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "non_taxable_adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.jsonb "metadata"
    t.bigint "price_list_id"
    t.bigint "cart_id"
    t.bigint "seller_id"
    t.string "price_source"
    t.index ["cart_id"], name: "index_spree_line_items_on_cart_id"
    t.index ["order_id"], name: "index_spree_line_items_on_order_id"
    t.index ["price_list_id"], name: "index_spree_line_items_on_price_list_id"
    t.index ["seller_id"], name: "index_spree_line_items_on_seller_id"
    t.index ["tax_category_id"], name: "index_spree_line_items_on_tax_category_id"
    t.index ["variant_id"], name: "index_spree_line_items_on_variant_id"
  end

  create_table "spree_log_entries", force: :cascade do |t|
    t.string "source_type"
    t.bigint "source_id"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id", "source_type"], name: "index_spree_log_entries_on_source_id_and_source_type"
  end

  create_table "spree_maintenance_task_runs", force: :cascade do |t|
    t.string "task_name", null: false
    t.string "status", null: false
    t.boolean "dry_run", default: false, null: false
    t.string "cursor"
    t.integer "tick_count", default: 0, null: false
    t.integer "tick_total"
    t.decimal "time_running", precision: 12, scale: 3, default: "0.0", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "error_class"
    t.text "error_message"
    t.text "error_backtrace"
    t.string "job_id"
    t.string "initiated_via", null: false
    t.bigint "admin_user_id"
    t.bigint "api_key_id"
    t.jsonb "arguments"
    t.jsonb "tallies"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_spree_maintenance_task_runs_on_admin_user_id"
    t.index ["api_key_id"], name: "index_spree_maintenance_task_runs_on_api_key_id"
    t.index ["created_at"], name: "index_spree_maintenance_task_runs_on_created_at"
    t.index ["task_name", "status"], name: "index_spree_maintenance_task_runs_on_task_name_and_status"
  end

  create_table "spree_market_countries", force: :cascade do |t|
    t.bigint "market_id", null: false
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code"
    t.index ["country_id"], name: "index_spree_market_countries_on_country_id"
    t.index ["market_id", "country_code"], name: "index_spree_market_countries_on_market_id_and_country_code", unique: true
    t.index ["market_id", "country_id"], name: "index_spree_market_countries_on_market_id_and_country_id", unique: true
    t.index ["market_id"], name: "index_spree_market_countries_on_market_id"
  end

  create_table "spree_markets", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "currency", null: false
    t.string "default_locale", null: false
    t.string "supported_locales"
    t.boolean "tax_inclusive", default: false, null: false
    t.boolean "default", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "tax_provider"
    t.index ["deleted_at"], name: "index_spree_markets_on_deleted_at"
    t.index ["store_id", "default"], name: "index_spree_markets_on_store_id_and_default", where: "(deleted_at IS NULL)"
    t.index ["store_id", "name"], name: "index_spree_markets_on_store_id_and_name", unique: true, where: "(deleted_at IS NULL)"
    t.index ["store_id", "position"], name: "index_spree_markets_on_store_id_and_position"
    t.index ["store_id"], name: "index_spree_markets_on_store_id"
  end

  create_table "spree_media", force: :cascade do |t|
    t.string "viewable_type"
    t.bigint "viewable_id"
    t.integer "attachment_width"
    t.integer "attachment_height"
    t.integer "attachment_file_size"
    t.integer "position"
    t.string "attachment_content_type"
    t.string "attachment_file_name"
    t.string "type", limit: 75
    t.datetime "attachment_updated_at", precision: nil
    t.text "alt"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.jsonb "metadata"
    t.string "session_id"
    t.string "media_type"
    t.decimal "focal_point_x", precision: 5, scale: 4
    t.decimal "focal_point_y", precision: 5, scale: 4
    t.string "external_video_url"
    t.bigint "store_id"
    t.index ["media_type"], name: "index_spree_media_on_media_type"
    t.index ["position"], name: "index_spree_media_on_position"
    t.index ["store_id"], name: "index_spree_media_on_store_id"
    t.index ["viewable_id"], name: "index_assets_on_viewable_id"
    t.index ["viewable_type", "type"], name: "index_assets_on_viewable_type_and_type"
  end

  create_table "spree_newsletter_subscribers", force: :cascade do |t|
    t.string "email", null: false
    t.bigint "customer_id"
    t.datetime "verified_at"
    t.string "verification_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
    t.bigint "store_id", null: false
    t.index ["customer_id"], name: "index_spree_newsletter_subscribers_on_customer_id"
    t.index ["email", "store_id"], name: "index_spree_newsletter_subscribers_on_email_and_store_id", unique: true
    t.index ["store_id"], name: "index_spree_newsletter_subscribers_on_store_id"
    t.index ["verification_token"], name: "index_spree_newsletter_subscribers_on_verification_token", unique: true
    t.index ["verified_at"], name: "index_spree_newsletter_subscribers_on_verified_at"
  end

  create_table "spree_number_sequences", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "resource_type", null: false
    t.bigint "value", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "resource_type"], name: "index_spree_number_sequences_on_store_and_resource", unique: true
    t.index ["store_id"], name: "index_spree_number_sequences_on_store_id"
  end

  create_table "spree_oauth_access_grants", force: :cascade do |t|
    t.string "resource_owner_type", null: false
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.datetime "revoked_at"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.text "resource"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_spree_oauth_access_grants_on_application_id"
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_spree_oauth_access_grants_on_resource_owner"
    t.index ["token"], name: "index_spree_oauth_access_grants_on_token", unique: true
  end

  create_table "spree_oauth_access_tokens", force: :cascade do |t|
    t.string "resource_owner_type"
    t.bigint "resource_owner_id"
    t.bigint "application_id"
    t.text "token", null: false
    t.text "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.text "resource"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_spree_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_spree_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_spree_oauth_access_tokens_on_resource_owner"
    t.index ["token"], name: "index_spree_oauth_access_tokens_on_token", unique: true
  end

  create_table "spree_oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret"
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: false, null: false
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_spree_oauth_applications_on_store_id"
    t.index ["uid"], name: "index_spree_oauth_applications_on_uid", unique: true
  end

  create_table "spree_option_type_product_types", force: :cascade do |t|
    t.bigint "product_type_id"
    t.bigint "option_type_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["option_type_id"], name: "index_option_type_product_types_on_option_type_id"
    t.index ["product_type_id", "option_type_id"], name: "index_option_type_product_types_uniqueness", unique: true
  end

  create_table "spree_option_type_translations", force: :cascade do |t|
    t.string "label"
    t.string "locale", null: false
    t.bigint "spree_option_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_spree_option_type_translations_on_locale"
    t.index ["spree_option_type_id", "locale"], name: "unique_option_type_id_per_locale", unique: true
  end

  create_table "spree_option_types", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "label", limit: 100
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "filterable", default: true, null: false
    t.jsonb "metadata"
    t.string "kind", default: "dropdown", null: false
    t.bigint "store_id"
    t.index ["filterable"], name: "index_spree_option_types_on_filterable"
    t.index ["kind"], name: "index_spree_option_types_on_kind"
    t.index ["position"], name: "index_spree_option_types_on_position"
    t.index ["store_id", "name"], name: "index_spree_option_types_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_spree_option_types_on_store_id"
  end

  create_table "spree_option_value_translations", force: :cascade do |t|
    t.string "label"
    t.string "locale", null: false
    t.bigint "spree_option_value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_spree_option_value_translations_on_locale"
    t.index ["spree_option_value_id", "locale"], name: "unique_option_value_id_per_locale", unique: true
  end

  create_table "spree_option_value_variants", force: :cascade do |t|
    t.bigint "variant_id"
    t.bigint "option_value_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["option_value_id"], name: "index_spree_option_value_variants_on_option_value_id"
    t.index ["variant_id", "option_value_id"], name: "index_option_values_variants_on_variant_id_and_option_value_id", unique: true
    t.index ["variant_id"], name: "index_spree_option_value_variants_on_variant_id"
  end

  create_table "spree_option_values", force: :cascade do |t|
    t.integer "position"
    t.string "name"
    t.string "label"
    t.bigint "option_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
    t.string "color_code"
    t.index ["name"], name: "index_spree_option_values_on_name"
    t.index ["option_type_id", "name"], name: "index_spree_option_values_on_option_type_id_and_name", unique: true
    t.index ["option_type_id"], name: "index_spree_option_values_on_option_type_id"
    t.index ["position"], name: "index_spree_option_values_on_position"
  end

  create_table "spree_order_cancellation_reasons", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "store_id", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "name"], name: "idx_order_cancellation_reasons_on_store_and_name", unique: true
    t.index ["store_id"], name: "index_spree_order_cancellation_reasons_on_store_id"
  end

  create_table "spree_order_groups", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "customer_id"
    t.bigint "cart_id"
    t.string "number", null: false
    t.string "currency", null: false
    t.string "email"
    t.string "token"
    t.bigint "ship_address_id"
    t.bigint "bill_address_id"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confirmation_delivered", default: false
    t.boolean "store_owner_notification_delivered", default: false
    t.index ["bill_address_id"], name: "index_spree_order_groups_on_bill_address_id"
    t.index ["cart_id"], name: "index_spree_order_groups_on_cart_id", unique: true
    t.index ["confirmation_delivered"], name: "index_spree_order_groups_on_confirmation_delivered"
    t.index ["customer_id"], name: "index_spree_order_groups_on_customer_id"
    t.index ["number"], name: "index_spree_order_groups_on_number", unique: true
    t.index ["ship_address_id"], name: "index_spree_order_groups_on_ship_address_id"
    t.index ["store_id", "created_at"], name: "index_spree_order_groups_on_store_id_and_created_at"
    t.index ["store_id"], name: "index_spree_order_groups_on_store_id"
    t.index ["token"], name: "index_spree_order_groups_on_token"
  end

  create_table "spree_order_promotions", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "promotion_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "cart_id"
    t.index ["cart_id"], name: "index_spree_order_promotions_on_cart_id"
    t.index ["order_id"], name: "index_spree_order_promotions_on_order_id"
    t.index ["promotion_id", "order_id"], name: "index_spree_order_promotions_on_promotion_id_and_order_id", unique: true
    t.index ["promotion_id"], name: "index_spree_order_promotions_on_promotion_id"
  end

  create_table "spree_order_routing_rules", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "channel_id", null: false
    t.string "type", null: false
    t.integer "position", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "preferences"
    t.index ["channel_id", "active", "position"], name: "idx_order_routing_rules_lookup"
    t.index ["channel_id", "position"], name: "index_spree_order_routing_rules_on_channel_id_and_position"
    t.index ["channel_id", "type"], name: "idx_order_routing_rules_channel_type", unique: true
    t.index ["channel_id"], name: "index_spree_order_routing_rules_on_channel_id"
    t.index ["store_id"], name: "index_spree_order_routing_rules_on_store_id"
    t.index ["type"], name: "index_spree_order_routing_rules_on_type"
  end

  create_table "spree_orders", force: :cascade do |t|
    t.string "number", limit: 32
    t.decimal "item_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.bigint "customer_id"
    t.datetime "completed_at", precision: nil
    t.bigint "bill_address_id"
    t.bigint "ship_address_id"
    t.decimal "payment_total", precision: 19, scale: 4, default: "0.0"
    t.string "fulfillment_status"
    t.string "payment_status"
    t.string "email"
    t.text "customer_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency"
    t.string "last_ip_address"
    t.bigint "created_by_id"
    t.decimal "delivery_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0"
    t.decimal "discount_total", precision: 19, scale: 4, default: "0.0"
    t.string "channel", default: "spree"
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.integer "total_quantity", default: 0
    t.bigint "approver_id"
    t.datetime "approved_at", precision: nil
    t.boolean "confirmation_delivered", default: false
    t.boolean "considered_risky", default: false
    t.string "token"
    t.datetime "canceled_at", precision: nil
    t.bigint "canceler_id"
    t.bigint "store_id"
    t.integer "lock_version", default: 0, null: false
    t.decimal "taxable_adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "non_taxable_adjustment_total", precision: 19, scale: 4, default: "0.0", null: false
    t.boolean "store_owner_notification_delivered"
    t.jsonb "metadata"
    t.text "internal_note"
    t.boolean "accept_marketing", default: false
    t.boolean "signup_for_an_account", default: false
    t.bigint "gift_card_id"
    t.string "locale"
    t.bigint "market_id"
    t.string "status", default: "draft", null: false
    t.bigint "preferred_stock_location_id"
    t.bigint "channel_id"
    t.bigint "cart_id"
    t.decimal "fee_total", precision: 19, scale: 4
    t.string "coupon_code"
    t.bigint "company_id"
    t.bigint "seller_id"
    t.bigint "order_group_id"
    t.string "po_number"
    t.bigint "cancel_reason_id"
    t.text "cancel_note"
    t.decimal "commission_amount_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "commission_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "commission_total", precision: 19, scale: 4, default: "0.0", null: false
    t.string "created_by_type"
    t.string "approver_type"
    t.string "canceler_type"
    t.jsonb "applied_tax_exemptions"
    t.index ["approver_id"], name: "index_spree_orders_on_approver_id"
    t.index ["approver_type", "approver_id"], name: "index_spree_orders_on_approver_actor"
    t.index ["bill_address_id"], name: "index_spree_orders_on_bill_address_id"
    t.index ["cancel_reason_id"], name: "index_spree_orders_on_cancel_reason_id"
    t.index ["canceler_id"], name: "index_spree_orders_on_canceler_id"
    t.index ["canceler_type", "canceler_id"], name: "index_spree_orders_on_canceler_actor"
    t.index ["cart_id"], name: "index_spree_orders_on_cart_id", unique: true
    t.index ["channel_id"], name: "index_spree_orders_on_channel_id"
    t.index ["company_id"], name: "index_spree_orders_on_company_id"
    t.index ["completed_at"], name: "index_spree_orders_on_completed_at"
    t.index ["confirmation_delivered"], name: "index_spree_orders_on_confirmation_delivered"
    t.index ["considered_risky"], name: "index_spree_orders_on_considered_risky"
    t.index ["coupon_code"], name: "index_spree_orders_on_coupon_code"
    t.index ["created_by_id"], name: "index_spree_orders_on_created_by_id"
    t.index ["created_by_type", "created_by_id"], name: "index_spree_orders_on_created_by_actor"
    t.index ["customer_id", "created_by_id"], name: "index_spree_orders_on_customer_id_and_created_by_id"
    t.index ["fulfillment_status"], name: "index_spree_orders_on_fulfillment_status"
    t.index ["gift_card_id"], name: "index_spree_orders_on_gift_card_id"
    t.index ["market_id"], name: "index_spree_orders_on_market_id"
    t.index ["number"], name: "index_spree_orders_on_number", unique: true
    t.index ["order_group_id"], name: "index_spree_orders_on_order_group_id"
    t.index ["payment_status"], name: "index_spree_orders_on_payment_status"
    t.index ["po_number"], name: "index_spree_orders_on_po_number"
    t.index ["preferred_stock_location_id"], name: "index_spree_orders_on_preferred_stock_location_id"
    t.index ["seller_id"], name: "index_spree_orders_on_seller_id"
    t.index ["ship_address_id"], name: "index_spree_orders_on_ship_address_id"
    t.index ["status"], name: "index_spree_orders_on_status"
    t.index ["store_id", "email"], name: "index_spree_orders_on_store_id_and_email"
    t.index ["store_id"], name: "index_spree_orders_on_store_id"
    t.index ["token"], name: "index_spree_orders_on_token"
  end

  create_table "spree_package_types", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "kind", null: false
    t.decimal "length", precision: 8, scale: 2
    t.decimal "width", precision: 8, scale: 2
    t.decimal "height", precision: 8, scale: 2
    t.string "dimensions_unit"
    t.decimal "weight", precision: 10, scale: 2
    t.decimal "max_weight", precision: 10, scale: 2
    t.string "weight_unit"
    t.boolean "default", default: false, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "seller_id"
    t.index ["seller_id"], name: "index_spree_package_types_on_seller_id"
    t.index ["store_id", "name"], name: "index_spree_package_types_marketplace_name", unique: true, where: "(seller_id IS NULL)"
    t.index ["store_id", "seller_id", "name"], name: "index_spree_package_types_seller_name", unique: true, where: "(seller_id IS NOT NULL)"
    t.index ["store_id", "seller_id"], name: "index_spree_package_types_seller_default", unique: true, where: "((\"default\" = true) AND (seller_id IS NOT NULL))"
    t.index ["store_id"], name: "index_spree_package_types_marketplace_default", unique: true, where: "((\"default\" = true) AND (seller_id IS NULL))"
    t.index ["store_id"], name: "index_spree_package_types_on_store_id"
  end

  create_table "spree_payment_capture_events", force: :cascade do |t|
    t.decimal "amount", precision: 19, scale: 4, default: "0.0"
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_spree_payment_capture_events_on_payment_id"
  end

  create_table "spree_payment_methods", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.text "description"
    t.boolean "active", default: true
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_capture"
    t.integer "position", default: 0
    t.jsonb "metadata"
    t.jsonb "settings"
    t.bigint "store_id"
    t.string "capture_method"
    t.boolean "storefront_visible", default: true, null: false
    t.text "secret_preferences"
    t.jsonb "preferences"
    t.index ["id", "type"], name: "index_spree_payment_methods_on_id_and_type"
    t.index ["store_id"], name: "index_spree_payment_methods_on_store_id"
  end

  create_table "spree_payment_methods_stores", id: false, force: :cascade do |t|
    t.bigint "payment_method_id"
    t.bigint "store_id"
    t.index ["payment_method_id", "store_id"], name: "payment_mentod_id_store_id_unique_index", unique: true
    t.index ["payment_method_id"], name: "index_spree_payment_methods_stores_on_payment_method_id"
    t.index ["store_id"], name: "index_spree_payment_methods_stores_on_store_id"
  end

  create_table "spree_payment_sessions", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "order_id"
    t.bigint "payment_method_id", null: false
    t.bigint "customer_id"
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", null: false
    t.string "status", null: false
    t.string "external_id", null: false
    t.jsonb "external_data"
    t.datetime "expires_at"
    t.string "customer_external_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cart_id"
    t.index ["cart_id"], name: "index_spree_payment_sessions_on_cart_id"
    t.index ["customer_id"], name: "index_spree_payment_sessions_on_customer_id"
    t.index ["deleted_at"], name: "index_spree_payment_sessions_on_deleted_at"
    t.index ["expires_at"], name: "index_spree_payment_sessions_on_expires_at"
    t.index ["external_id"], name: "index_spree_payment_sessions_on_external_id"
    t.index ["order_id", "payment_method_id", "external_id"], name: "idx_payment_sessions_order_method_external", unique: true
    t.index ["order_id"], name: "index_spree_payment_sessions_on_order_id"
    t.index ["payment_method_id"], name: "index_spree_payment_sessions_on_payment_method_id"
    t.index ["status"], name: "index_spree_payment_sessions_on_status"
    t.index ["type"], name: "index_spree_payment_sessions_on_type"
  end

  create_table "spree_payment_setup_sessions", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "payment_method_id", null: false
    t.string "payment_source_type"
    t.bigint "payment_source_id"
    t.string "status", null: false
    t.string "external_id"
    t.string "external_client_secret"
    t.jsonb "external_data"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["customer_id"], name: "index_spree_payment_setup_sessions_on_customer_id"
    t.index ["deleted_at"], name: "index_spree_payment_setup_sessions_on_deleted_at"
    t.index ["external_id", "payment_method_id"], name: "idx_spree_pss_unique_external_id_per_pm", unique: true
    t.index ["payment_method_id"], name: "index_spree_payment_setup_sessions_on_payment_method_id"
    t.index ["payment_source_type", "payment_source_id"], name: "idx_spree_pss_on_payment_source"
    t.index ["status"], name: "index_spree_payment_setup_sessions_on_status"
    t.index ["type"], name: "index_spree_payment_setup_sessions_on_type"
  end

  create_table "spree_payment_sources", force: :cascade do |t|
    t.string "gateway_payment_profile_id"
    t.string "type"
    t.bigint "payment_method_id"
    t.bigint "customer_id"
    t.jsonb "metadata"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "gateway_customer_profile_id"
    t.index ["customer_id"], name: "index_spree_payment_sources_on_customer_id"
    t.index ["payment_method_id"], name: "index_spree_payment_sources_on_payment_method_id"
    t.index ["type", "gateway_payment_profile_id", "payment_method_id"], name: "index_payment_sources_on_type_profile_id_and_payment_method", unique: true
    t.index ["type"], name: "index_spree_payment_sources_on_type"
  end

  create_table "spree_payment_splits", force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.bigint "order_id", null: false
    t.decimal "authorized_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "captured_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "refunded_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "claimed_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.index ["order_id"], name: "index_spree_payment_splits_on_order_id"
    t.index ["payment_id", "order_id"], name: "index_spree_payment_splits_on_payment_id_and_order_id", unique: true
  end

  create_table "spree_payments", force: :cascade do |t|
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.bigint "order_id"
    t.string "source_type"
    t.bigint "source_id"
    t.bigint "payment_method_id"
    t.string "status"
    t.string "response_code"
    t.string "avs_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.string "cvv_response_code"
    t.string "cvv_response_message"
    t.jsonb "metadata"
    t.bigint "cart_id"
    t.bigint "order_group_id"
    t.index ["cart_id"], name: "index_spree_payments_on_cart_id"
    t.index ["created_at"], name: "index_spree_payments_on_created_at"
    t.index ["number"], name: "index_spree_payments_on_number", unique: true
    t.index ["order_group_id"], name: "index_spree_payments_on_order_group_id"
    t.index ["order_id", "payment_method_id", "response_code"], name: "idx_payments_order_method_response_code", unique: true, where: "(response_code IS NOT NULL)"
    t.index ["order_id"], name: "index_spree_payments_on_order_id"
    t.index ["payment_method_id"], name: "index_spree_payments_on_payment_method_id"
    t.index ["source_id", "source_type"], name: "index_spree_payments_on_source_id_and_source_type"
  end

  create_table "spree_paypal_checkout_orders", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "payment_method_id", null: false
    t.string "paypal_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "paypal_id"], name: "index_spree_paypal_checkout_orders_on_order_id_and_paypal_id", unique: true
    t.index ["order_id"], name: "index_spree_paypal_checkout_orders_on_order_id"
    t.index ["payment_method_id"], name: "index_spree_paypal_checkout_orders_on_payment_method_id"
  end

  create_table "spree_policies", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.text "body"
    t.index ["owner_id", "owner_type", "slug"], name: "index_spree_policies_on_owner_id_and_owner_type_and_slug", unique: true
    t.index ["owner_type", "owner_id"], name: "index_spree_policies_on_owner"
  end

  create_table "spree_policy_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "name"
    t.bigint "spree_policy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body"
    t.index ["spree_policy_id", "locale"], name: "index_spree_policy_translations_on_spree_policy_id_and_locale", unique: true
    t.index ["spree_policy_id"], name: "index_spree_policy_translations_on_spree_policy_id"
  end

  create_table "spree_pos_approvals", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "approver_id", null: false
    t.bigint "requester_id", null: false
    t.string "action", null: false
    t.decimal "amount", precision: 19, scale: 4
    t.string "currency"
    t.string "revision", null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "consumed_at"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_approvals_on_branch_id"
    t.index ["store_id", "action"], name: "index_spree_pos_approvals_on_store_id_and_action"
    t.index ["store_id"], name: "index_spree_pos_approvals_on_store_id"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'revoked'::character varying::text, 'consumed'::character varying::text])", name: "chk_spree_pos_approvals_status"
  end

  create_table "spree_pos_areas", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "name", limit: 80, null: false
    t.integer "position", default: 0, null: false
    t.string "status", default: "active", null: false
    t.integer "floor_width", default: 24, null: false
    t.integer "floor_height", default: 16, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "name"], name: "idx_pos_areas_name", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["branch_id"], name: "index_spree_pos_areas_on_branch_id"
    t.index ["store_id"], name: "index_spree_pos_areas_on_store_id"
    t.check_constraint "floor_width >= 4 AND floor_width <= 200 AND floor_height >= 4 AND floor_height <= 200", name: "chk_pos_areas_floor"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'archived'::character varying]::text[])", name: "chk_pos_areas_status"
  end

  create_table "spree_pos_audit_entries", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "actor_id", null: false
    t.string "action", null: false
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_spree_pos_audit_entries_on_store_id"
    t.index ["subject_type", "subject_id"], name: "index_spree_pos_audit_entries_on_subject_type_and_subject_id"
  end

  create_table "spree_pos_bottle_keep_events", force: :cascade do |t|
    t.bigint "bottle_keep_id", null: false
    t.string "kind", null: false
    t.integer "level_before"
    t.integer "level_after", null: false
    t.integer "ml"
    t.bigint "workspace_id"
    t.bigint "approval_id"
    t.bigint "actor_id", null: false
    t.string "note", limit: 200
    t.datetime "created_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_bottle_keep_events_on_actor_id"
    t.index ["approval_id"], name: "index_spree_pos_bottle_keep_events_on_approval_id"
    t.index ["bottle_keep_id"], name: "index_spree_pos_bottle_keep_events_on_bottle_keep_id"
    t.index ["workspace_id"], name: "index_spree_pos_bottle_keep_events_on_workspace_id"
    t.check_constraint "(kind::text = ANY (ARRAY['open'::character varying, 'pour'::character varying, 'adjust'::character varying, 'expire'::character varying, 'return'::character varying]::text[])) AND level_after >= 0 AND level_after <= 100 AND (level_before IS NULL OR level_before >= 0 AND level_before <= 100) AND (ml IS NULL OR ml > 0)", name: "chk_pos_bottle_keep_events_values"
  end

  create_table "spree_pos_bottle_keeps", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "customer_profile_id"
    t.string "guest_name", limit: 120
    t.string "phone", limit: 32
    t.bigint "variant_id", null: false
    t.string "code", limit: 16, null: false
    t.integer "level_percent", null: false
    t.date "kept_on", null: false
    t.date "expires_on", null: false
    t.bigint "source_order_id"
    t.bigint "source_sale_line_id"
    t.string "note", limit: 200
    t.string "status", default: "kept", null: false
    t.integer "revision", default: 0, null: false
    t.bigint "created_by_id", null: false
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "code"], name: "idx_pos_bottle_keeps_code", unique: true
    t.index ["branch_id", "phone"], name: "idx_pos_bottle_keeps_phone"
    t.index ["branch_id", "status", "expires_on"], name: "idx_pos_bottle_keeps_expiry"
    t.index ["created_by_id"], name: "index_spree_pos_bottle_keeps_on_created_by_id"
    t.index ["customer_profile_id"], name: "index_spree_pos_bottle_keeps_on_customer_profile_id"
    t.index ["source_order_id"], name: "index_spree_pos_bottle_keeps_on_source_order_id"
    t.index ["source_sale_line_id"], name: "index_spree_pos_bottle_keeps_on_source_sale_line_id"
    t.index ["variant_id"], name: "index_spree_pos_bottle_keeps_on_variant_id"
    t.check_constraint "(status::text = ANY (ARRAY['kept'::character varying, 'finished'::character varying, 'expired'::character varying, 'returned'::character varying]::text[])) AND level_percent >= 0 AND level_percent <= 100 AND expires_on >= kept_on", name: "chk_pos_bottle_keeps_values"
  end

  create_table "spree_pos_branch_label_formats", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "label_format_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "label_format_id"], name: "idx_pos_branch_label_formats_unique", unique: true
    t.index ["label_format_id"], name: "index_spree_pos_branch_label_formats_on_label_format_id"
    t.index ["store_id"], name: "index_spree_pos_branch_label_formats_on_store_id"
  end

  create_table "spree_pos_branch_modules", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "module_key", limit: 64, null: false
    t.boolean "enabled", null: false
    t.string "reason", limit: 200
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "module_key"], name: "idx_pos_branch_modules_key", unique: true
    t.index ["store_id"], name: "index_spree_pos_branch_modules_on_store_id"
  end

  create_table "spree_pos_branch_payment_methods", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "pos_payment_method_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "pos_payment_method_id"], name: "idx_pos_branch_payment_methods_unique", unique: true
    t.index ["pos_payment_method_id"], name: "idx_on_pos_payment_method_id_1142b3933e"
    t.index ["store_id"], name: "index_spree_pos_branch_payment_methods_on_store_id"
  end

  create_table "spree_pos_branch_products", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "product_id"], name: "idx_pos_branch_product_unique", unique: true
    t.index ["branch_id"], name: "index_spree_pos_branch_products_on_branch_id"
    t.index ["product_id"], name: "index_spree_pos_branch_products_on_product_id"
  end

  create_table "spree_pos_branch_receipt_templates", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "document_type", null: false
    t.bigint "receipt_template_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "document_type"], name: "idx_pos_branch_receipt_templates_type", unique: true
    t.index ["receipt_template_id"], name: "idx_on_receipt_template_id_663f736c87"
    t.index ["store_id"], name: "index_spree_pos_branch_receipt_templates_on_store_id"
  end

  create_table "spree_pos_branches", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "receiving_stock_location_id"
    t.string "name", null: false
    t.string "code", null: false
    t.string "timezone", null: false
    t.jsonb "receiving_config", default: {}, null: false
    t.string "status", default: "active", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "return_window_days"
    t.decimal "variance_threshold", precision: 19, scale: 4
    t.string "lot_selection", limit: 16, default: "fefo", null: false
    t.bigint "adjustment_approval_threshold"
    t.integer "display_freshness_ttl_seconds"
    t.string "profile_key", limit: 40, default: "khac", null: false
    t.integer "profile_version", default: 1, null: false
    t.time "business_day_cutoff", default: "2000-01-01 04:00:00", null: false
    t.integer "staff_session_idle_minutes", default: 30, null: false
    t.string "kitchen_send_trigger", default: "on_complete", null: false
    t.bigint "cup_label_printer_id"
    t.jsonb "cup_label_settings", default: {}, null: false
    t.bigint "table_register_id"
    t.decimal "service_charge_rate", precision: 5, scale: 2
    t.jsonb "service_charge_applies_to", default: ["dine_in"], null: false
    t.bigint "service_charge_tax_category_id"
    t.jsonb "void_reasons", default: ["khach_doi_y", "het_mon", "nhap_nham", "lam_hong"], null: false
    t.integer "reservation_grace_minutes", default: 15, null: false
    t.integer "reservation_duration_minutes", default: 120, null: false
    t.bigint "reservation_fee_product_id"
    t.integer "bottle_keep_days", default: 90, null: false
    t.boolean "tips_as_revenue", default: false, null: false
    t.index ["cup_label_printer_id"], name: "index_spree_pos_branches_on_cup_label_printer_id"
    t.index ["service_charge_tax_category_id"], name: "index_spree_pos_branches_on_service_charge_tax_category_id"
    t.index ["stock_location_id"], name: "index_spree_pos_branches_on_stock_location_id"
    t.index ["store_id", "code"], name: "index_spree_pos_branches_on_store_id_and_code", unique: true
    t.index ["store_id"], name: "index_spree_pos_branches_on_store_id"
    t.index ["table_register_id"], name: "index_spree_pos_branches_on_table_register_id"
    t.check_constraint "adjustment_approval_threshold IS NULL OR adjustment_approval_threshold >= 0", name: "chk_pos_branches_adjustment_threshold"
    t.check_constraint "bottle_keep_days >= 1 AND bottle_keep_days <= 3650", name: "chk_pos_branches_bottle_keep_days"
    t.check_constraint "display_freshness_ttl_seconds IS NULL OR display_freshness_ttl_seconds >= 5 AND display_freshness_ttl_seconds <= 120", name: "chk_pos_branches_display_freshness"
    t.check_constraint "kitchen_send_trigger::text = ANY (ARRAY['on_complete'::character varying, 'manual'::character varying]::text[])", name: "chk_pos_branches_kitchen_send_trigger"
    t.check_constraint "lot_selection::text = ANY (ARRAY['fefo'::character varying::text, 'cashier_pick'::character varying::text])", name: "chk_pos_branches_lot_selection"
    t.check_constraint "profile_version >= 1", name: "chk_pos_branches_profile_version"
    t.check_constraint "return_window_days IS NULL OR return_window_days >= 0 AND return_window_days <= 3650", name: "chk_pos_branches_return_window"
    t.check_constraint "service_charge_rate IS NULL OR service_charge_rate > 0::numeric AND service_charge_rate <= 50::numeric", name: "chk_pos_branches_service_charge_rate"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_spree_pos_branches_status"
    t.check_constraint "variance_threshold IS NULL OR variance_threshold >= 0::numeric", name: "chk_pos_branches_variance_threshold"
  end

  create_table "spree_pos_buffet_tier_items", force: :cascade do |t|
    t.bigint "buffet_tier_id", null: false
    t.bigint "product_id", null: false
    t.integer "max_per_round"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buffet_tier_id", "product_id"], name: "idx_pos_buffet_tier_items_pair", unique: true
    t.index ["product_id"], name: "index_spree_pos_buffet_tier_items_on_product_id"
    t.check_constraint "max_per_round IS NULL OR max_per_round >= 1 AND max_per_round <= 99", name: "chk_pos_buffet_tier_items_max"
  end

  create_table "spree_pos_buffet_tiers", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "name", null: false
    t.bigint "product_id", null: false
    t.integer "duration_minutes", default: 90, null: false
    t.integer "round_item_limit"
    t.integer "round_interval_minutes", default: 0, null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_buffet_tiers_on_branch_id"
    t.index ["product_id"], name: "index_spree_pos_buffet_tiers_on_product_id"
    t.check_constraint "(status::text = ANY (ARRAY['active'::character varying, 'archived'::character varying]::text[])) AND duration_minutes >= 1 AND duration_minutes <= 1440 AND round_interval_minutes >= 0 AND round_interval_minutes <= 240 AND (round_item_limit IS NULL OR round_item_limit >= 1 AND round_item_limit <= 99)", name: "chk_pos_buffet_tiers_values"
  end

  create_table "spree_pos_cash_movement_requests", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "shift_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "confirmer_id"
    t.bigint "cash_movement_id"
    t.string "kind", limit: 16, null: false
    t.string "status", limit: 16, default: "requested", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.string "reason", limit: 200, null: false
    t.string "evidence_reference", limit: 120, null: false
    t.string "resolution_note", limit: 200
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "status"], name: "idx_pos_cash_movement_requests_branch"
    t.index ["cash_movement_id"], name: "index_spree_pos_cash_movement_requests_on_cash_movement_id", unique: true, where: "(cash_movement_id IS NOT NULL)"
    t.index ["requester_id"], name: "index_spree_pos_cash_movement_requests_on_requester_id"
    t.index ["shift_id"], name: "index_spree_pos_cash_movement_requests_on_shift_id"
    t.index ["store_id"], name: "index_spree_pos_cash_movement_requests_on_store_id"
    t.check_constraint "(status::text = 'confirmed'::text) = (cash_movement_id IS NOT NULL)", name: "chk_pos_cash_movement_requests_movement"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_cash_movement_requests_amount"
    t.check_constraint "kind::text = ANY (ARRAY['cash_out'::character varying::text, 'safe_drop'::character varying::text])", name: "chk_pos_cash_movement_requests_kind"
    t.check_constraint "status::text = ANY (ARRAY['requested'::character varying::text, 'confirmed'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_cash_movement_requests_status"
  end

  create_table "spree_pos_cash_movements", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "shift_id", null: false
    t.bigint "received_funds_id"
    t.bigint "liability_payout_id"
    t.bigint "actor_id", null: false
    t.string "kind", limit: 32, null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.string "source_type", limit: 64, null: false
    t.bigint "source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "refund_request_id"
    t.string "reason", limit: 200
    t.string "evidence_reference", limit: 120
    t.bigint "cash_reconciliation_id"
    t.index ["actor_id"], name: "index_spree_pos_cash_movements_on_actor_id"
    t.index ["branch_id"], name: "index_spree_pos_cash_movements_on_branch_id"
    t.index ["cash_reconciliation_id"], name: "index_spree_pos_cash_movements_on_cash_reconciliation_id", unique: true, where: "(cash_reconciliation_id IS NOT NULL)"
    t.index ["liability_payout_id"], name: "index_spree_pos_cash_movements_on_liability_payout_id"
    t.index ["received_funds_id"], name: "index_spree_pos_cash_movements_on_received_funds_id"
    t.index ["refund_request_id"], name: "index_spree_pos_cash_movements_on_refund_request_id"
    t.index ["register_id"], name: "index_spree_pos_cash_movements_on_register_id"
    t.index ["shift_id", "kind"], name: "idx_pos_cash_movements_shift"
    t.index ["shift_id"], name: "index_spree_pos_cash_movements_on_shift_id"
    t.index ["source_type", "source_id", "kind"], name: "idx_pos_cash_movements_source", unique: true
    t.index ["store_id"], name: "index_spree_pos_cash_movements_on_store_id"
    t.check_constraint "(kind::text <> ALL (ARRAY['cash_in'::character varying::text, 'cash_out'::character varying::text, 'safe_drop'::character varying::text])) OR reason IS NOT NULL", name: "chk_pos_cash_movements_reason"
    t.check_constraint "(kind::text = ANY (ARRAY['receipt'::character varying::text, 'cash_in'::character varying::text, 'reconciliation_inflow'::character varying::text])) AND amount > 0::numeric OR (kind::text = ANY (ARRAY['payout'::character varying::text, 'cash_out'::character varying::text, 'safe_drop'::character varying::text])) AND amount < 0::numeric", name: "chk_pos_cash_movements_sign"
    t.check_constraint "kind::text = ANY (ARRAY['receipt'::character varying::text, 'payout'::character varying::text, 'cash_in'::character varying::text, 'cash_out'::character varying::text, 'safe_drop'::character varying::text, 'reconciliation_inflow'::character varying::text])", name: "chk_pos_cash_movements_kind"
  end

  create_table "spree_pos_cash_reconciliations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "shift_closure_id"
    t.bigint "received_funds_id"
    t.bigint "target_shift_id"
    t.bigint "actor_id", null: false
    t.string "outcome", limit: 32, null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.string "reason", limit: 200, null: false
    t.string "custody_reference", limit: 120
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_cash_reconciliations_on_actor_id"
    t.index ["branch_id"], name: "index_spree_pos_cash_reconciliations_on_branch_id"
    t.index ["received_funds_id"], name: "index_spree_pos_cash_reconciliations_on_received_funds_id", unique: true, where: "(received_funds_id IS NOT NULL)"
    t.index ["shift_closure_id"], name: "index_spree_pos_cash_reconciliations_on_shift_closure_id"
    t.index ["store_id"], name: "index_spree_pos_cash_reconciliations_on_store_id"
    t.index ["target_shift_id"], name: "index_spree_pos_cash_reconciliations_on_target_shift_id"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_cash_reconciliations_amount"
    t.check_constraint "outcome::text = 'new_physical_inflow'::text AND target_shift_id IS NOT NULL OR outcome::text = 'in_opening_float'::text OR (outcome::text = ANY (ARRAY['safe'::character varying::text, 'handed_over'::character varying::text])) AND target_shift_id IS NULL", name: "chk_pos_cash_reconciliations_target"
    t.check_constraint "outcome::text = ANY (ARRAY['in_opening_float'::character varying::text, 'safe'::character varying::text, 'handed_over'::character varying::text, 'new_physical_inflow'::character varying::text])", name: "chk_pos_cash_reconciliations_outcome"
    t.check_constraint "shift_closure_id IS NOT NULL OR received_funds_id IS NOT NULL", name: "chk_pos_cash_reconciliations_source"
  end

  create_table "spree_pos_collections", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "credit_account_id", null: false
    t.bigint "received_funds_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "actor_id", null: false
    t.string "note", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_collections_on_actor_id"
    t.index ["branch_id"], name: "index_spree_pos_collections_on_branch_id"
    t.index ["credit_account_id"], name: "index_spree_pos_collections_on_credit_account_id"
    t.index ["received_funds_id"], name: "index_spree_pos_collections_on_received_funds_id", unique: true
    t.index ["store_id"], name: "index_spree_pos_collections_on_store_id"
  end

  create_table "spree_pos_combo_components", force: :cascade do |t|
    t.bigint "menu_item_id", null: false
    t.bigint "variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id", "variant_id"], name: "idx_pos_combo_components_pair", unique: true
    t.index ["variant_id"], name: "index_spree_pos_combo_components_on_variant_id"
    t.check_constraint "quantity > 0", name: "chk_pos_combo_components_quantity"
  end

  create_table "spree_pos_command_receipts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "workspace_id"
    t.bigint "actor_id", null: false
    t.string "idempotency_key", null: false
    t.string "digest", null: false
    t.jsonb "result", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "actor_id", "idempotency_key"], name: "idx_spree_pos_command_receipts_actor_key", unique: true
    t.index ["store_id"], name: "index_spree_pos_command_receipts_on_store_id"
    t.index ["workspace_id"], name: "index_spree_pos_command_receipts_on_workspace_id"
  end

  create_table "spree_pos_course_labels", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.integer "position", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "position"], name: "idx_pos_course_labels_position", unique: true
    t.check_constraint "\"position\" >= 1 AND \"position\" <= 9", name: "chk_pos_course_labels_position"
  end

  create_table "spree_pos_credit_accounts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "customer_profile_id", null: false
    t.bigint "branch_id", null: false
    t.decimal "credit_limit", precision: 19, scale: 4, null: false
    t.integer "due_days", null: false
    t.string "status", limit: 16, default: "active", null: false
    t.string "currency", limit: 16, null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_reminded_at"
    t.index ["branch_id"], name: "index_spree_pos_credit_accounts_on_branch_id"
    t.index ["customer_profile_id"], name: "index_spree_pos_credit_accounts_on_customer_profile_id"
    t.index ["store_id", "customer_profile_id", "currency"], name: "idx_pos_credit_accounts_customer", unique: true
    t.index ["store_id"], name: "index_spree_pos_credit_accounts_on_store_id"
    t.index ["updated_by_id"], name: "index_spree_pos_credit_accounts_on_updated_by_id"
    t.check_constraint "credit_limit >= 0::numeric AND due_days >= 0", name: "chk_pos_credit_accounts_terms"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'suspended'::character varying::text])", name: "chk_pos_credit_accounts_status"
  end

  create_table "spree_pos_credit_requests", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "customer_profile_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "decided_by_id"
    t.bigint "credit_reservation_id"
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.integer "workspace_revision", null: false
    t.string "status", limit: 16, default: "pending", null: false
    t.string "reason", limit: 200
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "status"], name: "idx_pos_credit_requests_branch"
    t.index ["branch_id"], name: "index_spree_pos_credit_requests_on_branch_id"
    t.index ["credit_reservation_id"], name: "index_spree_pos_credit_requests_on_credit_reservation_id"
    t.index ["customer_profile_id"], name: "index_spree_pos_credit_requests_on_customer_profile_id"
    t.index ["decided_by_id"], name: "index_spree_pos_credit_requests_on_decided_by_id"
    t.index ["requester_id"], name: "index_spree_pos_credit_requests_on_requester_id"
    t.index ["store_id"], name: "index_spree_pos_credit_requests_on_store_id"
    t.index ["workspace_id", "workspace_revision"], name: "idx_pos_credit_requests_revision", unique: true
    t.index ["workspace_id"], name: "index_spree_pos_credit_requests_on_workspace_id"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_credit_requests_amount"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text, 'stale'::character varying::text])", name: "chk_pos_credit_requests_status"
  end

  create_table "spree_pos_credit_reservations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "credit_account_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "approval_id", null: false
    t.bigint "customer_profile_id", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.integer "workspace_revision", null: false
    t.string "status", limit: 16, default: "active", null: false
    t.string "released_reason", limit: 64
    t.datetime "committed_at"
    t.datetime "released_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_id"], name: "index_spree_pos_credit_reservations_on_approval_id", unique: true
    t.index ["credit_account_id", "status"], name: "idx_pos_credit_reservations_account"
    t.index ["credit_account_id"], name: "index_spree_pos_credit_reservations_on_credit_account_id"
    t.index ["customer_profile_id"], name: "index_spree_pos_credit_reservations_on_customer_profile_id"
    t.index ["store_id"], name: "index_spree_pos_credit_reservations_on_store_id"
    t.index ["workspace_id"], name: "idx_pos_credit_reservations_one_active", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["workspace_id"], name: "index_spree_pos_credit_reservations_on_workspace_id"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_credit_reservations_amount"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'committed'::character varying::text, 'released'::character varying::text])", name: "chk_pos_credit_reservations_status"
  end

  create_table "spree_pos_customers", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "customer_id"
    t.bigint "created_by_id", null: false
    t.string "name", limit: 120, null: false
    t.string "phone", limit: 32
    t.string "normalized_phone", limit: 32
    t.string "email", limit: 254
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address", limit: 255
    t.index ["customer_id"], name: "index_spree_pos_customers_on_customer_id"
    t.index ["store_id", "email"], name: "idx_pos_customers_store_email"
    t.index ["store_id", "normalized_phone"], name: "idx_pos_customers_store_phone"
    t.index ["store_id"], name: "index_spree_pos_customers_on_store_id"
  end

  create_table "spree_pos_deliveries", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "order_id", null: false
    t.bigint "fee_id"
    t.string "status", limit: 20, default: "pending", null: false
    t.string "deliverer", limit: 80
    t.decimal "fee_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "delivered_at"
    t.bigint "delivered_by_id"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "status", "delivered_at"], name: "idx_pos_deliveries_branch_status"
    t.index ["order_id"], name: "index_spree_pos_deliveries_on_order_id", unique: true
    t.index ["workspace_id"], name: "index_spree_pos_deliveries_on_workspace_id", unique: true
    t.check_constraint "(status::text = 'delivered'::text) = (delivered_at IS NOT NULL)", name: "chk_pos_deliveries_delivered_at"
    t.check_constraint "fee_amount >= 0::numeric", name: "chk_pos_deliveries_fee"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'delivered'::character varying::text])", name: "chk_pos_deliveries_status"
  end

  create_table "spree_pos_device_pairings", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "device_id"
    t.string "mode", null: false
    t.string "code_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "consumed_at"
    t.bigint "created_by_id", null: false
    t.jsonb "attrs", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_device_pairings_on_branch_id"
    t.index ["code_digest"], name: "index_spree_pos_device_pairings_on_code_digest", unique: true
    t.index ["device_id"], name: "index_spree_pos_device_pairings_on_device_id"
    t.index ["store_id"], name: "index_spree_pos_device_pairings_on_store_id"
    t.check_constraint "mode::text = ANY (ARRAY['waiter'::character varying, 'kds'::character varying, 'expo'::character varying, 'kiosk'::character varying, 'print_station'::character varying, 'owner'::character varying, 'bridge'::character varying]::text[])", name: "chk_pos_device_pairings_mode"
  end

  create_table "spree_pos_device_pin_failures", force: :cascade do |t|
    t.bigint "device_id", null: false
    t.bigint "staff_membership_id", null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id", "staff_membership_id", "failed_at"], name: "idx_pos_device_pin_failures_lookup"
    t.index ["device_id"], name: "index_spree_pos_device_pin_failures_on_device_id"
    t.index ["staff_membership_id"], name: "index_spree_pos_device_pin_failures_on_staff_membership_id"
  end

  create_table "spree_pos_device_staff_sessions", force: :cascade do |t|
    t.bigint "device_id", null: false
    t.bigint "staff_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_active_at", null: false
    t.datetime "ended_at"
    t.string "end_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_spree_pos_device_staff_sessions_on_device_id"
    t.index ["token_digest"], name: "index_spree_pos_device_staff_sessions_on_token_digest", unique: true
  end

  create_table "spree_pos_device_table_pins", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "device_id", null: false
    t.bigint "resource_id", null: false
    t.bigint "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id", "resource_id"], name: "idx_pos_device_table_pins_pair", unique: true
    t.index ["resource_id"], name: "index_spree_pos_device_table_pins_on_resource_id"
    t.index ["staff_id"], name: "index_spree_pos_device_table_pins_on_staff_id"
  end

  create_table "spree_pos_devices", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "kitchen_station_id"
    t.string "name", null: false
    t.string "mode", null: false
    t.string "platform", null: false
    t.string "app_version"
    t.string "token_digest", null: false
    t.integer "generation", default: 0, null: false
    t.string "status", default: "active", null: false
    t.datetime "last_seen_at"
    t.bigint "paired_by_id"
    t.bigint "revoked_by_id"
    t.datetime "revoked_at"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_devices_on_branch_id"
    t.index ["kitchen_station_id"], name: "index_spree_pos_devices_on_kitchen_station_id"
    t.index ["register_id"], name: "index_spree_pos_devices_on_register_id"
    t.index ["store_id"], name: "index_spree_pos_devices_on_store_id"
    t.index ["token_digest"], name: "index_spree_pos_devices_on_token_digest", unique: true
    t.check_constraint "mode::text = ANY (ARRAY['waiter'::character varying, 'kds'::character varying, 'expo'::character varying, 'kiosk'::character varying, 'print_station'::character varying, 'owner'::character varying, 'bridge'::character varying]::text[])", name: "chk_pos_devices_mode"
    t.check_constraint "platform::text = ANY (ARRAY['android'::character varying, 'ios'::character varying, 'web'::character varying]::text[])", name: "chk_pos_devices_platform"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'revoked'::character varying]::text[])", name: "chk_pos_devices_status"
  end

  create_table "spree_pos_discount_allocations", force: :cascade do |t|
    t.bigint "discount_intent_id"
    t.bigint "discount_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "line_discount_intent_id"
    t.index ["discount_id"], name: "index_spree_pos_discount_allocations_on_discount_id", unique: true
    t.index ["discount_intent_id"], name: "index_spree_pos_discount_allocations_on_discount_intent_id"
    t.index ["line_discount_intent_id"], name: "idx_on_line_discount_intent_id_ec9cbc9e83"
  end

  create_table "spree_pos_discount_intents", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "actor_id", null: false
    t.string "value_type", null: false
    t.string "value", limit: 64, null: false
    t.string "reason", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id"], name: "index_spree_pos_discount_intents_on_workspace_id", unique: true
    t.check_constraint "value_type::text = ANY (ARRAY['flat'::character varying::text, 'percent'::character varying::text])", name: "chk_pos_discount_intent_type"
  end

  create_table "spree_pos_display_pairings", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "display_session_id", null: false
    t.bigint "created_by_id", null: false
    t.string "code_digest", limit: 64, null: false
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_digest"], name: "idx_pos_display_pairings_code", unique: true
    t.index ["display_session_id"], name: "index_spree_pos_display_pairings_on_display_session_id"
  end

  create_table "spree_pos_display_sessions", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "shift_id", null: false
    t.bigint "staff_id", null: false
    t.string "token_digest", limit: 64, null: false
    t.datetime "token_expires_at", null: false
    t.integer "generation", default: 1, null: false
    t.bigint "pinned_workspace_id"
    t.bigint "pinned_tender_attempt_id"
    t.datetime "pinned_at"
    t.bigint "state_sequence", default: 0, null: false
    t.datetime "last_seen_at"
    t.integer "acked_generation"
    t.datetime "acked_at"
    t.datetime "revoked_at"
    t.string "revoke_reason", limit: 32
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mode", limit: 16, default: "order", null: false
    t.index ["shift_id"], name: "idx_pos_display_sessions_live_shift", unique: true, where: "(revoked_at IS NULL)"
    t.index ["token_digest"], name: "idx_pos_display_sessions_token", unique: true
    t.check_constraint "generation >= 1", name: "chk_pos_display_sessions_generation"
    t.check_constraint "mode::text = ANY (ARRAY['order'::character varying, 'call_board'::character varying]::text[])", name: "chk_pos_display_sessions_mode"
    t.check_constraint "pinned_tender_attempt_id IS NULL OR pinned_workspace_id IS NOT NULL", name: "chk_pos_display_sessions_attempt_pin"
  end

  create_table "spree_pos_einvoice_settings", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id"
    t.string "provider", limit: 40, null: false
    t.text "credentials"
    t.string "template_code", limit: 1
    t.string "symbol", limit: 6
    t.string "seller_name", limit: 400
    t.string "seller_tax_code", limit: 14
    t.string "seller_address", limit: 400
    t.string "consumer_label", limit: 100
    t.string "lookup_url", limit: 300
    t.integer "buyer_link_hours"
    t.string "status", limit: 16, default: "active", null: false
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_einvoice_settings_on_branch_id"
    t.index ["changed_by_id"], name: "index_spree_pos_einvoice_settings_on_changed_by_id"
    t.index ["store_id", "branch_id"], name: "idx_pos_einvoice_settings_branch", unique: true, where: "(branch_id IS NOT NULL)"
    t.index ["store_id"], name: "idx_pos_einvoice_settings_store", unique: true, where: "(branch_id IS NULL)"
    t.index ["store_id"], name: "index_spree_pos_einvoice_settings_on_store_id"
    t.check_constraint "buyer_link_hours IS NULL OR buyer_link_hours >= 1 AND buyer_link_hours <= 720", name: "chk_pos_einvoice_settings_link_hours"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'disabled'::character varying]::text[])", name: "chk_pos_einvoice_settings_status"
  end

  create_table "spree_pos_einvoices", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "order_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "original_einvoice_id"
    t.bigint "created_by_id", null: false
    t.string "relation", limit: 16, default: "original", null: false
    t.string "invoice_type", limit: 16, null: false
    t.string "provider", limit: 40
    t.string "status", limit: 16, default: "pending", null: false
    t.jsonb "buyer", default: {}, null: false
    t.jsonb "seller", default: {}, null: false
    t.jsonb "lines_snapshot", default: [], null: false
    t.jsonb "totals_snapshot", default: {}, null: false
    t.string "payment_method", limit: 16
    t.string "currency", limit: 3, null: false
    t.string "template_code", limit: 1
    t.string "symbol", limit: 6
    t.string "number", limit: 16
    t.string "provider_ref", limit: 100
    t.string "cqt_code", limit: 40
    t.string "lookup_code", limit: 64
    t.string "lookup_url", limit: 300
    t.datetime "issued_at"
    t.datetime "signed_at"
    t.datetime "sent_to_cqt_at"
    t.integer "attempts", default: 0, null: false
    t.datetime "next_attempt_at"
    t.text "last_error"
    t.datetime "buyer_token_expires_at"
    t.datetime "buyer_submitted_at"
    t.datetime "canceled_at"
    t.string "cancel_reason", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_einvoices_on_branch_id"
    t.index ["created_by_id"], name: "index_spree_pos_einvoices_on_created_by_id"
    t.index ["order_id"], name: "idx_pos_einvoices_original_order", unique: true, where: "((relation)::text = 'original'::text)"
    t.index ["order_id"], name: "index_spree_pos_einvoices_on_order_id"
    t.index ["original_einvoice_id"], name: "index_spree_pos_einvoices_on_original_einvoice_id"
    t.index ["store_id", "status", "next_attempt_at"], name: "idx_pos_einvoices_queue"
    t.index ["store_id"], name: "index_spree_pos_einvoices_on_store_id"
    t.index ["workspace_id"], name: "index_spree_pos_einvoices_on_workspace_id"
    t.check_constraint "(relation::text = 'original'::text) = (original_einvoice_id IS NULL)", name: "chk_pos_einvoices_original"
    t.check_constraint "invoice_type::text = ANY (ARRAY['cash_register'::character varying, 'coded'::character varying]::text[])", name: "chk_pos_einvoices_type"
    t.check_constraint "relation::text = ANY (ARRAY['original'::character varying, 'replacement'::character varying]::text[])", name: "chk_pos_einvoices_relation"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'issuing'::character varying, 'issued'::character varying, 'failed'::character varying, 'canceled'::character varying, 'replaced'::character varying, 'adjusted'::character varying]::text[])", name: "chk_pos_einvoices_status"
  end

  create_table "spree_pos_exchange_operations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "return_operation_id", null: false
    t.bigint "replacement_workspace_id", null: false
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_exchange_operations_on_actor_id"
    t.index ["branch_id"], name: "index_spree_pos_exchange_operations_on_branch_id"
    t.index ["replacement_workspace_id"], name: "idx_on_replacement_workspace_id_5bdb19a854", unique: true
    t.index ["return_operation_id"], name: "index_spree_pos_exchange_operations_on_return_operation_id", unique: true
    t.index ["store_id"], name: "index_spree_pos_exchange_operations_on_store_id"
  end

  create_table "spree_pos_export_requests", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "requester_id", null: false
    t.string "report_type", limit: 32, null: false
    t.jsonb "filters", default: {}, null: false
    t.string "status", limit: 16, default: "queued", null: false
    t.integer "row_count"
    t.string "error_message", limit: 200
    t.datetime "expires_at", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "full_scope", default: false, null: false
    t.index ["branch_id"], name: "index_spree_pos_export_requests_on_branch_id"
    t.index ["requester_id"], name: "index_spree_pos_export_requests_on_requester_id"
    t.index ["status", "expires_at"], name: "idx_pos_export_requests_expiry"
    t.index ["store_id"], name: "index_spree_pos_export_requests_on_store_id"
    t.check_constraint "report_type::text = ANY (ARRAY['sales'::character varying, 'receipts'::character varying, 'cashbook'::character varying, 'receivables'::character varying, 'closures'::character varying, 'ingredient_usage'::character varying, 'menu_margin'::character varying, 'platforms'::character varying]::text[])", name: "chk_pos_export_requests_report"
    t.check_constraint "status::text = ANY (ARRAY['queued'::character varying::text, 'processing'::character varying::text, 'ready'::character varying::text, 'failed'::character varying::text, 'expired'::character varying::text])", name: "chk_pos_export_requests_status"
  end

  create_table "spree_pos_feature_flags", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id"
    t.string "feature", null: false
    t.boolean "enabled", null: false
    t.bigint "changed_by_id", null: false
    t.string "reason", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "feature"], name: "idx_pos_feature_flags_branch_override", unique: true, where: "(branch_id IS NOT NULL)"
    t.index ["branch_id"], name: "index_spree_pos_feature_flags_on_branch_id"
    t.index ["store_id", "feature"], name: "idx_pos_feature_flags_store_default", unique: true, where: "(branch_id IS NULL)"
    t.index ["store_id"], name: "index_spree_pos_feature_flags_on_store_id"
    t.check_constraint "char_length(reason::text) >= 1 AND char_length(reason::text) <= 200", name: "chk_pos_feature_flags_reason"
    t.check_constraint "feature::text = ANY (ARRAY['credit'::character varying::text, 'returns'::character varying::text, 'refunds'::character varying::text, 'exchanges'::character varying::text, 'traceability'::character varying::text, 'customer_display'::character varying::text, 'cash_moves'::character varying::text, 'exports'::character varying::text, 'vietqr'::character varying::text, 'edit_lease'::character varying::text, 'quick_credit'::character varying::text, 'delivery'::character varying::text])", name: "chk_pos_feature_flags_feature"
  end

  create_table "spree_pos_funds_allocations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "received_funds_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "order_id", null: false
    t.bigint "payment_id"
    t.string "status", default: "active", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.datetime "reversed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "collection_id"
    t.index ["collection_id"], name: "index_spree_pos_funds_allocations_on_collection_id"
    t.index ["payment_id"], name: "idx_pos_funds_allocations_payment", unique: true, where: "(payment_id IS NOT NULL)"
    t.index ["received_funds_id", "status"], name: "idx_pos_funds_allocations_funds"
    t.index ["received_funds_id"], name: "index_spree_pos_funds_allocations_on_received_funds_id"
    t.index ["store_id"], name: "index_spree_pos_funds_allocations_on_store_id"
    t.index ["workspace_id", "status"], name: "idx_pos_funds_allocations_workspace"
    t.index ["workspace_id"], name: "index_spree_pos_funds_allocations_on_workspace_id"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_funds_allocations_amount"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'reversed'::character varying::text])", name: "chk_pos_funds_allocations_status"
  end

  create_table "spree_pos_inventory_adjustments", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "applier_id"
    t.bigint "approval_id"
    t.string "status", limit: 32, default: "pending_approval", null: false
    t.string "reason", limit: 200, null: false
    t.jsonb "lines", default: [], null: false
    t.bigint "delta", default: 0, null: false
    t.boolean "requires_approval", default: false, null: false
    t.integer "revision", default: 1, null: false
    t.datetime "applied_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applier_id"], name: "index_spree_pos_inventory_adjustments_on_applier_id"
    t.index ["approval_id"], name: "index_spree_pos_inventory_adjustments_on_approval_id"
    t.index ["branch_id", "status"], name: "idx_pos_inventory_adjustments_branch"
    t.index ["branch_id"], name: "index_spree_pos_inventory_adjustments_on_branch_id"
    t.index ["requester_id"], name: "index_spree_pos_inventory_adjustments_on_requester_id"
    t.index ["store_id"], name: "index_spree_pos_inventory_adjustments_on_store_id"
    t.index ["variant_id"], name: "index_spree_pos_inventory_adjustments_on_variant_id"
    t.check_constraint "status::text = ANY (ARRAY['pending_approval'::character varying::text, 'applied'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_inventory_adjustments_status"
  end

  create_table "spree_pos_inventory_lots", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "source_lot_id"
    t.bigint "quarantined_by_id"
    t.string "lot_code", limit: 64, null: false
    t.date "expiry_on"
    t.string "status", limit: 16, default: "active", null: false
    t.bigint "received_quantity", default: 0, null: false
    t.bigint "on_hand", default: 0, null: false
    t.bigint "quarantined_quantity", default: 0, null: false
    t.string "quarantine_reason", limit: 200
    t.datetime "quarantined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quarantined_by_id"], name: "index_spree_pos_inventory_lots_on_quarantined_by_id"
    t.index ["source_lot_id"], name: "index_spree_pos_inventory_lots_on_source_lot_id"
    t.index ["stock_location_id", "variant_id", "lot_code"], name: "idx_pos_inventory_lots_code", unique: true
    t.index ["store_id", "lot_code"], name: "idx_pos_inventory_lots_recall"
    t.index ["store_id"], name: "index_spree_pos_inventory_lots_on_store_id"
    t.index ["variant_id", "stock_location_id", "status", "expiry_on"], name: "idx_pos_inventory_lots_fefo"
    t.check_constraint "on_hand >= 0 AND quarantined_quantity >= 0 AND received_quantity >= 0", name: "chk_pos_inventory_lots_quantities"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'quarantined'::character varying::text, 'expired'::character varying::text])", name: "chk_pos_inventory_lots_status"
  end

  create_table "spree_pos_kitchen_sends", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.integer "sequence", null: false
    t.bigint "staff_id"
    t.bigint "device_id"
    t.string "send_key", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_spree_pos_kitchen_sends_on_device_id"
    t.index ["staff_id"], name: "index_spree_pos_kitchen_sends_on_staff_id"
    t.index ["workspace_id", "send_key"], name: "idx_pos_kitchen_sends_key", unique: true
    t.index ["workspace_id", "sequence"], name: "idx_pos_kitchen_sends_sequence", unique: true
    t.check_constraint "sequence > 0", name: "chk_pos_kitchen_sends_sequence"
  end

  create_table "spree_pos_kitchen_stations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "name", limit: 80, null: false
    t.string "kind", default: "prep", null: false
    t.bigint "printer_id"
    t.boolean "kds_enabled", default: true, null: false
    t.boolean "is_default", default: false, null: false
    t.integer "warn_after_minutes", default: 8, null: false
    t.integer "late_after_minutes", default: 15, null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "expo_station_id"
    t.index ["branch_id", "name"], name: "idx_pos_kitchen_stations_name", unique: true
    t.index ["branch_id"], name: "idx_pos_kitchen_stations_default", unique: true, where: "is_default"
    t.index ["branch_id"], name: "index_spree_pos_kitchen_stations_on_branch_id"
    t.index ["expo_station_id"], name: "index_spree_pos_kitchen_stations_on_expo_station_id"
    t.index ["printer_id"], name: "index_spree_pos_kitchen_stations_on_printer_id"
    t.index ["store_id"], name: "index_spree_pos_kitchen_stations_on_store_id"
    t.check_constraint "expo_station_id IS NULL OR expo_station_id <> id", name: "chk_pos_kitchen_stations_expo"
    t.check_constraint "kind::text = ANY (ARRAY['prep'::character varying, 'bar'::character varying, 'expo'::character varying]::text[])", name: "chk_pos_kitchen_stations_kind"
    t.check_constraint "warn_after_minutes > 0 AND late_after_minutes >= warn_after_minutes AND late_after_minutes <= 240", name: "chk_pos_kitchen_stations_minutes"
  end

  create_table "spree_pos_kitchen_ticket_items", force: :cascade do |t|
    t.bigint "kitchen_ticket_id", null: false
    t.bigint "sale_line_id"
    t.string "name", null: false
    t.jsonb "modifiers", default: [], null: false
    t.jsonb "components", default: [], null: false
    t.string "note", limit: 200
    t.decimal "quantity", precision: 19, scale: 4, null: false
    t.string "status", default: "new", null: false
    t.datetime "started_at"
    t.datetime "ready_at"
    t.datetime "served_at"
    t.datetime "voided_at"
    t.string "changed_by_type"
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "recalled_at"
    t.integer "recall_count", default: 0, null: false
    t.integer "prep_seconds"
    t.boolean "late", default: false, null: false
    t.index ["kitchen_ticket_id", "status"], name: "idx_pos_kitchen_ticket_items_status"
    t.index ["kitchen_ticket_id"], name: "index_spree_pos_kitchen_ticket_items_on_kitchen_ticket_id"
    t.index ["ready_at"], name: "idx_pos_kitchen_ticket_items_ready", where: "(ready_at IS NOT NULL)"
    t.index ["sale_line_id"], name: "index_spree_pos_kitchen_ticket_items_on_sale_line_id"
    t.check_constraint "quantity > 0::numeric", name: "chk_pos_kitchen_ticket_items_qty"
    t.check_constraint "recall_count >= 0 AND (prep_seconds IS NULL OR prep_seconds >= 0)", name: "chk_pos_kitchen_ticket_items_timing"
    t.check_constraint "status::text = ANY (ARRAY['new'::character varying, 'preparing'::character varying, 'ready'::character varying, 'served'::character varying, 'voided'::character varying]::text[])", name: "chk_pos_kitchen_ticket_items_status"
  end

  create_table "spree_pos_kitchen_tickets", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "kitchen_station_id", null: false
    t.integer "sequence", null: false
    t.string "kind", default: "fire", null: false
    t.string "send_key", limit: 200, null: false
    t.string "service_mode", null: false
    t.date "business_date", null: false
    t.jsonb "header", default: {}, null: false
    t.string "sent_by_type"
    t.bigint "sent_by_id"
    t.datetime "sent_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kitchen_send_id"
    t.index ["branch_id"], name: "index_spree_pos_kitchen_tickets_on_branch_id"
    t.index ["kitchen_send_id"], name: "index_spree_pos_kitchen_tickets_on_kitchen_send_id"
    t.index ["kitchen_station_id", "sent_at"], name: "idx_pos_kitchen_tickets_board"
    t.index ["kitchen_station_id"], name: "index_spree_pos_kitchen_tickets_on_kitchen_station_id"
    t.index ["store_id"], name: "index_spree_pos_kitchen_tickets_on_store_id"
    t.index ["workspace_id", "send_key", "kitchen_station_id"], name: "idx_pos_kitchen_tickets_send", unique: true
    t.index ["workspace_id", "sequence"], name: "idx_pos_kitchen_tickets_sequence", unique: true
    t.index ["workspace_id"], name: "index_spree_pos_kitchen_tickets_on_workspace_id"
    t.check_constraint "kind::text = ANY (ARRAY['fire'::character varying, 'void'::character varying]::text[])", name: "chk_pos_kitchen_tickets_kind"
  end

  create_table "spree_pos_kitchen_voids", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "sale_line_id"
    t.decimal "quantity", precision: 19, scale: 4, null: false
    t.string "name", null: false
    t.string "reason_code", limit: 40, null: false
    t.string "note", limit: 200
    t.bigint "staff_id", null: false
    t.bigint "device_id"
    t.bigint "approval_id"
    t.boolean "wasted", default: false, null: false
    t.bigint "kitchen_ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_id"], name: "index_spree_pos_kitchen_voids_on_approval_id"
    t.index ["device_id"], name: "index_spree_pos_kitchen_voids_on_device_id"
    t.index ["kitchen_ticket_id"], name: "index_spree_pos_kitchen_voids_on_kitchen_ticket_id"
    t.index ["sale_line_id"], name: "index_spree_pos_kitchen_voids_on_sale_line_id"
    t.index ["staff_id"], name: "index_spree_pos_kitchen_voids_on_staff_id"
    t.index ["workspace_id"], name: "index_spree_pos_kitchen_voids_on_workspace_id"
    t.check_constraint "quantity > 0::numeric", name: "chk_pos_kitchen_voids_quantity"
  end

  create_table "spree_pos_label_formats", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id"
    t.string "name", null: false
    t.string "prefix", null: false
    t.string "kind", null: false
    t.integer "item_code_length", null: false
    t.integer "value_length", null: false
    t.integer "value_decimals", default: 0, null: false
    t.string "value_unit_code"
    t.decimal "price_tolerance", precision: 19, scale: 4, default: "0.0", null: false
    t.integer "version", default: 1, null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_label_formats_on_branch_id"
    t.index ["store_id"], name: "index_spree_pos_label_formats_on_store_id"
    t.check_constraint "(char_length(prefix::text) + item_code_length + value_length) = 12 AND item_code_length > 0 AND value_length > 0", name: "chk_pos_label_formats_layout"
    t.check_constraint "kind::text = ANY (ARRAY['weight'::character varying::text, 'price'::character varying::text])", name: "chk_pos_label_formats_kind"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_pos_label_formats_status"
  end

  create_table "spree_pos_liability_payouts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "received_funds_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "requester_id", null: false
    t.string "status", default: "requested", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.string "beneficiary_name", limit: 120, null: false
    t.string "beneficiary_reference", limit: 120
    t.string "reason", limit: 200, null: false
    t.datetime "confirmed_at"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_liability_payouts_on_branch_id"
    t.index ["received_funds_id", "status"], name: "idx_pos_liability_payouts_funds"
    t.index ["received_funds_id"], name: "index_spree_pos_liability_payouts_on_received_funds_id"
    t.index ["requester_id"], name: "index_spree_pos_liability_payouts_on_requester_id"
    t.index ["store_id"], name: "index_spree_pos_liability_payouts_on_store_id"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_liability_payouts_amount"
    t.check_constraint "status::text = ANY (ARRAY['requested'::character varying::text, 'reserved'::character varying::text, 'unknown'::character varying::text, 'confirmed'::character varying::text, 'failed'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_liability_payouts_status"
  end

  create_table "spree_pos_line_components", force: :cascade do |t|
    t.bigint "sale_line_id", null: false
    t.bigint "variant_id", null: false
    t.string "name", limit: 200, null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sale_line_id"], name: "index_spree_pos_line_components_on_sale_line_id"
    t.index ["variant_id"], name: "index_spree_pos_line_components_on_variant_id"
    t.check_constraint "quantity > 0", name: "chk_pos_line_components_quantity"
  end

  create_table "spree_pos_line_discount_intents", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "sale_line_id", null: false
    t.bigint "actor_id", null: false
    t.string "value_type", null: false
    t.string "value", limit: 64, null: false
    t.string "reason", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source", default: "manual", null: false
    t.index ["sale_line_id"], name: "index_spree_pos_line_discount_intents_on_sale_line_id", unique: true
    t.index ["workspace_id"], name: "index_spree_pos_line_discount_intents_on_workspace_id"
    t.check_constraint "source::text = ANY (ARRAY['manual'::character varying, 'cover_credit'::character varying]::text[])", name: "chk_pos_line_discount_source"
    t.check_constraint "value_type::text = ANY (ARRAY['flat'::character varying::text, 'percent'::character varying::text, 'unit_price'::character varying::text, 'item_flat'::character varying::text, 'item_percent'::character varying::text])", name: "chk_pos_line_discount_type"
  end

  create_table "spree_pos_line_modifiers", force: :cascade do |t|
    t.bigint "sale_line_id", null: false
    t.bigint "modifier_option_id"
    t.string "name", limit: 80, null: false
    t.string "group_name", limit: 80, null: false
    t.decimal "price_delta", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modifier_option_id"], name: "index_spree_pos_line_modifiers_on_modifier_option_id"
    t.index ["sale_line_id"], name: "index_spree_pos_line_modifiers_on_sale_line_id"
    t.check_constraint "quantity > 0 AND price_delta >= 0::numeric", name: "chk_pos_line_modifiers_values"
  end

  create_table "spree_pos_menu_availabilities", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "menu_item_id", null: false
    t.date "sold_out_on"
    t.string "updated_by_type"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "menu_item_id"], name: "idx_pos_menu_availabilities_pair", unique: true
    t.index ["menu_item_id"], name: "index_spree_pos_menu_availabilities_on_menu_item_id"
  end

  create_table "spree_pos_menu_categories", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", limit: 80, null: false
    t.integer "position", default: 0, null: false
    t.string "color", limit: 16
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "name"], name: "idx_pos_menu_categories_name", unique: true
    t.index ["store_id"], name: "index_spree_pos_menu_categories_on_store_id"
  end

  create_table "spree_pos_menu_favorites", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "menu_item_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "menu_item_id"], name: "idx_pos_menu_favorites_pair", unique: true
    t.index ["menu_item_id"], name: "index_spree_pos_menu_favorites_on_menu_item_id"
  end

  create_table "spree_pos_menu_item_modifier_groups", force: :cascade do |t|
    t.bigint "menu_item_id", null: false
    t.bigint "modifier_group_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id", "modifier_group_id"], name: "idx_pos_menu_item_modifier_groups_pair", unique: true
    t.index ["modifier_group_id"], name: "index_spree_pos_menu_item_modifier_groups_on_modifier_group_id"
  end

  create_table "spree_pos_menu_items", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "product_id", null: false
    t.bigint "menu_category_id"
    t.string "kind", default: "single", null: false
    t.string "kitchen_category", limit: 40
    t.boolean "cup_label", default: false, null: false
    t.boolean "show_components_on_kds", default: true, null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "drink_credit", precision: 19, scale: 4
    t.jsonb "drink_credit_categories", default: [], null: false
    t.index ["menu_category_id"], name: "index_spree_pos_menu_items_on_menu_category_id"
    t.index ["product_id"], name: "index_spree_pos_menu_items_on_product_id"
    t.index ["store_id", "product_id"], name: "idx_pos_menu_items_product", unique: true
    t.index ["store_id"], name: "index_spree_pos_menu_items_on_store_id"
    t.check_constraint "drink_credit IS NULL OR drink_credit > 0::numeric", name: "chk_pos_menu_items_drink_credit"
    t.check_constraint "kind::text = ANY (ARRAY['single'::character varying, 'combo'::character varying]::text[])", name: "chk_pos_menu_items_kind"
    t.check_constraint "kitchen_category IS NULL OR kitchen_category::text ~ '^[a-z_]{2,40}$'::text", name: "chk_pos_menu_items_kitchen_category"
  end

  create_table "spree_pos_menu_schedule_items", force: :cascade do |t|
    t.bigint "menu_schedule_id", null: false
    t.bigint "menu_item_id", null: false
    t.bigint "variant_id"
    t.decimal "price", precision: 19, scale: 4
    t.boolean "hidden", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "menu_schedule_id, menu_item_id, COALESCE(variant_id, (0)::bigint)", name: "idx_pos_menu_schedule_items_target", unique: true
    t.index ["menu_item_id"], name: "index_spree_pos_menu_schedule_items_on_menu_item_id"
    t.index ["variant_id"], name: "index_spree_pos_menu_schedule_items_on_variant_id"
    t.check_constraint "price IS NULL OR price >= 0::numeric", name: "chk_pos_menu_schedule_items_price"
  end

  create_table "spree_pos_menu_schedules", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id"
    t.string "name", limit: 80, null: false
    t.integer "days_of_week", default: [], null: false, array: true
    t.time "starts_at", null: false
    t.time "ends_at", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label", limit: 40
    t.index ["branch_id"], name: "index_spree_pos_menu_schedules_on_branch_id"
    t.index ["store_id"], name: "index_spree_pos_menu_schedules_on_store_id"
    t.check_constraint "days_of_week <@ ARRAY[0, 1, 2, 3, 4, 5, 6]", name: "chk_pos_menu_schedules_days"
    t.check_constraint "starts_at <> ends_at", name: "chk_pos_menu_schedules_window"
  end

  create_table "spree_pos_modifier_groups", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", limit: 80, null: false
    t.integer "min_select", default: 0, null: false
    t.integer "max_select", default: 1, null: false
    t.boolean "allow_quantity", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_spree_pos_modifier_groups_on_store_id"
    t.check_constraint "min_select >= 0 AND max_select >= 1 AND min_select <= max_select", name: "chk_pos_modifier_groups_select"
  end

  create_table "spree_pos_modifier_options", force: :cascade do |t|
    t.bigint "modifier_group_id", null: false
    t.string "name", limit: 80, null: false
    t.decimal "price_delta", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "variant_id"
    t.boolean "default_selected", default: false, null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modifier_group_id"], name: "index_spree_pos_modifier_options_on_modifier_group_id"
    t.index ["variant_id"], name: "index_spree_pos_modifier_options_on_variant_id"
    t.check_constraint "price_delta >= 0::numeric", name: "chk_pos_modifier_options_price"
  end

  create_table "spree_pos_open_bottles", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "variant_id", null: false
    t.integer "capacity_ml", null: false
    t.integer "remaining_ml", null: false
    t.string "status", default: "open", null: false
    t.datetime "opened_at", null: false
    t.bigint "opened_by_id", null: false
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "variant_id", "status"], name: "idx_pos_open_bottles_branch_variant"
    t.index ["opened_by_id"], name: "index_spree_pos_open_bottles_on_opened_by_id"
    t.index ["variant_id"], name: "index_spree_pos_open_bottles_on_variant_id"
    t.check_constraint "(status::text = ANY (ARRAY['open'::character varying, 'finished'::character varying]::text[])) AND capacity_ml > 0 AND remaining_ml >= 0 AND remaining_ml <= capacity_ml", name: "chk_pos_open_bottles_values"
  end

  create_table "spree_pos_order_number_counters", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.date "business_date", null: false
    t.integer "last_value", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "business_date"], name: "idx_pos_order_number_counters_day", unique: true
    t.check_constraint "last_value >= 0", name: "chk_pos_order_number_counters_value"
  end

  create_table "spree_pos_outbox_entries", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "event_type", limit: 64, null: false
    t.string "aggregate_type", limit: 64, null: false
    t.bigint "aggregate_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.integer "attempts", default: 0, null: false
    t.datetime "available_at", null: false
    t.datetime "processed_at"
    t.text "last_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "available_at"], name: "idx_pos_outbox_dispatch"
    t.index ["store_id", "status", "available_at"], name: "idx_pos_outbox_undelivered", where: "((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('failed'::character varying)::text]))"
    t.index ["store_id"], name: "index_spree_pos_outbox_entries_on_store_id"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'processing'::character varying::text, 'processed'::character varying::text, 'failed'::character varying::text])", name: "chk_pos_outbox_status"
  end

  create_table "spree_pos_payment_methods", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "code", limit: 32, null: false
    t.string "name", limit: 120, null: false
    t.string "kind", limit: 32, null: false
    t.string "payment_method_type", limit: 120
    t.bigint "payment_method_id"
    t.string "status", default: "active", null: false
    t.integer "position", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "code"], name: "idx_pos_payment_methods_store_code", unique: true
    t.index ["store_id", "status", "position"], name: "idx_pos_payment_methods_active"
    t.index ["store_id"], name: "index_spree_pos_payment_methods_on_store_id"
    t.check_constraint "kind::text = ANY (ARRAY['cash'::character varying, 'bank_manual'::character varying, 'vietqr'::character varying, 'platform_receivable'::character varying]::text[])", name: "chk_pos_payment_methods_kind"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_pos_payment_methods_status"
  end

  create_table "spree_pos_payment_requests", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "requested_by_id", null: false
    t.bigint "device_id"
    t.bigint "resolved_by_id"
    t.string "status", default: "open", null: false
    t.string "note", limit: 200
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_spree_pos_payment_requests_on_device_id"
    t.index ["requested_by_id"], name: "index_spree_pos_payment_requests_on_requested_by_id"
    t.index ["resolved_by_id"], name: "index_spree_pos_payment_requests_on_resolved_by_id"
    t.index ["workspace_id"], name: "idx_pos_payment_requests_open", unique: true, where: "((status)::text = 'open'::text)"
    t.index ["workspace_id"], name: "idx_pos_payment_requests_workspace"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying, 'done'::character varying, 'canceled'::character varying]::text[])", name: "chk_pos_payment_requests_status"
  end

  create_table "spree_pos_payout_evidences", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "liability_payout_id"
    t.bigint "actor_id", null: false
    t.string "kind", limit: 32, null: false
    t.string "reference", limit: 120
    t.datetime "attested_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "refund_request_id"
    t.index ["actor_id"], name: "index_spree_pos_payout_evidences_on_actor_id"
    t.index ["liability_payout_id", "created_at"], name: "idx_pos_payout_evidences_payout"
    t.index ["liability_payout_id"], name: "index_spree_pos_payout_evidences_on_liability_payout_id"
    t.index ["refund_request_id"], name: "index_spree_pos_payout_evidences_on_refund_request_id"
    t.index ["store_id"], name: "index_spree_pos_payout_evidences_on_store_id"
    t.check_constraint "(liability_payout_id IS NULL) <> (refund_request_id IS NULL)", name: "chk_pos_payout_evidences_subject"
    t.check_constraint "kind::text = ANY (ARRAY['cash_count'::character varying::text, 'bank_manual'::character varying::text, 'failed_no_effect'::character varying::text])", name: "chk_pos_payout_evidences_kind"
  end

  create_table "spree_pos_platform_orders", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.string "platform", limit: 20, null: false
    t.string "platform_order_ref", limit: 64, null: false
    t.string "pickup_code", limit: 32
    t.string "status", limit: 16, default: "accepted", null: false
    t.decimal "gross_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "commission_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "commission_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "net_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", limit: 16, null: false
    t.bigint "entered_by_id", null: false
    t.datetime "ready_at"
    t.datetime "completed_at"
    t.datetime "canceled_at"
    t.string "cancel_reason", limit: 200
    t.datetime "settled_at"
    t.bigint "settled_by_id"
    t.string "settlement_reference", limit: 120
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "platform", "platform_order_ref"], name: "idx_pos_platform_orders_ref", unique: true
    t.index ["branch_id", "status"], name: "idx_pos_platform_orders_status"
    t.index ["entered_by_id"], name: "index_spree_pos_platform_orders_on_entered_by_id"
    t.index ["settled_by_id"], name: "index_spree_pos_platform_orders_on_settled_by_id"
    t.index ["store_id"], name: "index_spree_pos_platform_orders_on_store_id"
    t.index ["workspace_id"], name: "index_spree_pos_platform_orders_on_workspace_id", unique: true
    t.check_constraint "gross_amount >= 0::numeric AND commission_amount >= 0::numeric AND commission_amount <= gross_amount AND net_amount = (gross_amount - commission_amount) AND commission_rate >= 0::numeric AND commission_rate <= 100::numeric", name: "chk_pos_platform_orders_amounts"
    t.check_constraint "platform::text = ANY (ARRAY['grabfood'::character varying, 'shopeefood'::character varying]::text[])", name: "chk_pos_platform_orders_platform"
    t.check_constraint "settled_at IS NULL OR status::text = 'completed'::text", name: "chk_pos_platform_orders_settled"
    t.check_constraint "status::text = ANY (ARRAY['accepted'::character varying, 'ready'::character varying, 'completed'::character varying, 'canceled'::character varying]::text[])", name: "chk_pos_platform_orders_status"
  end

  create_table "spree_pos_platform_settings", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "platform", limit: 20, null: false
    t.decimal "commission_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.string "status", limit: 16, default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "platform"], name: "idx_pos_platform_settings_branch", unique: true
    t.index ["store_id"], name: "index_spree_pos_platform_settings_on_store_id"
    t.check_constraint "commission_rate >= 0::numeric AND commission_rate <= 100::numeric", name: "chk_pos_platform_settings_rate"
    t.check_constraint "platform::text = ANY (ARRAY['grabfood'::character varying, 'shopeefood'::character varying]::text[])", name: "chk_pos_platform_settings_platform"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'disabled'::character varying]::text[])", name: "chk_pos_platform_settings_status"
  end

  create_table "spree_pos_pour_events", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "open_bottle_id", null: false
    t.bigint "sale_line_id", null: false
    t.bigint "workspace_id", null: false
    t.integer "ml", null: false
    t.date "business_date", null: false
    t.datetime "created_at", null: false
    t.index ["branch_id", "business_date"], name: "idx_pos_pour_events_day"
    t.index ["open_bottle_id"], name: "index_spree_pos_pour_events_on_open_bottle_id"
    t.index ["sale_line_id", "open_bottle_id"], name: "idx_pos_pour_events_once", unique: true
    t.index ["workspace_id"], name: "index_spree_pos_pour_events_on_workspace_id"
    t.check_constraint "ml > 0", name: "chk_pos_pour_events_ml"
  end

  create_table "spree_pos_prebill_prints", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.integer "revision", null: false
    t.integer "sequence", null: false
    t.bigint "staff_id", null: false
    t.bigint "approval_id"
    t.string "status", default: "current", null: false
    t.decimal "total", precision: 12, scale: 2, null: false
    t.string "currency", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_id"], name: "index_spree_pos_prebill_prints_on_approval_id"
    t.index ["staff_id"], name: "index_spree_pos_prebill_prints_on_staff_id"
    t.index ["workspace_id", "sequence"], name: "idx_pos_prebill_prints_sequence", unique: true
    t.check_constraint "status::text = ANY (ARRAY['current'::character varying, 'superseded'::character varying, 'canceled'::character varying]::text[])", name: "chk_pos_prebill_prints_status"
  end

  create_table "spree_pos_print_jobs", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "printer_id", null: false
    t.string "kind", null: false
    t.jsonb "document", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.integer "source_revision"
    t.string "status", default: "queued", null: false
    t.integer "attempts", default: 0, null: false
    t.bigint "claimed_by_device_id"
    t.datetime "claim_expires_at"
    t.datetime "printed_at"
    t.string "last_error"
    t.jsonb "attempt_reports", default: {}, null: false
    t.string "idempotency_key", null: false
    t.bigint "created_by_id"
    t.bigint "copy_of_id"
    t.bigint "receipt_print_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_digest"
    t.datetime "next_attempt_at"
    t.bigint "receipt_template_id"
    t.integer "template_version"
    t.index ["branch_id"], name: "index_spree_pos_print_jobs_on_branch_id"
    t.index ["claim_expires_at"], name: "idx_pos_print_jobs_leases", where: "((status)::text = 'claimed'::text)"
    t.index ["claimed_by_device_id"], name: "index_spree_pos_print_jobs_on_claimed_by_device_id"
    t.index ["copy_of_id"], name: "index_spree_pos_print_jobs_on_copy_of_id"
    t.index ["printer_id", "status", "id"], name: "idx_pos_print_jobs_queue"
    t.index ["receipt_print_id"], name: "index_spree_pos_print_jobs_on_receipt_print_id"
    t.index ["receipt_template_id"], name: "index_spree_pos_print_jobs_on_receipt_template_id"
    t.index ["source_type", "source_id"], name: "idx_pos_print_jobs_source"
    t.index ["store_id", "idempotency_key"], name: "idx_pos_print_jobs_key", unique: true
    t.check_constraint "attempts >= 0", name: "chk_pos_print_jobs_attempts"
    t.check_constraint "kind::text = ANY (ARRAY['receipt'::character varying, 'prebill'::character varying, 'kitchen_ticket'::character varying, 'void_ticket'::character varying, 'cup_label'::character varying, 'checklist'::character varying, 'table_qr'::character varying, 'test'::character varying]::text[])", name: "chk_pos_print_jobs_kind"
    t.check_constraint "status::text = ANY (ARRAY['queued'::character varying, 'claimed'::character varying, 'printed'::character varying, 'failed'::character varying, 'canceled'::character varying]::text[])", name: "chk_pos_print_jobs_status"
  end

  create_table "spree_pos_printers", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "print_station_device_id"
    t.string "name", null: false
    t.string "connection", null: false
    t.string "address"
    t.string "bluetooth_id"
    t.string "paper", default: "80mm", null: false
    t.string "command_language", default: "escpos", null: false
    t.text "roles", default: [], null: false, array: true
    t.string "status", default: "active", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_printers_on_branch_id"
    t.index ["print_station_device_id"], name: "index_spree_pos_printers_on_print_station_device_id"
    t.index ["register_id"], name: "index_spree_pos_printers_on_register_id"
    t.index ["store_id"], name: "index_spree_pos_printers_on_store_id"
    t.check_constraint "command_language::text = ANY (ARRAY['escpos'::character varying, 'tspl'::character varying]::text[])", name: "chk_pos_printers_language"
    t.check_constraint "connection::text = ANY (ARRAY['escpos_lan'::character varying, 'escpos_bluetooth'::character varying, 'sunmi_builtin'::character varying, 'epson_epos'::character varying, 'star_webprnt'::character varying, 'browser'::character varying]::text[])", name: "chk_pos_printers_connection"
    t.check_constraint "paper::text = ANY (ARRAY['58mm'::character varying, '80mm'::character varying]::text[])", name: "chk_pos_printers_paper"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'disabled'::character varying]::text[])", name: "chk_pos_printers_status"
  end

  create_table "spree_pos_receipt_evidences", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "tender_attempt_id", null: false
    t.bigint "actor_id", null: false
    t.string "kind", limit: 32, null: false
    t.string "reference", limit: 120
    t.string "receiving_account", limit: 120
    t.string "terminal_ref", limit: 120
    t.datetime "attested_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_receipt_evidences_on_actor_id"
    t.index ["store_id"], name: "index_spree_pos_receipt_evidences_on_store_id"
    t.index ["tender_attempt_id", "created_at"], name: "idx_pos_receipt_evidences_attempt"
    t.index ["tender_attempt_id"], name: "index_spree_pos_receipt_evidences_on_tender_attempt_id"
    t.check_constraint "kind::text = ANY (ARRAY['cash_count'::character varying, 'bank_manual'::character varying, 'external_card'::character varying, 'vietqr_webhook'::character varying, 'vietqr_manual'::character varying, 'platform_order'::character varying]::text[])", name: "chk_pos_receipt_evidences_kind"
  end

  create_table "spree_pos_receipt_prints", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "receipt_snapshot_id", null: false
    t.bigint "actor_id", null: false
    t.integer "copy_number", null: false
    t.datetime "created_at", null: false
    t.bigint "receipt_template_id"
    t.integer "template_version"
    t.string "paper"
    t.datetime "voided_at"
    t.bigint "printer_id"
    t.index ["printer_id"], name: "index_spree_pos_receipt_prints_on_printer_id"
    t.index ["receipt_snapshot_id", "copy_number"], name: "idx_pos_receipt_prints_copy", unique: true, where: "(voided_at IS NULL)"
    t.index ["receipt_template_id"], name: "idx_pos_receipt_prints_template"
    t.check_constraint "copy_number >= 0", name: "chk_pos_receipt_prints_copy_number"
    t.check_constraint "paper IS NULL OR (paper::text = ANY (ARRAY['58mm'::character varying::text, '80mm'::character varying::text, 'a4'::character varying::text, 'a5'::character varying::text, 'a6'::character varying::text]))", name: "chk_pos_receipt_prints_paper"
  end

  create_table "spree_pos_receipt_snapshots", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "issued_by_id"
    t.string "source_type", limit: 32, null: false
    t.bigint "source_id", null: false
    t.string "number", limit: 64, null: false
    t.jsonb "payload", default: {}, null: false
    t.boolean "issued_late", default: false, null: false
    t.datetime "issued_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "number"], name: "idx_pos_receipt_snapshots_branch_number"
    t.index ["source_type", "source_id"], name: "idx_pos_receipt_snapshots_source", unique: true
    t.index ["store_id", "source_type", "number"], name: "idx_pos_receipt_snapshots_number", unique: true
    t.check_constraint "source_type::text = ANY (ARRAY['sale'::character varying::text, 'return'::character varying::text, 'return_supplement'::character varying::text, 'refund'::character varying::text, 'shift_closure'::character varying::text])", name: "chk_pos_receipt_snapshots_source_type"
  end

  create_table "spree_pos_receipt_template_versions", force: :cascade do |t|
    t.bigint "receipt_template_id", null: false
    t.integer "version", null: false
    t.jsonb "config", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.index ["receipt_template_id", "version"], name: "idx_pos_receipt_template_versions_version", unique: true
    t.check_constraint "version >= 1", name: "chk_pos_receipt_template_versions_version"
  end

  create_table "spree_pos_receipt_templates", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "document_type", null: false
    t.string "paper", null: false
    t.string "status", default: "active", null: false
    t.boolean "is_default", default: false, null: false
    t.integer "current_version", default: 1, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "document_type", "status"], name: "idx_pos_receipt_templates_type"
    t.index ["store_id", "document_type"], name: "idx_pos_receipt_templates_default", unique: true, where: "(is_default AND ((status)::text = 'active'::text))"
    t.check_constraint "current_version >= 1", name: "chk_pos_receipt_templates_current_version"
    t.check_constraint "document_type::text = ANY (ARRAY['sale'::character varying::text, 'prebill'::character varying::text, 'payment_ticket'::character varying::text, 'return'::character varying::text, 'refund'::character varying::text, 'shift_closure'::character varying::text])", name: "chk_pos_receipt_templates_document_type"
    t.check_constraint "paper::text = ANY (ARRAY['58mm'::character varying::text, '80mm'::character varying::text, 'a4'::character varying::text, 'a5'::character varying::text, 'a6'::character varying::text])", name: "chk_pos_receipt_templates_paper"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_pos_receipt_templates_status"
  end

  create_table "spree_pos_receivable_entries", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "credit_account_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "order_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "credit_reservation_id"
    t.bigint "funds_allocation_id"
    t.bigint "actor_id", null: false
    t.string "kind", limit: 32, null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.date "due_on"
    t.string "source_type", limit: 64
    t.bigint "source_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_receivable_entries_on_actor_id"
    t.index ["branch_id"], name: "index_spree_pos_receivable_entries_on_branch_id"
    t.index ["credit_account_id", "order_id"], name: "idx_pos_receivable_entries_account_order"
    t.index ["credit_account_id"], name: "index_spree_pos_receivable_entries_on_credit_account_id"
    t.index ["credit_reservation_id"], name: "index_spree_pos_receivable_entries_on_credit_reservation_id"
    t.index ["funds_allocation_id", "kind"], name: "idx_pos_receivable_entries_allocation", unique: true, where: "(funds_allocation_id IS NOT NULL)"
    t.index ["funds_allocation_id"], name: "index_spree_pos_receivable_entries_on_funds_allocation_id"
    t.index ["order_id"], name: "idx_pos_receivable_entries_one_debit", unique: true, where: "((kind)::text = 'debit'::text)"
    t.index ["source_type", "source_id"], name: "idx_pos_receivable_entries_credit_note_source", unique: true, where: "((kind)::text = 'credit_note'::text)"
    t.index ["store_id"], name: "index_spree_pos_receivable_entries_on_store_id"
    t.index ["workspace_id"], name: "index_spree_pos_receivable_entries_on_workspace_id"
    t.check_constraint "(kind::text = 'debit'::text) = (due_on IS NOT NULL AND credit_reservation_id IS NOT NULL)", name: "chk_pos_receivable_entries_debit"
    t.check_constraint "(kind::text = ANY (ARRAY['collection'::character varying::text, 'collection_reversal'::character varying::text])) = (funds_allocation_id IS NOT NULL)", name: "chk_pos_receivable_entries_allocation"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_receivable_entries_amount"
    t.check_constraint "kind::text <> 'credit_note'::text OR source_type IS NOT NULL AND source_id IS NOT NULL", name: "chk_pos_receivable_entries_credit_note"
    t.check_constraint "kind::text = ANY (ARRAY['debit'::character varying::text, 'credit_note'::character varying::text, 'collection'::character varying::text, 'collection_reversal'::character varying::text])", name: "chk_pos_receivable_entries_kind"
  end

  create_table "spree_pos_received_funds", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "workspace_id"
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "shift_id", null: false
    t.bigint "tender_attempt_id"
    t.bigint "actor_id", null: false
    t.string "kind", limit: 32, null: false
    t.string "status", default: "received", null: false
    t.decimal "handed_amount", precision: 19, scale: 4, null: false
    t.decimal "applied_amount", precision: 19, scale: 4, null: false
    t.decimal "change_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "received_net", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.string "reference", limit: 120
    t.datetime "received_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "receiving_account", limit: 120
    t.string "custody", limit: 16, default: "drawer", null: false
    t.string "custody_note", limit: 200
    t.index ["actor_id"], name: "index_spree_pos_received_funds_on_actor_id"
    t.index ["branch_id", "received_at"], name: "idx_pos_received_funds_branch_received"
    t.index ["branch_id"], name: "idx_pos_received_funds_held_cash", where: "(((kind)::text = 'cash'::text) AND ((custody)::text = 'held'::text))"
    t.index ["branch_id"], name: "index_spree_pos_received_funds_on_branch_id"
    t.index ["register_id"], name: "index_spree_pos_received_funds_on_register_id"
    t.index ["shift_id", "status"], name: "idx_pos_received_funds_shift"
    t.index ["shift_id"], name: "index_spree_pos_received_funds_on_shift_id"
    t.index ["store_id"], name: "index_spree_pos_received_funds_on_store_id"
    t.index ["tender_attempt_id"], name: "idx_pos_received_funds_attempt", unique: true, where: "(tender_attempt_id IS NOT NULL)"
    t.index ["tender_attempt_id"], name: "index_spree_pos_received_funds_on_tender_attempt_id"
    t.index ["workspace_id", "status"], name: "idx_pos_received_funds_workspace"
    t.index ["workspace_id"], name: "index_spree_pos_received_funds_on_workspace_id"
    t.check_constraint "custody::text = ANY (ARRAY['drawer'::character varying::text, 'held'::character varying::text])", name: "chk_pos_received_funds_custody"
    t.check_constraint "handed_amount >= 0::numeric AND applied_amount >= 0::numeric AND change_amount >= 0::numeric AND received_net >= 0::numeric", name: "chk_pos_received_funds_amounts"
    t.check_constraint "kind::text = ANY (ARRAY['cash'::character varying, 'bank_manual'::character varying, 'platform_receivable'::character varying]::text[])", name: "chk_pos_received_funds_kind"
    t.check_constraint "status::text = ANY (ARRAY['received'::character varying::text, 'attention'::character varying::text])", name: "chk_pos_received_funds_status"
  end

  create_table "spree_pos_recipe_consumptions", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "order_id", null: false
    t.bigint "sale_line_id", null: false
    t.bigint "ingredient_variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.integer "base_quantity", null: false
    t.string "base_unit_code", limit: 16, null: false
    t.bigint "recipe_id"
    t.integer "recipe_version"
    t.string "source_key", limit: 64, null: false
    t.decimal "unit_cost", precision: 19, scale: 4
    t.date "business_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "business_date"], name: "idx_pos_recipe_consumptions_day"
    t.index ["branch_id"], name: "index_spree_pos_recipe_consumptions_on_branch_id"
    t.index ["ingredient_variant_id"], name: "index_spree_pos_recipe_consumptions_on_ingredient_variant_id"
    t.index ["order_id"], name: "index_spree_pos_recipe_consumptions_on_order_id"
    t.index ["recipe_id"], name: "index_spree_pos_recipe_consumptions_on_recipe_id"
    t.index ["sale_line_id", "ingredient_variant_id", "source_key"], name: "idx_pos_recipe_consumptions_source", unique: true
    t.index ["sale_line_id"], name: "index_spree_pos_recipe_consumptions_on_sale_line_id"
    t.index ["stock_location_id"], name: "index_spree_pos_recipe_consumptions_on_stock_location_id"
    t.index ["store_id"], name: "index_spree_pos_recipe_consumptions_on_store_id"
    t.index ["workspace_id"], name: "index_spree_pos_recipe_consumptions_on_workspace_id"
    t.check_constraint "base_quantity > 0", name: "chk_pos_recipe_consumptions_quantity"
  end

  create_table "spree_pos_recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 4, null: false
    t.string "unit_code", limit: 16, null: false
    t.integer "base_quantity", null: false
    t.string "base_unit_code", limit: 16, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pour_ml"
    t.integer "bottle_ml"
    t.index ["ingredient_variant_id"], name: "index_spree_pos_recipe_ingredients_on_ingredient_variant_id"
    t.index ["recipe_id", "ingredient_variant_id"], name: "idx_pos_recipe_ingredients_variant", unique: true
    t.index ["recipe_id"], name: "index_spree_pos_recipe_ingredients_on_recipe_id"
    t.check_constraint "quantity > 0::numeric AND (pour_ml IS NULL AND bottle_ml IS NULL AND base_quantity > 0 OR pour_ml > 0 AND bottle_ml >= pour_ml AND base_quantity = 0)", name: "chk_pos_recipe_ingredients_quantity"
  end

  create_table "spree_pos_recipes", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "owner_type", limit: 64, null: false
    t.bigint "owner_id", null: false
    t.integer "version", null: false
    t.boolean "active", default: true, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_spree_pos_recipes_on_created_by_id"
    t.index ["owner_type", "owner_id", "version"], name: "idx_pos_recipes_version", unique: true
    t.index ["owner_type", "owner_id"], name: "idx_pos_recipes_active", unique: true, where: "active"
    t.index ["store_id"], name: "index_spree_pos_recipes_on_store_id"
    t.check_constraint "owner_type::text = ANY (ARRAY['Spree::Variant'::character varying, 'Spree::Pos::ModifierOption'::character varying]::text[])", name: "chk_pos_recipes_owner"
    t.check_constraint "version > 0", name: "chk_pos_recipes_version"
  end

  create_table "spree_pos_refund_requests", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "return_operation_id", null: false
    t.bigint "funds_allocation_id", null: false
    t.bigint "received_funds_id", null: false
    t.bigint "payment_id", null: false
    t.bigint "order_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "confirmer_id"
    t.bigint "approval_id"
    t.bigint "shift_id"
    t.bigint "refund_id"
    t.string "method", limit: 16, null: false
    t.string "status", limit: 16, default: "reserved", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.integer "revision", default: 1, null: false
    t.string "beneficiary_reference", limit: 120
    t.datetime "confirmed_at"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_id"], name: "index_spree_pos_refund_requests_on_approval_id"
    t.index ["branch_id"], name: "index_spree_pos_refund_requests_on_branch_id"
    t.index ["confirmer_id"], name: "index_spree_pos_refund_requests_on_confirmer_id"
    t.index ["funds_allocation_id", "status"], name: "idx_pos_refund_requests_allocation"
    t.index ["funds_allocation_id"], name: "index_spree_pos_refund_requests_on_funds_allocation_id"
    t.index ["order_id"], name: "index_spree_pos_refund_requests_on_order_id"
    t.index ["payment_id"], name: "index_spree_pos_refund_requests_on_payment_id"
    t.index ["received_funds_id"], name: "index_spree_pos_refund_requests_on_received_funds_id"
    t.index ["refund_id"], name: "index_spree_pos_refund_requests_on_refund_id", unique: true
    t.index ["requester_id"], name: "index_spree_pos_refund_requests_on_requester_id"
    t.index ["return_operation_id"], name: "index_spree_pos_refund_requests_on_return_operation_id"
    t.index ["shift_id"], name: "index_spree_pos_refund_requests_on_shift_id"
    t.index ["store_id", "branch_id", "status"], name: "idx_pos_refund_requests_branch"
    t.index ["store_id"], name: "index_spree_pos_refund_requests_on_store_id"
    t.check_constraint "(status::text = 'confirmed'::text) = (refund_id IS NOT NULL)", name: "chk_pos_refund_requests_refund"
    t.check_constraint "amount > 0::numeric", name: "chk_pos_refund_requests_amount"
    t.check_constraint "method::text = ANY (ARRAY['cash'::character varying::text, 'bank_manual'::character varying::text])", name: "chk_pos_refund_requests_method"
    t.check_constraint "status::text = ANY (ARRAY['reserved'::character varying::text, 'unknown'::character varying::text, 'confirmed'::character varying::text, 'failed'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_refund_requests_status"
  end

  create_table "spree_pos_registers", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.string "name", null: false
    t.string "code", null: false
    t.string "status", default: "active", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_registers_on_branch_id"
    t.index ["store_id", "code"], name: "index_spree_pos_registers_on_store_id_and_code", unique: true
    t.index ["store_id"], name: "index_spree_pos_registers_on_store_id"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_spree_pos_registers_status"
  end

  create_table "spree_pos_reservation_deposits", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.bigint "received_funds_id", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", null: false
    t.string "status", default: "held", null: false
    t.bigint "resolution_order_id"
    t.bigint "liability_payout_id"
    t.bigint "funds_allocation_id"
    t.bigint "actor_id", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_reservation_deposits_on_actor_id"
    t.index ["funds_allocation_id"], name: "index_spree_pos_reservation_deposits_on_funds_allocation_id"
    t.index ["liability_payout_id"], name: "index_spree_pos_reservation_deposits_on_liability_payout_id"
    t.index ["received_funds_id"], name: "index_spree_pos_reservation_deposits_on_received_funds_id", unique: true
    t.index ["reservation_id"], name: "index_spree_pos_reservation_deposits_on_reservation_id"
    t.index ["resolution_order_id"], name: "index_spree_pos_reservation_deposits_on_resolution_order_id"
    t.check_constraint "(status::text = ANY (ARRAY['held'::character varying, 'applied'::character varying, 'refunded'::character varying, 'forfeited'::character varying]::text[])) AND amount > 0::numeric", name: "chk_pos_reservation_deposits_values"
  end

  create_table "spree_pos_reservation_resources", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.bigint "resource_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_spree_pos_reservation_resources_on_reservation_id"
    t.check_constraint "ends_at > starts_at", name: "chk_pos_reservation_resources_range"
    t.exclusion_constraint "resource_id WITH =, tsrange(starts_at, ends_at) WITH &&", where: "(active)", using: :gist, name: "excl_pos_reservation_resources_overlap"
  end

  create_table "spree_pos_reservations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "customer_profile_id"
    t.string "guest_name", null: false
    t.string "phone"
    t.integer "party_size", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "source", default: "phone", null: false
    t.string "status", default: "booked", null: false
    t.text "note"
    t.bigint "workspace_id"
    t.bigint "created_by_id", null: false
    t.integer "revision", default: 0, null: false
    t.datetime "seated_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "starts_at"], name: "idx_pos_reservations_branch_time"
    t.index ["created_by_id"], name: "index_spree_pos_reservations_on_created_by_id"
    t.index ["customer_profile_id"], name: "index_spree_pos_reservations_on_customer_profile_id"
    t.index ["workspace_id"], name: "index_spree_pos_reservations_on_workspace_id"
    t.check_constraint "(status::text = ANY (ARRAY['booked'::character varying, 'seated'::character varying, 'completed'::character varying, 'no_show'::character varying, 'canceled'::character varying]::text[])) AND (source::text = ANY (ARRAY['phone'::character varying, 'walk_in'::character varying, 'online'::character varying]::text[])) AND party_size >= 1 AND party_size <= 999 AND ends_at > starts_at", name: "chk_pos_reservations_values"
  end

  create_table "spree_pos_resources", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "area_id", null: false
    t.string "kind", default: "table", null: false
    t.string "name", limit: 40, null: false
    t.integer "capacity", default: 4, null: false
    t.string "shape", default: "rect", null: false
    t.integer "x", default: 0, null: false
    t.integer "y", default: 0, null: false
    t.integer "w", default: 2, null: false
    t.integer "h", default: 2, null: false
    t.integer "rotation", default: 0, null: false
    t.string "manual_status", default: "available", null: false
    t.string "resource_type_code", limit: 40
    t.string "status", default: "active", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "minimum_spend", precision: 19, scale: 4
    t.string "minimum_spend_currency", limit: 16
    t.index ["area_id"], name: "index_spree_pos_resources_on_area_id"
    t.index ["branch_id", "name"], name: "idx_pos_resources_name", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["branch_id"], name: "index_spree_pos_resources_on_branch_id"
    t.index ["store_id"], name: "index_spree_pos_resources_on_store_id"
    t.check_constraint "capacity >= 0 AND capacity <= 999 AND x >= 0 AND y >= 0 AND w >= 1 AND w <= 50 AND h >= 1 AND h <= 50 AND rotation >= 0 AND rotation <= 359", name: "chk_pos_resources_geometry"
    t.check_constraint "kind::text = ANY (ARRAY['table'::character varying, 'room'::character varying, 'billiard'::character varying, 'vip'::character varying]::text[])", name: "chk_pos_resources_kind"
    t.check_constraint "manual_status::text = ANY (ARRAY['available'::character varying, 'cleaning'::character varying, 'out_of_service'::character varying]::text[])", name: "chk_pos_resources_manual_status"
    t.check_constraint "minimum_spend IS NULL AND minimum_spend_currency IS NULL OR minimum_spend > 0::numeric AND minimum_spend_currency IS NOT NULL", name: "chk_pos_resources_minimum_spend"
    t.check_constraint "shape::text = ANY (ARRAY['rect'::character varying, 'round'::character varying]::text[])", name: "chk_pos_resources_shape"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'archived'::character varying]::text[])", name: "chk_pos_resources_status"
  end

  create_table "spree_pos_return_operations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "sale_branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "order_id", null: false
    t.bigint "core_return_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "receiver_id"
    t.bigint "approval_id"
    t.string "status", limit: 32, default: "ready", null: false
    t.string "entitlement_status", limit: 32, default: "pending", null: false
    t.string "reason", limit: 200, null: false
    t.boolean "cross_branch", default: false, null: false
    t.boolean "out_of_window", default: false, null: false
    t.boolean "damaged", default: false, null: false
    t.boolean "requires_approval", default: false, null: false
    t.integer "revision", default: 1, null: false
    t.decimal "entitlement_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "credit_note_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "refund_entitlement", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", limit: 16, null: false
    t.datetime "received_at"
    t.datetime "posted_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_id"], name: "index_spree_pos_return_operations_on_approval_id"
    t.index ["branch_id"], name: "index_spree_pos_return_operations_on_branch_id"
    t.index ["core_return_id"], name: "index_spree_pos_return_operations_on_core_return_id", unique: true
    t.index ["order_id", "status"], name: "idx_pos_return_operations_order"
    t.index ["order_id"], name: "index_spree_pos_return_operations_on_order_id"
    t.index ["receiver_id"], name: "index_spree_pos_return_operations_on_receiver_id"
    t.index ["requester_id"], name: "index_spree_pos_return_operations_on_requester_id"
    t.index ["sale_branch_id"], name: "index_spree_pos_return_operations_on_sale_branch_id"
    t.index ["store_id", "status"], name: "idx_pos_return_operations_status"
    t.index ["store_id"], name: "index_spree_pos_return_operations_on_store_id"
    t.index ["workspace_id"], name: "index_spree_pos_return_operations_on_workspace_id"
    t.check_constraint "entitlement_status::text = ANY (ARRAY['pending'::character varying::text, 'awaiting_predecessor'::character varying::text, 'posted'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_return_operations_entitlement"
    t.check_constraint "entitlement_total >= 0::numeric AND credit_note_amount >= 0::numeric AND refund_entitlement >= 0::numeric AND (credit_note_amount + refund_entitlement) <= entitlement_total", name: "chk_pos_return_operations_amounts"
    t.check_constraint "status::text = ANY (ARRAY['pending_approval'::character varying::text, 'ready'::character varying::text, 'received'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_return_operations_status"
  end

  create_table "spree_pos_return_reservations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "return_operation_id", null: false
    t.bigint "sale_line_id", null: false
    t.bigint "line_item_id", null: false
    t.bigint "fulfillment_item_id", null: false
    t.bigint "return_line_item_id", null: false
    t.integer "quantity", null: false
    t.integer "sequence", null: false
    t.integer "cumulative_before", null: false
    t.integer "cumulative_after", null: false
    t.string "condition", limit: 16, null: false
    t.string "status", limit: 16, default: "reserved", null: false
    t.decimal "total", precision: 19, scale: 4, null: false
    t.decimal "net", precision: 19, scale: 4, null: false
    t.decimal "tax", precision: 19, scale: 4, null: false
    t.decimal "discount", precision: 19, scale: 4, null: false
    t.decimal "gross", precision: 19, scale: 4, null: false
    t.integer "received_quantity", default: 0, null: false
    t.integer "restocked_quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fulfillment_item_id"], name: "index_spree_pos_return_reservations_on_fulfillment_item_id"
    t.index ["line_item_id"], name: "index_spree_pos_return_reservations_on_line_item_id"
    t.index ["return_line_item_id"], name: "index_spree_pos_return_reservations_on_return_line_item_id", unique: true
    t.index ["return_operation_id", "sale_line_id"], name: "idx_pos_return_reservations_line"
    t.index ["return_operation_id"], name: "index_spree_pos_return_reservations_on_return_operation_id"
    t.index ["sale_line_id", "sequence"], name: "idx_pos_return_reservations_sequence", unique: true
    t.index ["sale_line_id"], name: "index_spree_pos_return_reservations_on_sale_line_id"
    t.index ["store_id"], name: "index_spree_pos_return_reservations_on_store_id"
    t.check_constraint "condition::text = ANY (ARRAY['resellable'::character varying::text, 'damaged'::character varying::text])", name: "chk_pos_return_reservations_condition"
    t.check_constraint "quantity > 0 AND cumulative_before >= 0 AND cumulative_after = (cumulative_before + quantity)", name: "chk_pos_return_reservations_quantity"
    t.check_constraint "received_quantity >= 0 AND received_quantity <= quantity AND restocked_quantity >= 0 AND restocked_quantity <= received_quantity", name: "chk_pos_return_reservations_receipt"
    t.check_constraint "status::text = ANY (ARRAY['reserved'::character varying::text, 'posted'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_return_reservations_status"
    t.check_constraint "total >= 0::numeric AND net >= 0::numeric AND tax >= 0::numeric AND discount >= 0::numeric AND gross >= 0::numeric AND total = (net + tax) AND (gross - discount) = net", name: "chk_pos_return_reservations_components"
  end

  create_table "spree_pos_sale_lines", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "order_id", null: false
    t.bigint "line_item_id", null: false
    t.bigint "variant_id", null: false
    t.string "kind", default: "ordinary", null: false
    t.string "merge_key", limit: 200, null: false
    t.decimal "sale_quantity", precision: 19, scale: 4, null: false
    t.integer "base_quantity", null: false
    t.string "sale_unit_code", limit: 16, default: "item", null: false
    t.string "base_unit_code", limit: 16, default: "item", null: false
    t.integer "ratio_numerator", default: 1, null: false
    t.integer "ratio_denominator", default: 1, null: false
    t.integer "conversion_version"
    t.decimal "unit_price", precision: 19, scale: 4, null: false
    t.decimal "line_price", precision: 19, scale: 4, null: false
    t.string "lot_code", limit: 100
    t.date "expiry_on"
    t.jsonb "serial_codes", default: [], null: false
    t.string "tracked_mode", default: "none", null: false
    t.uuid "measurement_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label_barcode"
    t.bigint "label_format_id"
    t.integer "label_format_version"
    t.string "note", limit: 200
    t.string "modifier_signature", limit: 64
    t.decimal "kitchen_sent_quantity", precision: 19, scale: 4, default: "0.0", null: false
    t.integer "row_version", default: 0, null: false
    t.bigint "added_by_id"
    t.bigint "added_device_id"
    t.uuid "append_batch_id"
    t.integer "course", limit: 2
    t.string "course_status", default: "none", null: false
    t.integer "seat", limit: 2
    t.bigint "buffet_tier_id"
    t.bigint "buffet_cover_line_id"
    t.string "price_label", limit: 40
    t.index ["buffet_cover_line_id"], name: "idx_pos_sale_lines_buffet_cover", where: "(buffet_cover_line_id IS NOT NULL)"
    t.index ["line_item_id"], name: "index_spree_pos_sale_lines_on_line_item_id", unique: true
    t.index ["order_id"], name: "index_spree_pos_sale_lines_on_order_id"
    t.index ["variant_id"], name: "index_spree_pos_sale_lines_on_variant_id"
    t.index ["workspace_id", "append_batch_id"], name: "idx_pos_sale_lines_append_batch", where: "(append_batch_id IS NOT NULL)"
    t.index ["workspace_id", "course"], name: "idx_pos_sale_lines_held", where: "((course_status)::text = 'held'::text)"
    t.index ["workspace_id", "measurement_event_id"], name: "idx_pos_sale_lines_event", unique: true, where: "(measurement_event_id IS NOT NULL)"
    t.index ["workspace_id", "merge_key"], name: "idx_pos_sale_lines_merge"
    t.index ["workspace_id"], name: "index_spree_pos_sale_lines_on_workspace_id"
    t.check_constraint "(course_status::text = ANY (ARRAY['none'::character varying, 'held'::character varying, 'fired'::character varying]::text[])) AND (course IS NULL OR course >= 1 AND course <= 9) AND (seat IS NULL OR seat >= 1 AND seat <= 99) AND (course_status::text = 'none'::text OR course IS NOT NULL)", name: "chk_pos_sale_lines_course_seat"
    t.check_constraint "base_quantity > 0 AND sale_quantity > 0::numeric", name: "chk_pos_sale_lines_qty"
    t.check_constraint "kind::text = ANY (ARRAY['ordinary'::character varying::text, 'measured'::character varying::text, 'tracked'::character varying::text, 'menu'::character varying::text, 'timed'::character varying::text, 'cover'::character varying::text])", name: "chk_pos_sale_lines_kind"
    t.check_constraint "kitchen_sent_quantity <= sale_quantity", name: "chk_pos_sale_lines_kitchen_sent_within_sale"
    t.check_constraint "kitchen_sent_quantity >= 0::numeric", name: "chk_pos_sale_lines_kitchen_sent"
    t.check_constraint "tracked_mode::text = ANY (ARRAY['none'::character varying::text, 'serial'::character varying::text, 'lot'::character varying::text])", name: "chk_pos_sale_lines_tracked"
  end

  create_table "spree_pos_serial_units", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.string "serial", limit: 100, null: false
    t.string "status", limit: 16, default: "in_stock", null: false
    t.string "quarantine_reason", limit: 200
    t.datetime "returned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_location_id"], name: "index_spree_pos_serial_units_on_stock_location_id"
    t.index ["store_id", "serial"], name: "idx_pos_serial_units_recall"
    t.index ["store_id", "variant_id", "serial"], name: "idx_pos_serial_units_identity", unique: true
    t.index ["variant_id"], name: "index_spree_pos_serial_units_on_variant_id"
    t.check_constraint "status::text = ANY (ARRAY['in_stock'::character varying::text, 'reserved'::character varying::text, 'sold'::character varying::text, 'returned'::character varying::text, 'quarantined'::character varying::text, 'removed'::character varying::text])", name: "chk_pos_serial_units_status"
  end

  create_table "spree_pos_shift_closures", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "shift_id", null: false
    t.bigint "closer_id", null: false
    t.bigint "approver_id"
    t.bigint "approval_id"
    t.string "currency", limit: 16, null: false
    t.decimal "opening_float", precision: 19, scale: 4, null: false
    t.decimal "inflow_total", precision: 19, scale: 4, null: false
    t.decimal "outflow_total", precision: 19, scale: 4, null: false
    t.decimal "expected", precision: 19, scale: 4, null: false
    t.decimal "counted", precision: 19, scale: 4, null: false
    t.decimal "variance", precision: 19, scale: 4, null: false
    t.decimal "variance_threshold", precision: 19, scale: 4
    t.string "reason", limit: 200
    t.bigint "cutoff_movement_id"
    t.integer "movement_count", default: 0, null: false
    t.jsonb "breakdown", default: {}, null: false
    t.datetime "opened_at", null: false
    t.datetime "closed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "closed_at"], name: "idx_pos_shift_closures_branch_closed"
    t.index ["closer_id"], name: "index_spree_pos_shift_closures_on_closer_id"
    t.index ["register_id"], name: "index_spree_pos_shift_closures_on_register_id"
    t.index ["shift_id"], name: "index_spree_pos_shift_closures_on_shift_id", unique: true
    t.index ["store_id"], name: "index_spree_pos_shift_closures_on_store_id"
    t.check_constraint "counted >= 0::numeric AND inflow_total >= 0::numeric AND outflow_total >= 0::numeric", name: "chk_pos_shift_closures_amounts"
    t.check_constraint "expected = (opening_float + inflow_total - outflow_total)", name: "chk_pos_shift_closures_expected"
    t.check_constraint "variance = (counted - expected)", name: "chk_pos_shift_closures_variance"
  end

  create_table "spree_pos_shifts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "owner_id", null: false
    t.decimal "opening_float", precision: 19, scale: 4, null: false
    t.string "currency", null: false
    t.string "status", default: "open", null: false
    t.datetime "opened_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "revision", default: 0, null: false
    t.decimal "closing_counted", precision: 19, scale: 4
    t.string "closing_reason", limit: 200
    t.bigint "closing_counted_by_id"
    t.datetime "closing_counted_at"
    t.datetime "closed_at"
    t.bigint "closing_cutoff_movement_id"
    t.date "business_date", null: false
    t.index ["branch_id", "business_date"], name: "idx_pos_shifts_branch_business_date"
    t.index ["branch_id"], name: "index_spree_pos_shifts_on_branch_id"
    t.index ["owner_id"], name: "index_spree_pos_shifts_on_owner_id"
    t.index ["register_id"], name: "idx_spree_pos_shifts_one_open_register", unique: true, where: "((status)::text = 'open'::text)"
    t.index ["register_id"], name: "index_spree_pos_shifts_on_register_id"
    t.index ["store_id", "branch_id", "owner_id"], name: "idx_spree_pos_shifts_one_open_branch_owner", unique: true, where: "(((status)::text = 'open'::text) AND (register_id IS NULL))"
    t.index ["store_id"], name: "index_spree_pos_shifts_on_store_id"
    t.check_constraint "closing_counted IS NULL OR closing_counted >= 0::numeric", name: "chk_pos_shifts_closing_counted"
    t.check_constraint "opening_float >= 0::numeric", name: "chk_spree_pos_shifts_opening_float_nonnegative"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying::text, 'closed'::character varying::text])", name: "chk_spree_pos_shifts_status"
  end

  create_table "spree_pos_staff_memberships", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "staff_id", null: false
    t.jsonb "capabilities", default: [], null: false
    t.string "status", default: "active", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "staff_role_id"
    t.string "pin_digest"
    t.datetime "pin_set_at"
    t.index ["branch_id"], name: "index_spree_pos_staff_memberships_on_branch_id"
    t.index ["staff_id"], name: "index_spree_pos_staff_memberships_on_staff_id"
    t.index ["staff_role_id"], name: "index_spree_pos_staff_memberships_on_staff_role_id"
    t.index ["store_id", "branch_id", "staff_id"], name: "idx_spree_pos_memberships_staff_branch", unique: true
    t.index ["store_id"], name: "index_spree_pos_staff_memberships_on_store_id"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_spree_pos_memberships_status"
  end

  create_table "spree_pos_staff_roles", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", limit: 80, null: false
    t.jsonb "capabilities", default: [], null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "store_id, lower((name)::text)", name: "idx_pos_staff_roles_store_name", unique: true
    t.index ["store_id"], name: "index_spree_pos_staff_roles_on_store_id"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'disabled'::character varying::text])", name: "chk_pos_staff_roles_status"
  end

  create_table "spree_pos_station_routes", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "kitchen_station_id", null: false
    t.bigint "product_id"
    t.string "kitchen_category", limit: 40
    t.string "service_mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "branch_id, COALESCE(product_id, (0)::bigint), COALESCE(kitchen_category, ''::character varying), COALESCE(service_mode, ''::character varying)", name: "idx_pos_station_routes_target", unique: true
    t.index ["branch_id"], name: "index_spree_pos_station_routes_on_branch_id"
    t.index ["kitchen_station_id"], name: "index_spree_pos_station_routes_on_kitchen_station_id"
    t.index ["product_id"], name: "index_spree_pos_station_routes_on_product_id"
    t.index ["store_id"], name: "index_spree_pos_station_routes_on_store_id"
    t.check_constraint "(product_id IS NULL) <> (kitchen_category IS NULL)", name: "chk_pos_station_routes_target"
    t.check_constraint "service_mode IS NULL OR (service_mode::text = ANY (ARRAY['counter'::character varying, 'dine_in'::character varying, 'takeaway'::character varying, 'delivery'::character varying, 'tab'::character varying, 'timed'::character varying]::text[]))", name: "chk_pos_station_routes_mode"
  end

  create_table "spree_pos_stock_alerts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "variant_id", null: false
    t.integer "min_quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "variant_id"], name: "idx_pos_stock_alerts_variant", unique: true
    t.index ["branch_id"], name: "index_spree_pos_stock_alerts_on_branch_id"
    t.index ["store_id"], name: "index_spree_pos_stock_alerts_on_store_id"
    t.index ["variant_id"], name: "index_spree_pos_stock_alerts_on_variant_id"
    t.check_constraint "min_quantity > 0", name: "chk_pos_stock_alerts_min"
  end

  create_table "spree_pos_stock_discrepancies", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "order_id", null: false
    t.bigint "fulfillment_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "actor_id", null: false
    t.integer "needed", null: false
    t.integer "on_hand", null: false
    t.string "status", limit: 16, default: "open", null: false
    t.datetime "checked_at", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source", limit: 16, default: "handover", null: false
    t.index ["actor_id"], name: "index_spree_pos_stock_discrepancies_on_actor_id"
    t.index ["branch_id"], name: "index_spree_pos_stock_discrepancies_on_branch_id"
    t.index ["fulfillment_id", "variant_id", "source"], name: "idx_pos_stock_discrepancies_open", unique: true, where: "((status)::text = 'open'::text)"
    t.index ["fulfillment_id"], name: "index_spree_pos_stock_discrepancies_on_fulfillment_id"
    t.index ["order_id"], name: "index_spree_pos_stock_discrepancies_on_order_id"
    t.index ["stock_location_id"], name: "index_spree_pos_stock_discrepancies_on_stock_location_id"
    t.index ["store_id"], name: "index_spree_pos_stock_discrepancies_on_store_id"
    t.index ["variant_id"], name: "index_spree_pos_stock_discrepancies_on_variant_id"
    t.index ["workspace_id"], name: "index_spree_pos_stock_discrepancies_on_workspace_id"
    t.check_constraint "needed > 0", name: "chk_pos_stock_discrepancies_needed"
    t.check_constraint "source::text = ANY (ARRAY['handover'::character varying, 'recipe'::character varying]::text[])", name: "chk_pos_stock_discrepancies_source"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying::text, 'resolved'::character varying::text])", name: "chk_pos_stock_discrepancies_status"
  end

  create_table "spree_pos_store_profiles", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "profile_key", limit: 40, null: false
    t.integer "profile_version", default: 1, null: false
    t.boolean "wholesale", default: false, null: false
    t.string "interests", default: [], null: false, array: true
    t.datetime "onboarded_at"
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "einvoice_type", limit: 16, default: "none", null: false
    t.bigint "food_tax_category_id"
    t.bigint "alcohol_tax_category_id"
    t.index ["store_id"], name: "index_spree_pos_store_profiles_on_store_id", unique: true
    t.check_constraint "einvoice_type::text = ANY (ARRAY['none'::character varying, 'cash_register'::character varying, 'coded'::character varying]::text[])", name: "chk_pos_store_profiles_einvoice_type"
    t.check_constraint "profile_version >= 1", name: "chk_pos_store_profiles_version"
  end

  create_table "spree_pos_tax_rate_schedules", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "tax_rate_id", null: false
    t.decimal "amount", precision: 8, scale: 5, null: false
    t.date "effective_on", null: false
    t.datetime "applied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_spree_pos_tax_rate_schedules_on_store_id"
    t.index ["tax_rate_id", "effective_on"], name: "idx_pos_tax_rate_schedules_rate_day", unique: true
    t.index ["tax_rate_id"], name: "index_spree_pos_tax_rate_schedules_on_tax_rate_id"
  end

  create_table "spree_pos_tender_attempts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "shift_id", null: false
    t.bigint "pos_payment_method_id", null: false
    t.bigint "actor_id", null: false
    t.string "status", default: "prepared", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.decimal "order_total_snapshot", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.integer "workspace_revision", null: false
    t.jsonb "snapshot", default: {}, null: false
    t.datetime "confirmed_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_spree_pos_tender_attempts_on_actor_id"
    t.index ["branch_id", "created_at"], name: "idx_pos_tender_attempts_unresolved", where: "((status)::text = ANY (ARRAY[('prepared'::character varying)::text, ('unknown'::character varying)::text]))"
    t.index ["branch_id"], name: "index_spree_pos_tender_attempts_on_branch_id"
    t.index ["pos_payment_method_id"], name: "index_spree_pos_tender_attempts_on_pos_payment_method_id"
    t.index ["register_id"], name: "index_spree_pos_tender_attempts_on_register_id"
    t.index ["shift_id"], name: "index_spree_pos_tender_attempts_on_shift_id"
    t.index ["store_id"], name: "index_spree_pos_tender_attempts_on_store_id"
    t.index ["workspace_id", "status"], name: "idx_pos_tender_attempts_workspace_status"
    t.index ["workspace_id"], name: "index_spree_pos_tender_attempts_on_workspace_id"
    t.check_constraint "amount > 0::numeric AND order_total_snapshot >= 0::numeric", name: "chk_pos_tender_attempts_amount"
    t.check_constraint "status::text = ANY (ARRAY['prepared'::character varying::text, 'confirmed'::character varying::text, 'canceled'::character varying::text, 'unknown'::character varying::text, 'failed'::character varying::text])", name: "chk_pos_tender_attempts_status"
  end

  create_table "spree_pos_tip_records", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "received_funds_id", null: false
    t.bigint "shift_id", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.string "currency", limit: 16, null: false
    t.date "business_date", null: false
    t.string "status", default: "held", null: false
    t.bigint "liability_payout_id"
    t.datetime "paid_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "business_date", "status"], name: "idx_pos_tip_records_day"
    t.index ["liability_payout_id"], name: "index_spree_pos_tip_records_on_liability_payout_id"
    t.index ["received_funds_id"], name: "index_spree_pos_tip_records_on_received_funds_id", unique: true
    t.index ["shift_id"], name: "index_spree_pos_tip_records_on_shift_id"
    t.index ["workspace_id"], name: "index_spree_pos_tip_records_on_workspace_id"
    t.check_constraint "amount > 0::numeric AND (status::text = ANY (ARRAY['held'::character varying, 'paid_out'::character varying]::text[]))", name: "chk_pos_tip_records_values"
  end

  create_table "spree_pos_tip_split_rules", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.string "mode", default: "equal", null: false
    t.jsonb "role_codes", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_spree_pos_tip_split_rules_on_branch_id", unique: true
    t.check_constraint "mode::text = ANY (ARRAY['equal'::character varying, 'by_hours'::character varying, 'manual'::character varying]::text[])", name: "chk_pos_tip_split_rules_mode"
  end

  create_table "spree_pos_trace_allocations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "sale_line_id", null: false
    t.bigint "order_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "inventory_lot_id"
    t.bigint "serial_unit_id"
    t.bigint "fulfillment_item_id"
    t.string "status", limit: 16, default: "reserved", null: false
    t.bigint "quantity", null: false
    t.bigint "returned_quantity", default: 0, null: false
    t.integer "lease_generation", null: false
    t.boolean "picked", default: false, null: false
    t.datetime "expires_at"
    t.datetime "committed_at"
    t.datetime "consumed_at"
    t.datetime "released_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fulfillment_item_id"], name: "index_spree_pos_trace_allocations_on_fulfillment_item_id"
    t.index ["inventory_lot_id", "status"], name: "idx_pos_trace_allocations_lot_status"
    t.index ["inventory_lot_id"], name: "index_spree_pos_trace_allocations_on_inventory_lot_id"
    t.index ["order_id"], name: "index_spree_pos_trace_allocations_on_order_id"
    t.index ["sale_line_id"], name: "index_spree_pos_trace_allocations_on_sale_line_id"
    t.index ["serial_unit_id"], name: "idx_pos_trace_allocations_live_serial", unique: true, where: "((status)::text = ANY (ARRAY[('reserved'::character varying)::text, ('committed'::character varying)::text]))"
    t.index ["serial_unit_id"], name: "idx_pos_trace_allocations_serial"
    t.index ["status", "expires_at"], name: "idx_pos_trace_allocations_expiry"
    t.index ["workspace_id"], name: "index_spree_pos_trace_allocations_on_workspace_id"
    t.check_constraint "(inventory_lot_id IS NULL) <> (serial_unit_id IS NULL)", name: "chk_pos_trace_allocations_subject"
    t.check_constraint "quantity > 0 AND returned_quantity >= 0 AND returned_quantity <= quantity AND (serial_unit_id IS NULL OR quantity = 1)", name: "chk_pos_trace_allocations_quantity"
    t.check_constraint "status::text = ANY (ARRAY['reserved'::character varying::text, 'committed'::character varying::text, 'consumed'::character varying::text, 'released'::character varying::text])", name: "chk_pos_trace_allocations_status"
  end

  create_table "spree_pos_trace_enrollments", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "opened_by_id", null: false
    t.string "tracked_mode", limit: 16, null: false
    t.bigint "opening_quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "drift_signature", limit: 64
    t.datetime "drift_checked_at"
    t.index ["branch_id"], name: "index_spree_pos_trace_enrollments_on_branch_id"
    t.index ["opened_by_id"], name: "index_spree_pos_trace_enrollments_on_opened_by_id"
    t.index ["stock_location_id"], name: "index_spree_pos_trace_enrollments_on_stock_location_id"
    t.index ["store_id"], name: "index_spree_pos_trace_enrollments_on_store_id"
    t.index ["variant_id", "stock_location_id"], name: "idx_pos_trace_enrollments_pair", unique: true
    t.check_constraint "opening_quantity >= 0", name: "chk_pos_trace_enrollments_opening"
    t.check_constraint "tracked_mode::text = ANY (ARRAY['serial'::character varying::text, 'lot'::character varying::text])", name: "chk_pos_trace_enrollments_mode"
  end

  create_table "spree_pos_trace_returns", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "return_operation_id", null: false
    t.bigint "trace_allocation_id", null: false
    t.bigint "return_lot_id"
    t.bigint "quantity", null: false
    t.string "condition", limit: 16, null: false
    t.string "status", limit: 16, default: "reserved", null: false
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["return_lot_id"], name: "index_spree_pos_trace_returns_on_return_lot_id"
    t.index ["return_operation_id"], name: "index_spree_pos_trace_returns_on_return_operation_id"
    t.index ["trace_allocation_id"], name: "index_spree_pos_trace_returns_on_trace_allocation_id"
    t.check_constraint "condition::text = ANY (ARRAY['resellable'::character varying::text, 'damaged'::character varying::text])", name: "chk_pos_trace_returns_condition"
    t.check_constraint "quantity > 0", name: "chk_pos_trace_returns_quantity"
    t.check_constraint "status::text = ANY (ARRAY['reserved'::character varying::text, 'received'::character varying::text, 'canceled'::character varying::text])", name: "chk_pos_trace_returns_status"
  end

  create_table "spree_pos_units", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "code", limit: 16, null: false
    t.string "name", limit: 64, null: false
    t.string "dimension", limit: 16, null: false
    t.string "base_code", limit: 16, null: false
    t.integer "factor_to_base", null: false
    t.integer "sale_precision", default: 0, null: false
    t.integer "version", default: 1, null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "code"], name: "idx_pos_units_store_code", unique: true
    t.index ["store_id"], name: "index_spree_pos_units_on_store_id"
    t.check_constraint "dimension::text = ANY (ARRAY['mass'::character varying::text, 'volume'::character varying::text, 'count'::character varying::text])", name: "chk_pos_units_dimension"
    t.check_constraint "factor_to_base > 0 AND sale_precision >= 0 AND sale_precision <= 3", name: "chk_pos_units_factor"
  end

  create_table "spree_pos_variant_units", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "variant_id", null: false
    t.bigint "sale_unit_id", null: false
    t.bigint "base_unit_id", null: false
    t.bigint "price_unit_id", null: false
    t.integer "ratio_numerator", null: false
    t.integer "ratio_denominator", default: 1, null: false
    t.string "tracked_mode", default: "none", null: false
    t.integer "version", default: 1, null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label_code"
    t.index ["base_unit_id"], name: "index_spree_pos_variant_units_on_base_unit_id"
    t.index ["price_unit_id"], name: "index_spree_pos_variant_units_on_price_unit_id"
    t.index ["sale_unit_id"], name: "index_spree_pos_variant_units_on_sale_unit_id"
    t.index ["store_id", "label_code"], name: "idx_pos_variant_units_label_code", unique: true, where: "(label_code IS NOT NULL)"
    t.index ["store_id"], name: "index_spree_pos_variant_units_on_store_id"
    t.index ["variant_id"], name: "index_spree_pos_variant_units_on_variant_id", unique: true
    t.check_constraint "ratio_numerator > 0 AND ratio_denominator > 0", name: "chk_pos_variant_units_ratio"
    t.check_constraint "tracked_mode::text = ANY (ARRAY['none'::character varying::text, 'serial'::character varying::text, 'lot'::character varying::text])", name: "chk_pos_variant_units_tracked"
  end

  create_table "spree_pos_workspaces", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "register_id"
    t.bigint "shift_id", null: false
    t.bigint "order_id", null: false
    t.integer "revision", default: 0, null: false
    t.integer "lease_generation", default: 0, null: false
    t.bigint "lease_holder_id"
    t.datetime "lease_expires_at"
    t.string "operational_status", default: "editing", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lease_editor_digest"
    t.bigint "pos_customer_id"
    t.text "note"
    t.string "order_source", limit: 20, default: "counter", null: false
    t.string "service_mode", default: "counter", null: false
    t.date "business_date", null: false
    t.integer "order_number"
    t.string "guest_name", limit: 60
    t.bigint "resource_id"
    t.integer "guest_count"
    t.string "table_label", limit: 4
    t.boolean "service_charge_waived", default: false, null: false
    t.string "tab_name", limit: 60
    t.boolean "minimum_spend_waived", default: false, null: false
    t.index "branch_id, lower((tab_name)::text)", name: "idx_pos_workspaces_open_tab_name", where: "((tab_name IS NOT NULL) AND ((operational_status)::text = ANY ((ARRAY['editing'::character varying, 'parked'::character varying])::text[])))"
    t.index ["branch_id", "business_date", "order_number"], name: "idx_pos_workspaces_order_number", unique: true, where: "(order_number IS NOT NULL)"
    t.index ["branch_id", "business_date"], name: "idx_pos_workspaces_branch_business_date"
    t.index ["branch_id"], name: "index_spree_pos_workspaces_on_branch_id"
    t.index ["lease_holder_id"], name: "index_spree_pos_workspaces_on_lease_holder_id"
    t.index ["order_id"], name: "index_spree_pos_workspaces_on_order_id", unique: true
    t.index ["pos_customer_id"], name: "index_spree_pos_workspaces_on_pos_customer_id"
    t.index ["register_id"], name: "index_spree_pos_workspaces_on_register_id"
    t.index ["resource_id", "operational_status"], name: "idx_pos_workspaces_resource_status"
    t.index ["shift_id"], name: "index_spree_pos_workspaces_on_shift_id"
    t.index ["store_id"], name: "index_spree_pos_workspaces_on_store_id"
    t.check_constraint "guest_count IS NULL OR guest_count >= 0 AND guest_count <= 999", name: "chk_pos_workspaces_guest_count"
    t.check_constraint "note IS NULL OR char_length(note) <= 1000", name: "chk_pos_workspace_note_length"
    t.check_constraint "operational_status::text = ANY (ARRAY['editing'::character varying::text, 'parked'::character varying::text, 'canceled'::character varying::text, 'completed'::character varying::text])", name: "chk_spree_pos_workspaces_status"
    t.check_constraint "order_number IS NULL OR order_number > 0", name: "chk_pos_workspaces_order_number"
    t.check_constraint "order_source::text = ANY (ARRAY['counter'::character varying, 'facebook'::character varying, 'zalo'::character varying, 'other'::character varying, 'grabfood'::character varying, 'shopeefood'::character varying]::text[])", name: "chk_pos_workspace_order_source"
    t.check_constraint "resource_id IS NULL OR (service_mode::text = ANY (ARRAY['dine_in'::character varying, 'timed'::character varying]::text[]))", name: "chk_pos_workspaces_resource_mode"
    t.check_constraint "service_mode::text = ANY (ARRAY['counter'::character varying::text, 'dine_in'::character varying::text, 'takeaway'::character varying::text, 'delivery'::character varying::text, 'tab'::character varying::text, 'timed'::character varying::text])", name: "chk_pos_workspace_service_mode"
  end

  create_table "spree_price_adjustment_tiers", force: :cascade do |t|
    t.bigint "price_list_id", null: false
    t.integer "min_quantity", default: 1, null: false
    t.decimal "percentage", precision: 6, scale: 3, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["price_list_id", "min_quantity"], name: "index_spree_price_adjustment_tiers_on_list_and_quantity", unique: true
  end

  create_table "spree_price_histories", force: :cascade do |t|
    t.bigint "price_id", null: false
    t.bigint "variant_id", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.decimal "compare_at_amount", precision: 19, scale: 4
    t.string "currency", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.index ["price_id", "recorded_at"], name: "idx_price_histories_price_recorded"
    t.index ["recorded_at"], name: "idx_price_histories_recorded_at"
    t.index ["variant_id", "currency", "recorded_at"], name: "idx_price_histories_variant_currency_recorded"
  end

  create_table "spree_price_lists", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.string "status", default: "draft", null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "match_policy", default: "all", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "catalog_id"
    t.decimal "price_adjustment_percentage", precision: 6, scale: 3
    t.boolean "adjust_compare_at", default: false, null: false
    t.index ["catalog_id"], name: "index_spree_price_lists_one_per_catalog", unique: true, where: "((catalog_id IS NOT NULL) AND (deleted_at IS NULL))"
    t.index ["deleted_at"], name: "index_spree_price_lists_on_deleted_at"
    t.index ["position"], name: "index_spree_price_lists_on_position"
    t.index ["starts_at", "ends_at"], name: "index_spree_price_lists_on_starts_at_and_ends_at"
    t.index ["status"], name: "index_spree_price_lists_on_status"
    t.index ["store_id", "status", "position"], name: "index_spree_price_lists_on_store_id_and_status_and_position"
    t.index ["store_id"], name: "index_spree_price_lists_on_store_id"
  end

  create_table "spree_price_rules", force: :cascade do |t|
    t.bigint "price_list_id", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "preferences"
    t.index ["price_list_id", "type"], name: "index_spree_price_rules_on_price_list_id_and_type", unique: true
    t.index ["price_list_id"], name: "index_spree_price_rules_on_price_list_id"
    t.index ["type"], name: "index_spree_price_rules_on_type"
  end

  create_table "spree_prices", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.decimal "amount", precision: 19, scale: 4
    t.string "currency"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "compare_at_amount", precision: 19, scale: 4
    t.bigint "price_list_id"
    t.integer "min_quantity", default: 1, null: false
    t.index ["deleted_at"], name: "index_spree_prices_on_deleted_at"
    t.index ["price_list_id"], name: "index_spree_prices_on_price_list_id"
    t.index ["variant_id", "currency", "price_list_id", "min_quantity"], name: "index_spree_prices_on_variant_currency_list_quantity", unique: true, where: "((price_list_id IS NOT NULL) AND (deleted_at IS NULL) AND (amount IS NOT NULL))"
    t.index ["variant_id", "currency"], name: "index_spree_prices_on_variant_id_and_currency", unique: true, where: "((price_list_id IS NULL) AND (deleted_at IS NULL) AND (amount IS NOT NULL))"
    t.index ["variant_id"], name: "index_spree_prices_on_variant_id"
  end

  create_table "spree_product_categories", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "category_id"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_spree_product_categories_on_category_id"
    t.index ["position"], name: "index_spree_product_categories_on_position"
    t.index ["product_id", "category_id"], name: "index_spree_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_spree_product_categories_on_product_id"
  end

  create_table "spree_product_collections", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "collection_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "product_id"], name: "index_product_collections_on_collection_and_product", unique: true
    t.index ["collection_id"], name: "index_spree_product_collections_on_collection_id"
    t.index ["product_id"], name: "index_spree_product_collections_on_product_id"
  end

  create_table "spree_product_option_types", force: :cascade do |t|
    t.integer "position"
    t.bigint "product_id"
    t.bigint "option_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["option_type_id"], name: "index_spree_product_option_types_on_option_type_id"
    t.index ["position"], name: "index_spree_product_option_types_on_position"
    t.index ["product_id"], name: "index_spree_product_option_types_on_product_id"
  end

  create_table "spree_product_promotion_rules", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "promotion_rule_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["product_id", "promotion_rule_id"], name: "idx_on_product_id_promotion_rule_id_aaea0385c9", unique: true
    t.index ["product_id"], name: "index_products_promotion_rules_on_product_id"
    t.index ["promotion_rule_id", "product_id"], name: "index_products_promotion_rules_on_promotion_rule_and_product"
  end

  create_table "spree_product_publications", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "channel_id", null: false
    t.datetime "published_at"
    t.datetime "unpublished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_spree_product_publications_on_channel_id"
    t.index ["product_id", "channel_id"], name: "index_spree_product_publications_on_product_and_channel", unique: true
    t.index ["product_id"], name: "index_spree_product_publications_on_product_id"
  end

  create_table "spree_product_submissions", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "status", null: false
    t.bigint "submitted_by_id"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.text "review_note"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "created_at"], name: "index_spree_product_submissions_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_spree_product_submissions_on_product_id"
    t.index ["reviewed_by_id"], name: "index_spree_product_submissions_on_reviewed_by_id"
    t.index ["submitted_by_id"], name: "index_spree_product_submissions_on_submitted_by_id"
  end

  create_table "spree_product_translations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "locale", null: false
    t.bigint "spree_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "meta_description"
    t.string "meta_keywords"
    t.string "meta_title"
    t.string "slug"
    t.datetime "deleted_at", precision: nil
    t.index ["deleted_at"], name: "index_spree_product_translations_on_deleted_at"
    t.index ["locale", "slug"], name: "unique_slug_per_locale", unique: true
    t.index ["locale"], name: "index_spree_product_translations_on_locale"
    t.index ["spree_product_id", "locale"], name: "unique_product_id_per_locale", unique: true
  end

  create_table "spree_product_type_categories", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "product_type_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_product_type_categories_on_category_id"
    t.index ["product_type_id", "category_id"], name: "index_product_type_categories_uniqueness", unique: true
  end

  create_table "spree_product_type_custom_field_definitions", force: :cascade do |t|
    t.bigint "product_type_id", null: false
    t.bigint "custom_field_definition_id", null: false
    t.boolean "required", default: false, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_definition_id"], name: "idx_on_custom_field_definition_id_8b23a96514"
    t.index ["product_type_id", "custom_field_definition_id"], name: "idx_product_type_cf_defs_unique", unique: true
  end

  create_table "spree_product_type_translations", force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.bigint "spree_product_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_spree_product_type_translations_on_locale"
    t.index ["spree_product_type_id", "locale"], name: "index_product_type_translations_on_product_type_and_locale", unique: true
  end

  create_table "spree_product_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
    t.bigint "store_id"
    t.integer "products_count", default: 0, null: false
    t.bigint "delivery_profile_id"
    t.index ["delivery_profile_id"], name: "index_spree_product_types_on_delivery_profile_id"
    t.index ["store_id"], name: "index_spree_product_types_on_store_id"
  end

  create_table "spree_products", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.text "description"
    t.datetime "available_on", precision: nil
    t.datetime "deleted_at", precision: nil
    t.string "slug"
    t.text "meta_description"
    t.string "meta_keywords"
    t.bigint "tax_category_id"
    t.bigint "delivery_profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "promotionable", default: true
    t.string "meta_title"
    t.datetime "discontinue_on", precision: nil
    t.jsonb "metadata"
    t.string "status", default: "draft", null: false
    t.datetime "make_active_at", precision: nil
    t.integer "variant_count", default: 0, null: false
    t.integer "categories_count", default: 0, null: false
    t.integer "media_count", default: 0, null: false
    t.bigint "primary_media_id"
    t.bigint "store_id"
    t.integer "units_sold_count", default: 0, null: false
    t.decimal "revenue", precision: 19, scale: 4, default: "0.0", null: false
    t.bigint "default_variant_id"
    t.integer "collections_count", default: 0, null: false
    t.bigint "product_type_id"
    t.bigint "seller_id"
    t.index ["available_on"], name: "index_spree_products_on_available_on"
    t.index ["categories_count"], name: "index_spree_products_on_categories_count"
    t.index ["default_variant_id"], name: "index_spree_products_on_default_variant_id"
    t.index ["deleted_at"], name: "index_spree_products_on_deleted_at"
    t.index ["delivery_profile_id"], name: "index_spree_products_on_delivery_profile_id"
    t.index ["discontinue_on"], name: "index_spree_products_on_discontinue_on"
    t.index ["make_active_at"], name: "index_spree_products_on_make_active_at"
    t.index ["media_count"], name: "index_spree_products_on_media_count"
    t.index ["name"], name: "index_spree_products_on_name"
    t.index ["primary_media_id"], name: "index_spree_products_on_primary_media_id"
    t.index ["product_type_id"], name: "index_spree_products_on_product_type_id"
    t.index ["promotionable"], name: "index_spree_products_on_promotionable"
    t.index ["seller_id"], name: "index_spree_products_on_seller_id"
    t.index ["slug"], name: "index_spree_products_on_slug", unique: true
    t.index ["status", "deleted_at"], name: "index_spree_products_on_status_and_deleted_at"
    t.index ["status"], name: "index_spree_products_on_status"
    t.index ["store_id", "units_sold_count"], name: "index_spree_products_on_store_id_and_units_sold_count"
    t.index ["store_id"], name: "index_spree_products_on_store_id"
    t.index ["tax_category_id"], name: "index_spree_products_on_tax_category_id"
    t.index ["variant_count"], name: "index_spree_products_on_variant_count"
  end

  create_table "spree_products_stores", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "store_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "units_sold_count", default: 0, null: false
    t.decimal "revenue", precision: 19, scale: 4, default: "0.0", null: false
    t.index ["product_id", "store_id"], name: "index_spree_products_stores_on_product_id_and_store_id", unique: true
    t.index ["product_id"], name: "index_spree_products_stores_on_product_id"
    t.index ["store_id", "revenue"], name: "index_products_stores_on_store_and_revenue"
    t.index ["store_id", "units_sold_count"], name: "index_products_stores_on_store_and_units_sold"
    t.index ["store_id"], name: "index_spree_products_stores_on_store_id"
  end

  create_table "spree_promotion_action_line_items", force: :cascade do |t|
    t.bigint "promotion_action_id"
    t.bigint "variant_id"
    t.integer "quantity", default: 1
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["promotion_action_id", "variant_id"], name: "idx_on_promotion_action_id_variant_id_90d181a88a", unique: true
    t.index ["promotion_action_id"], name: "index_spree_promotion_action_line_items_on_promotion_action_id"
    t.index ["variant_id"], name: "index_spree_promotion_action_line_items_on_variant_id"
  end

  create_table "spree_promotion_actions", force: :cascade do |t|
    t.bigint "promotion_id"
    t.integer "position"
    t.string "type"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["deleted_at"], name: "index_spree_promotion_actions_on_deleted_at"
    t.index ["id", "type"], name: "index_spree_promotion_actions_on_id_and_type"
    t.index ["promotion_id"], name: "index_spree_promotion_actions_on_promotion_id"
  end

  create_table "spree_promotion_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "spree_promotion_rule_categories", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "promotion_rule_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id", "promotion_rule_id"], name: "idx_on_category_id_promotion_rule_id_530c96f872", unique: true
    t.index ["category_id"], name: "index_spree_promotion_rule_categories_on_category_id"
    t.index ["promotion_rule_id"], name: "index_spree_promotion_rule_categories_on_promotion_rule_id"
  end

  create_table "spree_promotion_rule_users", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "promotion_rule_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["customer_id", "promotion_rule_id"], name: "idx_on_customer_id_promotion_rule_id_90bd732c00", unique: true
    t.index ["customer_id", "promotion_rule_id"], name: "index_promotion_rules_users_on_user_id_and_promotion_rule_id"
    t.index ["promotion_rule_id"], name: "index_promotion_rules_users_on_promotion_rule_id"
  end

  create_table "spree_promotion_rules", force: :cascade do |t|
    t.bigint "promotion_id"
    t.bigint "user_id"
    t.bigint "product_group_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.jsonb "preferences"
    t.index ["product_group_id"], name: "index_promotion_rules_on_product_group_id"
    t.index ["promotion_id", "type"], name: "index_spree_promotion_rules_on_promotion_id_and_type", unique: true
    t.index ["promotion_id"], name: "index_spree_promotion_rules_on_promotion_id"
    t.index ["user_id"], name: "index_promotion_rules_on_user_id"
  end

  create_table "spree_promotions", force: :cascade do |t|
    t.string "description"
    t.datetime "expires_at", precision: nil
    t.datetime "starts_at", precision: nil
    t.string "name"
    t.string "type"
    t.integer "usage_limit"
    t.string "match_policy", default: "all"
    t.string "code"
    t.boolean "advertise", default: false
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "promotion_category_id"
    t.jsonb "metadata"
    t.string "code_prefix"
    t.integer "number_of_codes"
    t.integer "kind", default: 0
    t.boolean "multi_codes", default: false
    t.bigint "store_id"
    t.index ["advertise"], name: "index_spree_promotions_on_advertise"
    t.index ["code"], name: "index_spree_promotions_on_code"
    t.index ["expires_at"], name: "index_spree_promotions_on_expires_at"
    t.index ["id", "type"], name: "index_spree_promotions_on_id_and_type"
    t.index ["kind"], name: "index_spree_promotions_on_kind"
    t.index ["path"], name: "index_spree_promotions_on_path"
    t.index ["promotion_category_id"], name: "index_spree_promotions_on_promotion_category_id"
    t.index ["starts_at"], name: "index_spree_promotions_on_starts_at"
    t.index ["store_id"], name: "index_spree_promotions_on_store_id"
  end

  create_table "spree_promotions_stores", force: :cascade do |t|
    t.bigint "promotion_id"
    t.bigint "store_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["promotion_id", "store_id"], name: "index_spree_promotions_stores_on_promotion_id_and_store_id", unique: true
    t.index ["promotion_id"], name: "index_spree_promotions_stores_on_promotion_id"
    t.index ["store_id"], name: "index_spree_promotions_stores_on_store_id"
  end

  create_table "spree_purchase_order_items", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.bigint "variant_id", null: false
    t.integer "quantity_ordered", default: 0, null: false
    t.integer "quantity_received", default: 0, null: false
    t.decimal "unit_cost", precision: 19, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity_rejected", default: 0, null: false
    t.index ["purchase_order_id", "variant_id"], name: "idx_purchase_order_items_unique", unique: true
    t.index ["purchase_order_id"], name: "index_spree_purchase_order_items_on_purchase_order_id"
    t.index ["variant_id"], name: "index_spree_purchase_order_items_on_variant_id"
  end

  create_table "spree_purchase_orders", force: :cascade do |t|
    t.string "number", null: false
    t.string "status"
    t.string "currency", null: false
    t.string "reference"
    t.bigint "supplier_id", null: false
    t.bigint "store_id", null: false
    t.bigint "destination_location_id", null: false
    t.date "expected_at"
    t.datetime "ordered_at"
    t.datetime "received_at"
    t.text "notes"
    t.bigint "created_by_id"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "cancel_by"
    t.datetime "closed_short_at"
    t.text "close_reason"
    t.index ["destination_location_id"], name: "index_spree_purchase_orders_on_destination_location_id"
    t.index ["number"], name: "index_spree_purchase_orders_on_number", unique: true
    t.index ["status"], name: "index_spree_purchase_orders_on_status"
    t.index ["store_id"], name: "index_spree_purchase_orders_on_store_id"
    t.index ["supplier_id"], name: "index_spree_purchase_orders_on_supplier_id"
  end

  create_table "spree_refresh_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.datetime "expires_at", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "audience"
    t.index ["expires_at"], name: "index_spree_refresh_tokens_on_expires_at"
    t.index ["token"], name: "index_spree_refresh_tokens_on_token", unique: true
    t.index ["user_type", "user_id"], name: "idx_refresh_tokens_user"
    t.index ["user_type", "user_id"], name: "index_spree_refresh_tokens_on_user"
  end

  create_table "spree_refund_reasons", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id", null: false
    t.index ["store_id", "name"], name: "index_spree_refund_reasons_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_spree_refund_reasons_on_store_id"
  end

  create_table "spree_refunds", force: :cascade do |t|
    t.bigint "payment_id"
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "refund_reason_id"
    t.bigint "reimbursement_id"
    t.jsonb "metadata"
    t.bigint "refunder_id"
    t.string "originator_type"
    t.bigint "originator_id"
    t.bigint "order_id"
    t.string "refunder_type"
    t.decimal "tax_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.index ["order_id"], name: "index_spree_refunds_on_order_id"
    t.index ["originator_type", "originator_id"], name: "index_spree_refunds_on_originator"
    t.index ["payment_id"], name: "index_spree_refunds_on_payment_id"
    t.index ["refund_reason_id"], name: "index_refunds_on_refund_reason_id"
    t.index ["refunder_id"], name: "index_spree_refunds_on_refunder_id"
    t.index ["refunder_type", "refunder_id"], name: "index_spree_refunds_on_refunder_actor"
    t.index ["reimbursement_id"], name: "index_spree_refunds_on_reimbursement_id"
  end

  create_table "spree_reimbursement_credits", force: :cascade do |t|
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.bigint "reimbursement_id"
    t.bigint "creditable_id"
    t.string "creditable_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["creditable_id", "creditable_type"], name: "index_reimbursement_credits_on_creditable_id_and_type"
    t.index ["reimbursement_id"], name: "index_spree_reimbursement_credits_on_reimbursement_id"
  end

  create_table "spree_reimbursement_types", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.boolean "mutable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["name"], name: "index_spree_reimbursement_types_on_name", unique: true
    t.index ["type"], name: "index_spree_reimbursement_types_on_type"
  end

  create_table "spree_reimbursements", force: :cascade do |t|
    t.string "number"
    t.string "reimbursement_status"
    t.bigint "customer_return_id"
    t.bigint "order_id"
    t.decimal "total", precision: 19, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "performed_by_id"
    t.index ["customer_return_id"], name: "index_spree_reimbursements_on_customer_return_id"
    t.index ["number"], name: "index_spree_reimbursements_on_number", unique: true
    t.index ["order_id"], name: "index_spree_reimbursements_on_order_id"
    t.index ["performed_by_id"], name: "index_spree_reimbursements_on_performed_by_id"
  end

  create_table "spree_reports", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "user_id"
    t.string "type"
    t.string "currency"
    t.datetime "date_from", precision: nil
    t.datetime "date_to", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_spree_reports_on_store_id"
    t.index ["user_id"], name: "index_spree_reports_on_user_id"
  end

  create_table "spree_return_authorizations", force: :cascade do |t|
    t.string "number"
    t.string "state"
    t.bigint "order_id"
    t.text "memo"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "stock_location_id"
    t.bigint "return_authorization_reason_id"
    t.index ["number"], name: "index_spree_return_authorizations_on_number", unique: true
    t.index ["order_id"], name: "index_spree_return_authorizations_on_order_id"
    t.index ["return_authorization_reason_id"], name: "index_return_authorizations_on_return_authorization_reason_id"
    t.index ["stock_location_id"], name: "index_spree_return_authorizations_on_stock_location_id"
  end

  create_table "spree_return_items", force: :cascade do |t|
    t.bigint "return_authorization_id"
    t.bigint "fulfillment_item_id"
    t.bigint "exchange_variant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "pre_tax_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.string "reception_status"
    t.string "acceptance_status"
    t.bigint "customer_return_id"
    t.bigint "reimbursement_id"
    t.text "acceptance_status_errors"
    t.bigint "preferred_reimbursement_type_id"
    t.bigint "override_reimbursement_type_id"
    t.boolean "resellable", default: true, null: false
    t.index ["customer_return_id"], name: "index_return_items_on_customer_return_id"
    t.index ["exchange_variant_id"], name: "index_spree_return_items_on_exchange_variant_id"
    t.index ["fulfillment_item_id"], name: "index_spree_return_items_on_fulfillment_item_id"
    t.index ["override_reimbursement_type_id"], name: "index_spree_return_items_on_override_reimbursement_type_id"
    t.index ["preferred_reimbursement_type_id"], name: "index_spree_return_items_on_preferred_reimbursement_type_id"
    t.index ["reimbursement_id"], name: "index_spree_return_items_on_reimbursement_id"
    t.index ["return_authorization_id"], name: "index_spree_return_items_on_return_authorization_id"
  end

  create_table "spree_return_line_items", force: :cascade do |t|
    t.bigint "return_id", null: false
    t.bigint "fulfillment_item_id", null: false
    t.bigint "line_item_id", null: false
    t.bigint "variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "received_quantity", default: 0, null: false
    t.decimal "pre_tax_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.boolean "resellable", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "included_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "additional_tax_total", precision: 19, scale: 4, default: "0.0", null: false
    t.index ["fulfillment_item_id"], name: "index_spree_return_line_items_on_fulfillment_item_id"
    t.index ["line_item_id"], name: "index_spree_return_line_items_on_line_item_id"
    t.index ["return_id"], name: "index_spree_return_line_items_on_return_id"
    t.index ["variant_id"], name: "index_spree_return_line_items_on_variant_id"
  end

  create_table "spree_return_reasons", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id", null: false
    t.index ["store_id", "name"], name: "index_spree_return_reasons_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_spree_return_reasons_on_store_id"
  end

  create_table "spree_returns", force: :cascade do |t|
    t.string "number", null: false
    t.bigint "store_id", null: false
    t.bigint "order_id", null: false
    t.bigint "stock_location_id", null: false
    t.bigint "reason_id"
    t.bigint "created_by_id"
    t.string "status", null: false
    t.text "memo"
    t.datetime "approved_at"
    t.datetime "received_at"
    t.datetime "refunded_at"
    t.datetime "canceled_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_by_type"
    t.index ["created_by_id"], name: "index_spree_returns_on_created_by_id"
    t.index ["created_by_type", "created_by_id"], name: "index_spree_returns_on_created_by_actor"
    t.index ["number"], name: "index_spree_returns_on_number", unique: true
    t.index ["order_id"], name: "index_spree_returns_on_order_id"
    t.index ["reason_id"], name: "index_spree_returns_on_reason_id"
    t.index ["status"], name: "index_spree_returns_on_status"
    t.index ["stock_location_id"], name: "index_spree_returns_on_stock_location_id"
    t.index ["store_id"], name: "index_spree_returns_on_store_id"
  end

  create_table "spree_role_users", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "user_type", null: false
    t.bigint "invitation_id"
    t.index ["invitation_id"], name: "index_spree_role_users_on_invitation_id"
    t.index ["role_id"], name: "index_spree_role_users_on_role_id"
    t.index ["user_id"], name: "index_spree_role_users_on_user_id"
    t.index ["user_type", "user_id", "role_id"], name: "index_spree_role_users_on_user_and_role", unique: true
    t.index ["user_type"], name: "index_spree_role_users_on_user_type"
  end

  create_table "spree_roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "description"
    t.boolean "mutable", default: true, null: false
    t.jsonb "permissions"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.index ["resource_type", "resource_id", "name"], name: "index_spree_roles_on_resource_and_name", unique: true
  end

  create_table "spree_saved_reports", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "user_id"
    t.string "name", null: false
    t.text "description"
    t.jsonb "query", null: false
    t.boolean "seeded", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "store_id, lower((name)::text)", name: "index_spree_saved_reports_on_store_and_lower_name", unique: true
    t.index ["user_id"], name: "index_spree_saved_reports_on_user_id"
  end

  create_table "spree_seller_payouts", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "seller_id", null: false
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", null: false
    t.string "status", null: false
    t.datetime "period_start"
    t.datetime "period_end"
    t.string "provider", null: false
    t.string "reference"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "reference"], name: "index_seller_payouts_on_provider_reference", unique: true, where: "(reference IS NOT NULL)"
    t.index ["seller_id", "created_at"], name: "index_spree_seller_payouts_on_seller_id_and_created_at"
    t.index ["seller_id", "currency", "status"], name: "idx_on_seller_id_currency_status_2cb0739591"
    t.index ["seller_id"], name: "index_spree_seller_payouts_on_seller_id"
    t.index ["store_id"], name: "index_spree_seller_payouts_on_store_id"
  end

  create_table "spree_seller_requirement_custom_fields", force: :cascade do |t|
    t.bigint "seller_requirement_id", null: false
    t.bigint "custom_field_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_definition_id"], name: "idx_on_custom_field_definition_id_7687001add"
    t.index ["seller_requirement_id", "custom_field_definition_id"], name: "idx_seller_requirement_custom_fields_uniqueness", unique: true
  end

  create_table "spree_seller_requirement_submissions", force: :cascade do |t|
    t.bigint "seller_id", null: false
    t.bigint "seller_requirement_id", null: false
    t.string "status", null: false
    t.bigint "submitted_by_id"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.text "note"
    t.text "review_note"
    t.string "reference"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewed_by_id"], name: "index_spree_seller_requirement_submissions_on_reviewed_by_id"
    t.index ["seller_id", "seller_requirement_id", "created_at"], name: "index_seller_requirement_submissions_on_pair_and_date"
    t.index ["seller_id"], name: "index_spree_seller_requirement_submissions_on_seller_id"
    t.index ["seller_requirement_id"], name: "idx_on_seller_requirement_id_9d30ae5c62"
    t.index ["submitted_by_id"], name: "index_spree_seller_requirement_submissions_on_submitted_by_id"
  end

  create_table "spree_seller_requirements", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "type", null: false
    t.string "name"
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.boolean "required", default: true, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "preferences"
    t.index ["store_id", "position"], name: "index_spree_seller_requirements_on_store_id_and_position"
    t.index ["store_id", "type"], name: "index_spree_seller_requirements_on_store_id_and_type"
    t.index ["store_id"], name: "index_spree_seller_requirements_on_store_id"
  end

  create_table "spree_seller_transfers", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "order_id", null: false
    t.bigint "payout_id"
    t.bigint "reversed_from_id"
    t.bigint "refund_id"
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", null: false
    t.string "kind", null: false
    t.string "status", null: false
    t.string "provider", null: false
    t.string "reference"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "settled_amount", precision: 19, scale: 4, null: false
    t.string "settled_currency", null: false
    t.index ["order_id"], name: "index_seller_transfers_on_order_earning", unique: true, where: "((kind)::text = 'earning'::text)"
    t.index ["order_id"], name: "index_spree_seller_transfers_on_order_id"
    t.index ["payout_id"], name: "index_spree_seller_transfers_on_payout_id"
    t.index ["provider", "reference"], name: "index_seller_transfers_on_provider_reference", unique: true, where: "(reference IS NOT NULL)"
    t.index ["refund_id"], name: "index_seller_transfers_on_refund", unique: true
    t.index ["reversed_from_id"], name: "index_spree_seller_transfers_on_reversed_from_id"
    t.index ["seller_id", "created_at"], name: "index_spree_seller_transfers_on_seller_id_and_created_at"
    t.index ["seller_id", "currency", "status"], name: "idx_on_seller_id_currency_status_fefa3626f6"
    t.index ["seller_id", "settled_currency", "status"], name: "index_seller_transfers_on_seller_and_settled_currency"
    t.index ["seller_id"], name: "index_spree_seller_transfers_on_seller_id"
    t.index ["store_id"], name: "index_spree_seller_transfers_on_store_id"
  end

  create_table "spree_seller_translations", force: :cascade do |t|
    t.string "name"
    t.text "about"
    t.string "locale", null: false
    t.bigint "spree_seller_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["locale"], name: "index_spree_seller_translations_on_locale"
    t.index ["spree_seller_id", "locale"], name: "index_seller_translations_on_seller_and_locale", unique: true
  end

  create_table "spree_sellers", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "status", null: false
    t.string "contact_email"
    t.string "billing_email"
    t.text "about"
    t.bigint "billing_address_id"
    t.datetime "terms_accepted_at"
    t.datetime "holiday_mode_until"
    t.string "payouts_schedule_interval"
    t.decimal "minimum_payout_amount", precision: 19, scale: 4
    t.string "tax_remittance", default: "seller", null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "legal_name"
    t.string "registration_number"
    t.datetime "payouts_enabled_at"
    t.index ["billing_address_id"], name: "index_spree_sellers_on_billing_address_id"
    t.index ["deleted_at"], name: "index_spree_sellers_on_deleted_at"
    t.index ["store_id", "slug"], name: "index_spree_sellers_on_store_id_and_slug", unique: true
    t.index ["store_id", "status"], name: "index_spree_sellers_on_store_id_and_status"
    t.index ["store_id"], name: "index_spree_sellers_on_store_id"
  end

  create_table "spree_shipping_labels", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.bigint "store_id", null: false
    t.bigint "integration_id"
    t.string "source", null: false
    t.string "external_id"
    t.string "carrier"
    t.string "service"
    t.string "tracking_number"
    t.decimal "cost", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency"
    t.string "format"
    t.string "status", null: false
    t.datetime "refunded_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_spree_shipping_labels_on_integration_id"
    t.index ["owner_type", "owner_id"], name: "index_spree_shipping_labels_on_active_owner", unique: true, where: "((status)::text <> 'refunded'::text)"
    t.index ["owner_type", "owner_id"], name: "index_spree_shipping_labels_on_owner"
    t.index ["owner_type", "owner_id"], name: "index_spree_shipping_labels_on_owner_type_and_owner_id"
    t.index ["store_id"], name: "index_spree_shipping_labels_on_store_id"
  end

  create_table "spree_shipping_method_categories", force: :cascade do |t|
    t.bigint "shipping_method_id", null: false
    t.bigint "shipping_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shipping_category_id", "shipping_method_id"], name: "unique_spree_shipping_method_categories", unique: true
    t.index ["shipping_category_id"], name: "index_spree_shipping_method_categories_on_shipping_category_id"
    t.index ["shipping_method_id"], name: "index_spree_shipping_method_categories_on_shipping_method_id"
  end

  create_table "spree_state_changes", force: :cascade do |t|
    t.string "name"
    t.string "previous_state"
    t.bigint "stateful_id"
    t.bigint "user_id"
    t.string "stateful_type"
    t.string "next_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stateful_id", "stateful_type"], name: "index_spree_state_changes_on_stateful_id_and_stateful_type"
  end

  create_table "spree_states", force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.bigint "country_id"
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.index ["country_id", "abbr"], name: "index_spree_states_on_country_id_and_abbr", unique: true
    t.index ["country_id"], name: "index_spree_states_on_country_id"
  end

  create_table "spree_stock_levels", force: :cascade do |t|
    t.bigint "stock_location_id"
    t.bigint "variant_id"
    t.integer "count_on_hand", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "backorderable", default: false
    t.datetime "deleted_at", precision: nil
    t.jsonb "metadata"
    t.integer "allocated_count", default: 0, null: false
    t.integer "reserved_count", default: 0, null: false
    t.integer "incoming_count", default: 0, null: false
    t.index ["backorderable"], name: "index_spree_stock_levels_on_backorderable"
    t.index ["deleted_at"], name: "index_spree_stock_levels_on_deleted_at"
    t.index ["stock_location_id", "variant_id", "deleted_at"], name: "stock_level_by_loc_var_id_deleted_at", unique: true
    t.index ["stock_location_id", "variant_id"], name: "stock_level_by_loc_and_var_id"
    t.index ["stock_location_id"], name: "index_spree_stock_levels_on_stock_location_id"
    t.index ["variant_id", "stock_location_id"], name: "index_spree_stock_levels_unique_without_deleted_at", unique: true, where: "(deleted_at IS NULL)"
    t.index ["variant_id"], name: "index_spree_stock_levels_on_variant_id"
  end

  create_table "spree_stock_locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false, null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.bigint "state_id"
    t.string "state_name"
    t.bigint "country_id"
    t.string "zipcode"
    t.string "phone"
    t.boolean "active", default: true
    t.boolean "backorderable_default", default: false
    t.boolean "propagate_all_variants", default: false
    t.string "admin_name"
    t.datetime "deleted_at", precision: nil
    t.string "company"
    t.string "kind", default: "warehouse", null: false
    t.boolean "pickup_enabled", default: false, null: false
    t.string "pickup_stock_policy", default: "local", null: false
    t.integer "pickup_ready_in_minutes"
    t.text "pickup_instructions"
    t.bigint "store_id"
    t.string "country_code"
    t.string "state_code"
    t.bigint "seller_id"
    t.boolean "returns_enabled", default: true, null: false
    t.index ["active"], name: "index_spree_stock_locations_on_active"
    t.index ["backorderable_default"], name: "index_spree_stock_locations_on_backorderable_default"
    t.index ["country_id"], name: "index_spree_stock_locations_on_country_id"
    t.index ["deleted_at"], name: "index_spree_stock_locations_on_deleted_at"
    t.index ["kind"], name: "index_spree_stock_locations_on_kind"
    t.index ["pickup_enabled"], name: "index_spree_stock_locations_on_pickup_enabled"
    t.index ["propagate_all_variants"], name: "index_spree_stock_locations_on_propagate_all_variants"
    t.index ["returns_enabled"], name: "index_spree_stock_locations_on_returns_enabled"
    t.index ["seller_id"], name: "index_spree_stock_locations_on_seller_id"
    t.index ["state_id"], name: "index_spree_stock_locations_on_state_id"
    t.index ["store_id"], name: "index_spree_stock_locations_on_store_id"
  end

  create_table "spree_stock_movements", force: :cascade do |t|
    t.bigint "stock_level_id"
    t.integer "quantity", default: 0
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "originator_type"
    t.bigint "originator_id"
    t.string "kind"
    t.string "reason"
    t.bigint "order_id"
    t.bigint "fulfillment_id"
    t.bigint "return_id"
    t.bigint "exchange_id"
    t.bigint "stock_transfer_id"
    t.bigint "purchase_order_id"
    t.decimal "unit_cost", precision: 19, scale: 4
    t.bigint "stock_receipt_id"
    t.index ["exchange_id"], name: "index_spree_stock_movements_on_exchange_id"
    t.index ["fulfillment_id"], name: "index_spree_stock_movements_on_fulfillment_id"
    t.index ["kind"], name: "index_spree_stock_movements_on_kind"
    t.index ["order_id"], name: "index_spree_stock_movements_on_order_id"
    t.index ["originator_id", "originator_type"], name: "index_stock_movements_on_originator_id_and_originator_type"
    t.index ["purchase_order_id"], name: "index_spree_stock_movements_on_purchase_order_id"
    t.index ["return_id"], name: "index_spree_stock_movements_on_return_id"
    t.index ["stock_level_id", "created_at"], name: "index_spree_stock_movements_on_stock_level_id_and_created_at"
    t.index ["stock_level_id"], name: "index_spree_stock_movements_on_stock_level_id"
    t.index ["stock_receipt_id"], name: "index_spree_stock_movements_on_stock_receipt_id"
    t.index ["stock_transfer_id"], name: "index_spree_stock_movements_on_stock_transfer_id"
  end

  create_table "spree_stock_receipt_items", force: :cascade do |t|
    t.bigint "stock_receipt_id", null: false
    t.string "line_type", null: false
    t.bigint "line_id", null: false
    t.integer "quantity_accepted", default: 0, null: false
    t.integer "quantity_rejected", default: 0, null: false
    t.string "rejection_reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_type", "line_id"], name: "index_spree_stock_receipt_items_on_line"
    t.index ["stock_receipt_id"], name: "index_spree_stock_receipt_items_on_stock_receipt_id"
  end

  create_table "spree_stock_receipts", force: :cascade do |t|
    t.string "number", null: false
    t.bigint "store_id", null: false
    t.string "receivable_type", null: false
    t.bigint "receivable_id", null: false
    t.string "reference"
    t.datetime "received_at", null: false
    t.bigint "received_by_id"
    t.text "notes"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "received_by_type"
    t.index ["number"], name: "index_spree_stock_receipts_on_number", unique: true
    t.index ["receivable_type", "receivable_id"], name: "index_spree_stock_receipts_on_receivable"
    t.index ["received_by_id"], name: "index_spree_stock_receipts_on_received_by_id"
    t.index ["received_by_type", "received_by_id"], name: "index_spree_stock_receipts_on_received_by_actor"
    t.index ["store_id"], name: "index_spree_stock_receipts_on_store_id"
  end

  create_table "spree_stock_reservations", force: :cascade do |t|
    t.bigint "stock_level_id", null: false
    t.bigint "line_item_id", null: false
    t.bigint "order_id"
    t.integer "quantity", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cart_id"
    t.index ["cart_id"], name: "index_spree_stock_reservations_on_cart_id"
    t.index ["expires_at"], name: "index_spree_stock_reservations_on_expires_at"
    t.index ["line_item_id"], name: "index_spree_stock_reservations_on_line_item_id"
    t.index ["order_id"], name: "index_spree_stock_reservations_on_order_id"
    t.index ["stock_level_id", "expires_at"], name: "idx_on_stock_level_id_expires_at_e64b0c98f8"
    t.index ["stock_level_id", "line_item_id"], name: "idx_stock_reservations_level_line_item", unique: true
  end

  create_table "spree_stock_transfer_items", force: :cascade do |t|
    t.bigint "stock_transfer_id", null: false
    t.bigint "variant_id", null: false
    t.integer "quantity_shipped", default: 0, null: false
    t.integer "quantity_received", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity_rejected", default: 0, null: false
    t.index ["stock_transfer_id", "variant_id"], name: "idx_stock_transfer_items_unique", unique: true
    t.index ["stock_transfer_id"], name: "index_spree_stock_transfer_items_on_stock_transfer_id"
    t.index ["variant_id"], name: "index_spree_stock_transfer_items_on_variant_id"
  end

  create_table "spree_stock_transfers", force: :cascade do |t|
    t.string "reference"
    t.bigint "source_location_id"
    t.bigint "destination_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.jsonb "metadata"
    t.bigint "store_id"
    t.string "status"
    t.datetime "shipped_at"
    t.datetime "received_at"
    t.text "notes"
    t.bigint "created_by_id"
    t.datetime "deleted_at"
    t.datetime "closed_short_at"
    t.text "close_reason"
    t.index ["deleted_at"], name: "index_spree_stock_transfers_on_deleted_at"
    t.index ["destination_location_id"], name: "index_spree_stock_transfers_on_destination_location_id"
    t.index ["number"], name: "index_spree_stock_transfers_on_number", unique: true
    t.index ["source_location_id"], name: "index_spree_stock_transfers_on_source_location_id"
    t.index ["status"], name: "index_spree_stock_transfers_on_status"
    t.index ["store_id"], name: "index_spree_stock_transfers_on_store_id"
  end

  create_table "spree_store_credit_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spree_store_credit_events", force: :cascade do |t|
    t.bigint "store_credit_id", null: false
    t.string "action", null: false
    t.decimal "amount", precision: 19, scale: 4
    t.string "authorization_code", null: false
    t.decimal "user_total_amount", precision: 19, scale: 4, default: "0.0", null: false
    t.bigint "originator_id"
    t.string "originator_type"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["originator_id", "originator_type"], name: "spree_store_credit_events_originator"
    t.index ["store_credit_id"], name: "index_spree_store_credit_events_on_store_credit_id"
  end

  create_table "spree_store_credit_types", force: :cascade do |t|
    t.string "name"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_spree_store_credit_types_on_priority"
  end

  create_table "spree_store_credits", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "category_id"
    t.bigint "created_by_id"
    t.decimal "amount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "amount_used", precision: 19, scale: 4, default: "0.0", null: false
    t.text "memo"
    t.datetime "deleted_at", precision: nil
    t.string "currency"
    t.decimal "amount_authorized", precision: 19, scale: 4, default: "0.0", null: false
    t.bigint "originator_id"
    t.string "originator_type"
    t.bigint "type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.jsonb "metadata"
    t.bigint "refunded_order_id"
    t.string "created_by_type"
    t.index ["created_by_type", "created_by_id"], name: "index_spree_store_credits_on_created_by_actor"
    t.index ["customer_id"], name: "index_spree_store_credits_on_customer_id"
    t.index ["deleted_at"], name: "index_spree_store_credits_on_deleted_at"
    t.index ["originator_id", "originator_type"], name: "spree_store_credits_originator"
    t.index ["refunded_order_id"], name: "index_spree_store_credits_on_refunded_order_id"
    t.index ["store_id"], name: "index_spree_store_credits_on_store_id"
    t.index ["type_id"], name: "index_spree_store_credits_on_type_id"
  end

  create_table "spree_store_translations", force: :cascade do |t|
    t.string "name"
    t.text "meta_description"
    t.text "meta_keywords"
    t.string "seo_title"
    t.string "facebook"
    t.string "twitter"
    t.string "instagram"
    t.string "customer_support_email"
    t.text "description"
    t.text "address"
    t.string "contact_phone"
    t.string "new_order_notifications_email"
    t.string "locale", null: false
    t.bigint "spree_store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.index ["deleted_at"], name: "index_spree_store_translations_on_deleted_at"
    t.index ["locale"], name: "index_spree_store_translations_on_locale"
    t.index ["spree_store_id", "locale"], name: "index_spree_store_translations_on_spree_store_id_locale", unique: true
  end

  create_table "spree_stores", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "meta_description"
    t.text "meta_keywords"
    t.string "seo_title"
    t.string "mail_from_address"
    t.string "default_currency"
    t.string "code"
    t.boolean "default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "supported_currencies"
    t.string "facebook"
    t.string "twitter"
    t.string "instagram"
    t.string "default_locale"
    t.string "customer_support_email"
    t.bigint "default_country_id"
    t.text "description"
    t.text "address"
    t.string "contact_phone"
    t.string "new_order_notifications_email"
    t.bigint "checkout_zone_id"
    t.string "seo_robots"
    t.string "supported_locales"
    t.datetime "deleted_at", precision: nil
    t.jsonb "settings"
    t.jsonb "metadata"
    t.text "storefront_custom_code_head"
    t.text "storefront_custom_code_body_start"
    t.text "storefront_custom_code_body_end"
    t.string "default_country_code"
    t.string "setup_token"
    t.jsonb "preferences"
    t.index ["code"], name: "index_spree_stores_on_code", unique: true
    t.index ["default"], name: "index_spree_stores_on_default"
    t.index ["deleted_at"], name: "index_spree_stores_on_deleted_at"
    t.index ["setup_token"], name: "index_spree_stores_on_setup_token", unique: true
    t.index ["url"], name: "index_spree_stores_on_url"
  end

  create_table "spree_stripe_payment_intents", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "order_id", null: false
    t.bigint "payment_method_id", null: false
    t.string "stripe_id", null: false
    t.string "client_secret", null: false
    t.string "customer_id"
    t.string "ephemeral_key_secret"
    t.string "stripe_payment_method_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "stripe_id"], name: "index_spree_stripe_payment_intents_on_order_id_and_stripe_id", unique: true
    t.index ["order_id"], name: "index_spree_stripe_payment_intents_on_order_id"
    t.index ["payment_method_id"], name: "index_spree_stripe_payment_intents_on_payment_method_id"
  end

  create_table "spree_stripe_payment_methods_webhook_keys", force: :cascade do |t|
    t.bigint "payment_method_id", null: false
    t.bigint "webhook_key_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id", "webhook_key_id"], name: "index_payment_method_id_webhook_key_id_uniqueness", unique: true
    t.index ["payment_method_id"], name: "index_payment_methods_webhook_keys_on_payment_method_id"
    t.index ["webhook_key_id"], name: "index_payment_methods_webhook_keys_on_webhook_key_id"
  end

  create_table "spree_stripe_webhook_keys", force: :cascade do |t|
    t.string "stripe_id", null: false
    t.string "signing_secret", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signing_secret"], name: "index_spree_stripe_webhook_keys_on_signing_secret", unique: true
    t.index ["stripe_id"], name: "index_spree_stripe_webhook_keys_on_stripe_id", unique: true
  end

  create_table "spree_suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "contact_name"
    t.string "email"
    t.string "phone"
    t.text "notes"
    t.bigint "store_id", null: false
    t.integer "purchase_orders_count", default: 0, null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state_name"
    t.string "state_code"
    t.string "country_code"
    t.string "postal_code"
    t.jsonb "metadata"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_spree_suppliers_on_deleted_at"
    t.index ["store_id", "name"], name: "index_spree_suppliers_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_spree_suppliers_on_store_id"
  end

  create_table "spree_taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_spree_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "spree_taggings_idx", unique: true
    t.index ["tag_id"], name: "index_spree_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "spree_taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "spree_taggings_idy"
    t.index ["taggable_id"], name: "index_spree_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_spree_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_spree_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_spree_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_spree_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_spree_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_spree_taggings_on_tenant"
  end

  create_table "spree_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_spree_tags_on_lower_name"
    t.index ["name"], name: "index_spree_tags_on_name", unique: true
  end

  create_table "spree_tax_categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_default", default: false
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tax_code"
    t.bigint "store_id"
    t.index ["deleted_at"], name: "index_spree_tax_categories_on_deleted_at"
    t.index ["is_default"], name: "index_spree_tax_categories_on_is_default"
    t.index ["store_id", "name"], name: "index_spree_tax_categories_on_store_id_and_name", unique: true, where: "(deleted_at IS NULL)"
    t.index ["store_id"], name: "index_spree_tax_categories_on_store_id"
  end

  create_table "spree_tax_exemption_certificates", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "country_code"
    t.string "state_code"
    t.string "certificate_number", null: false
    t.string "reason_code"
    t.string "status", null: false
    t.datetime "issued_at"
    t.datetime "expires_at"
    t.string "issuing_authority"
    t.datetime "verified_at"
    t.bigint "verified_by_id"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tax_exemption_reason_id"
    t.index ["company_id", "status"], name: "idx_on_company_id_status_9f9c6d73b6"
    t.index ["company_id"], name: "index_spree_tax_exemption_certificates_on_company_id"
    t.index ["country_code", "state_code"], name: "idx_on_country_code_state_code_21132110e7"
    t.index ["tax_exemption_reason_id"], name: "idx_on_tax_exemption_reason_id_5c3e42a6be"
    t.index ["verified_by_id"], name: "index_spree_tax_exemption_certificates_on_verified_by_id"
  end

  create_table "spree_tax_exemption_reasons", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.string "code", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "code"], name: "idx_tax_exemption_reasons_on_store_and_code", unique: true
    t.index ["store_id", "name"], name: "idx_tax_exemption_reasons_on_store_and_name", unique: true
  end

  create_table "spree_tax_identifiers", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "kind", null: false
    t.string "value", null: false
    t.string "validation_status"
    t.datetime "validated_at"
    t.jsonb "validation_evidence"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "kind"], name: "index_spree_tax_identifiers_on_owner_and_kind", unique: true
    t.index ["owner_type", "owner_id"], name: "index_spree_tax_identifiers_on_owner"
  end

  create_table "spree_tax_lines", force: :cascade do |t|
    t.bigint "cart_id"
    t.bigint "order_id"
    t.bigint "tax_rate_id"
    t.bigint "line_item_id"
    t.bigint "fulfillment_id"
    t.bigint "fee_id"
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.decimal "rate", precision: 8, scale: 5, null: false
    t.string "label", null: false
    t.boolean "included", null: false
    t.string "provider_id"
    t.jsonb "data"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "taxability_reason"
    t.string "country_code"
    t.string "state_code"
    t.bigint "return_line_item_id"
    t.bigint "claim_line_item_id"
    t.bigint "exchange_line_item_id"
    t.bigint "original_tax_line_id"
    t.boolean "credit", default: false, null: false
    t.index ["cart_id"], name: "index_spree_tax_lines_on_cart_id"
    t.index ["claim_line_item_id"], name: "index_spree_tax_lines_on_claim_line_item_id"
    t.index ["country_code", "state_code"], name: "index_spree_tax_lines_on_country_code_and_state_code"
    t.index ["exchange_line_item_id"], name: "index_spree_tax_lines_on_exchange_line_item_id"
    t.index ["fee_id"], name: "index_spree_tax_lines_on_fee_id"
    t.index ["fulfillment_id"], name: "index_spree_tax_lines_on_fulfillment_id"
    t.index ["line_item_id"], name: "index_spree_tax_lines_on_line_item_id"
    t.index ["order_id"], name: "index_spree_tax_lines_on_order_id"
    t.index ["original_tax_line_id"], name: "index_spree_tax_lines_on_original_tax_line_id"
    t.index ["return_line_item_id"], name: "index_spree_tax_lines_on_return_line_item_id"
    t.index ["tax_rate_id"], name: "index_spree_tax_lines_on_tax_rate_id"
    t.index ["taxability_reason"], name: "index_spree_tax_lines_on_taxability_reason"
  end

  create_table "spree_tax_rates", force: :cascade do |t|
    t.decimal "amount", precision: 8, scale: 5
    t.bigint "zone_id"
    t.bigint "tax_category_id"
    t.boolean "included_in_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "show_rate_in_label", default: true
    t.datetime "deleted_at", precision: nil
    t.jsonb "metadata"
    t.bigint "store_id"
    t.string "country_code"
    t.string "state_code"
    t.index ["country_code", "state_code"], name: "index_spree_tax_rates_on_country_code_and_state_code"
    t.index ["deleted_at"], name: "index_spree_tax_rates_on_deleted_at"
    t.index ["included_in_price"], name: "index_spree_tax_rates_on_included_in_price"
    t.index ["show_rate_in_label"], name: "index_spree_tax_rates_on_show_rate_in_label"
    t.index ["store_id"], name: "index_spree_tax_rates_on_store_id"
    t.index ["tax_category_id"], name: "index_spree_tax_rates_on_tax_category_id"
    t.index ["zone_id"], name: "index_spree_tax_rates_on_zone_id"
  end

  create_table "spree_taxon_rules", force: :cascade do |t|
    t.bigint "taxon_id", null: false
    t.string "type", null: false
    t.string "value", null: false
    t.string "match_policy", default: "is_equal_to", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["taxon_id"], name: "index_spree_taxon_rules_on_taxon_id"
  end

  create_table "spree_taxonomies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0
    t.bigint "store_id"
    t.jsonb "metadata"
    t.index ["name", "store_id"], name: "index_spree_taxonomies_on_name_and_store_id", unique: true
    t.index ["position"], name: "index_spree_taxonomies_on_position"
    t.index ["store_id"], name: "index_spree_taxonomies_on_store_id"
  end

  create_table "spree_taxonomy_translations", force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.bigint "spree_taxonomy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_spree_taxonomy_translations_on_locale"
    t.index ["spree_taxonomy_id", "locale"], name: "index_spree_taxonomy_translations_on_spree_taxonomy_id_locale", unique: true
  end

  create_table "spree_trackers", force: :cascade do |t|
    t.string "analytics_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "engine", default: 0, null: false
    t.index ["active"], name: "index_spree_trackers_on_active"
  end

  create_table "spree_upgrade_records", force: :cascade do |t|
    t.string "version", null: false
    t.string "source", null: false
    t.datetime "completed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["version"], name: "index_spree_upgrade_records_on_version", unique: true
  end

  create_table "spree_user_identities", force: :cascade do |t|
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.jsonb "info"
    t.text "access_token"
    t.text "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid", "user_type"], name: "index_spree_user_identities_on_provider_uid_user_type", unique: true
    t.index ["user_type", "user_id"], name: "index_spree_user_identities_on_user"
  end

  create_table "spree_users", force: :cascade do |t|
    t.string "encrypted_password", limit: 128
    t.string "password_salt", limit: 128
    t.string "email"
    t.string "remember_token"
    t.string "persistence_token"
    t.string "reset_password_token"
    t.string "perishable_token"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_request_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "login"
    t.bigint "ship_address_id"
    t.bigint "bill_address_id"
    t.string "authentication_token"
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
  end

  create_table "spree_variant_media", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "media_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_id"], name: "idx_variant_media_media"
    t.index ["variant_id", "media_id"], name: "idx_variant_media_unique", unique: true
  end

  create_table "spree_variants", force: :cascade do |t|
    t.string "sku", default: "", null: false
    t.decimal "weight", precision: 8, scale: 2, default: "0.0"
    t.decimal "height", precision: 8, scale: 2
    t.decimal "width", precision: 8, scale: 2
    t.decimal "depth", precision: 8, scale: 2
    t.datetime "deleted_at", precision: nil
    t.boolean "is_master", default: false
    t.bigint "product_id"
    t.decimal "cost_price", precision: 19, scale: 4
    t.integer "position"
    t.string "cost_currency"
    t.boolean "track_inventory", default: true
    t.bigint "tax_category_id"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "discontinue_on", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.jsonb "metadata"
    t.string "barcode"
    t.string "weight_unit"
    t.string "dimensions_unit"
    t.integer "media_count", default: 0, null: false
    t.bigint "primary_media_id"
    t.boolean "preorderable"
    t.datetime "preorder_ships_at"
    t.integer "backorder_limit"
    t.string "hs_code"
    t.string "country_of_origin"
    t.string "customs_description"
    t.bigint "seller_id"
    t.bigint "delivery_profile_id"
    t.integer "minimum_order_quantity"
    t.integer "order_multiple"
    t.string "purchase_unit"
    t.integer "units_per_carton"
    t.bigint "carton_package_type_id"
    t.decimal "carton_weight", precision: 8, scale: 2
    t.integer "cartons_per_pallet"
    t.index ["barcode"], name: "index_spree_variants_on_barcode"
    t.index ["carton_package_type_id"], name: "index_spree_variants_on_carton_package_type_id"
    t.index ["deleted_at"], name: "index_spree_variants_on_deleted_at"
    t.index ["delivery_profile_id"], name: "index_spree_variants_on_delivery_profile_id"
    t.index ["discontinue_on"], name: "index_spree_variants_on_discontinue_on"
    t.index ["is_master"], name: "index_spree_variants_on_is_master"
    t.index ["media_count"], name: "index_spree_variants_on_media_count"
    t.index ["position"], name: "index_spree_variants_on_position"
    t.index ["primary_media_id"], name: "index_spree_variants_on_primary_media_id"
    t.index ["product_id"], name: "index_spree_variants_on_product_id"
    t.index ["seller_id"], name: "index_spree_variants_on_seller_id"
    t.index ["sku"], name: "index_spree_variants_on_sku"
    t.index ["tax_category_id"], name: "index_spree_variants_on_tax_category_id"
    t.index ["track_inventory"], name: "index_spree_variants_on_track_inventory"
  end

  create_table "spree_vietqr_payment_allocations", force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.bigint "order_id", null: false
    t.bigint "payment_method_id", null: false
    t.bigint "receiving_account_id"
    t.bigint "webhook_event_id"
    t.string "provider", null: false
    t.string "bank_bin", null: false
    t.string "account_number", null: false
    t.string "account_name", null: false
    t.string "sub_account", default: "", null: false
    t.string "virtual_account_number", default: "", null: false
    t.bigint "expected_amount", null: false
    t.string "transfer_content", null: false
    t.string "order_number", null: false
    t.string "provider_order_code"
    t.string "payment_link_id"
    t.string "provider_checkout_url"
    t.text "provider_qr_code"
    t.string "status", default: "allocated", null: false
    t.datetime "expires_at"
    t.datetime "confirmed_at"
    t.datetime "released_at"
    t.string "release_reason"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_spree_vietqr_payment_allocations_on_order_id"
    t.index ["payment_id"], name: "idx_vietqr_payment_allocations_active_payment", unique: true, where: "(released_at IS NULL)"
    t.index ["payment_id"], name: "index_spree_vietqr_payment_allocations_on_payment_id"
    t.index ["payment_method_id"], name: "index_spree_vietqr_payment_allocations_on_payment_method_id"
    t.index ["provider", "account_number", "bank_bin", "status"], name: "idx_vietqr_payment_allocations_account_lookup"
    t.index ["provider", "order_number", "status"], name: "idx_vietqr_payment_allocations_order_lookup"
    t.index ["provider", "payment_link_id", "status"], name: "idx_vietqr_payment_allocations_payment_link_lookup"
    t.index ["provider", "provider_order_code", "status"], name: "idx_vietqr_payment_allocations_provider_order_lookup"
    t.index ["receiving_account_id"], name: "index_spree_vietqr_payment_allocations_on_receiving_account_id"
    t.index ["webhook_event_id"], name: "index_spree_vietqr_payment_allocations_on_webhook_event_id"
  end

  create_table "spree_vietqr_receiving_accounts", force: :cascade do |t|
    t.bigint "payment_method_id", null: false
    t.string "provider", null: false
    t.string "bank_bin", null: false
    t.string "bank_name"
    t.string "account_number", null: false
    t.string "account_name", null: false
    t.string "keyword_init", default: "", null: false
    t.string "sub_account", default: "", null: false
    t.string "virtual_account_number", default: "", null: false
    t.boolean "active", default: true, null: false
    t.integer "priority", default: 0, null: false
    t.integer "routing_weight", default: 1, null: false
    t.bigint "monthly_quota_amount"
    t.bigint "monthly_threshold_amount"
    t.string "current_period", null: false
    t.bigint "period_allocated_amount", default: 0, null: false
    t.bigint "period_confirmed_amount", default: 0, null: false
    t.datetime "last_allocated_at"
    t.string "webhook_secret"
    t.string "payos_client_id"
    t.string "payos_api_key"
    t.string "payos_checksum_key"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id", "active", "priority"], name: "idx_vietqr_receiving_accounts_routing"
    t.index ["payment_method_id", "provider", "bank_bin", "account_number", "sub_account", "virtual_account_number", "keyword_init"], name: "idx_vietqr_receiving_accounts_identity", unique: true
    t.index ["payment_method_id"], name: "index_spree_vietqr_receiving_accounts_on_payment_method_id"
  end

  create_table "spree_vietqr_webhook_events", force: :cascade do |t|
    t.string "provider", null: false
    t.string "provider_transaction_id"
    t.string "status", default: "received", null: false
    t.jsonb "raw_payload", default: {}, null: false
    t.jsonb "raw_headers", default: {}
    t.bigint "receiving_account_id"
    t.bigint "payment_allocation_id"
    t.string "matched_order_number"
    t.bigint "payment_method_id"
    t.bigint "payment_id"
    t.bigint "amount_cents"
    t.string "parsed_order_code"
    t.string "account_number"
    t.string "bank_bin"
    t.string "sub_account"
    t.string "virtual_account_number"
    t.string "payment_link_id"
    t.string "provider_order_code"
    t.string "error_message"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_allocation_id"], name: "index_spree_vietqr_webhook_events_on_payment_allocation_id"
    t.index ["payment_id"], name: "index_spree_vietqr_webhook_events_on_payment_id"
    t.index ["payment_method_id"], name: "index_spree_vietqr_webhook_events_on_payment_method_id"
    t.index ["provider", "provider_transaction_id"], name: "idx_webhook_events_provider_tx_id", where: "(provider_transaction_id IS NOT NULL)"
    t.index ["provider"], name: "index_spree_vietqr_webhook_events_on_provider"
    t.index ["provider_transaction_id"], name: "index_spree_vietqr_webhook_events_on_provider_transaction_id"
    t.index ["receiving_account_id"], name: "index_spree_vietqr_webhook_events_on_receiving_account_id"
  end

  create_table "spree_webhook_deliveries", force: :cascade do |t|
    t.bigint "webhook_endpoint_id", null: false
    t.string "event_name", null: false
    t.jsonb "payload", null: false
    t.integer "response_code"
    t.text "response_body"
    t.string "error_type"
    t.integer "execution_time"
    t.text "request_errors"
    t.boolean "success"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_id"
    t.index ["delivered_at"], name: "index_spree_webhook_deliveries_on_delivered_at"
    t.index ["event_name"], name: "index_spree_webhook_deliveries_on_event_name"
    t.index ["response_code"], name: "index_spree_webhook_deliveries_on_response_code"
    t.index ["success"], name: "index_spree_webhook_deliveries_on_success"
    t.index ["webhook_endpoint_id", "event_id"], name: "index_spree_webhook_deliveries_on_endpoint_and_event", unique: true, where: "(event_id IS NOT NULL)"
    t.index ["webhook_endpoint_id"], name: "index_spree_webhook_deliveries_on_webhook_endpoint_id"
  end

  create_table "spree_webhook_endpoints", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "url", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "subscriptions", null: false
    t.string "secret_key", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "disabled_reason"
    t.datetime "disabled_at"
    t.index ["active"], name: "index_spree_webhook_endpoints_on_active"
    t.index ["deleted_at"], name: "index_spree_webhook_endpoints_on_deleted_at"
    t.index ["store_id"], name: "index_spree_webhook_endpoints_on_store_id"
  end

  create_table "spree_wishlist_items", force: :cascade do |t|
    t.bigint "variant_id"
    t.bigint "wishlist_id"
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["variant_id", "wishlist_id"], name: "index_spree_wishlist_items_on_variant_id_and_wishlist_id", unique: true
    t.index ["variant_id"], name: "index_spree_wishlist_items_on_variant_id"
    t.index ["wishlist_id"], name: "index_spree_wishlist_items_on_wishlist_id"
  end

  create_table "spree_wishlists", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "store_id"
    t.string "name"
    t.string "token", null: false
    t.boolean "is_private", default: true, null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["customer_id", "is_default"], name: "index_spree_wishlists_on_customer_id_and_is_default"
    t.index ["customer_id"], name: "index_spree_wishlists_on_customer_id"
    t.index ["store_id"], name: "index_spree_wishlists_on_store_id"
    t.index ["token"], name: "index_spree_wishlists_on_token", unique: true
  end

  create_table "spree_zone_members", force: :cascade do |t|
    t.string "zoneable_type"
    t.bigint "zoneable_id"
    t.bigint "zone_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["zone_id", "zoneable_type", "zoneable_id"], name: "index_spree_zone_members_uniqueness", unique: true
    t.index ["zone_id"], name: "index_spree_zone_members_on_zone_id"
  end

  create_table "spree_zones", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "default_tax", default: false
    t.integer "zone_members_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind", default: "state"
    t.index ["default_tax"], name: "index_spree_zones_on_default_tax"
    t.index ["kind"], name: "index_spree_zones_on_kind"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pos_walk_in_orders", "spree_orders", column: "order_id"
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "spree_category_translations", "spree_categories"
  add_foreign_key "spree_option_type_translations", "spree_option_types"
  add_foreign_key "spree_option_value_translations", "spree_option_values"
  add_foreign_key "spree_payment_sources", "spree_payment_methods", column: "payment_method_id"
  add_foreign_key "spree_pos_approvals", "spree_admin_users", column: "approver_id"
  add_foreign_key "spree_pos_approvals", "spree_admin_users", column: "requester_id"
  add_foreign_key "spree_pos_approvals", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_approvals", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_areas", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_areas", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_audit_entries", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_audit_entries", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_bottle_keep_events", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_bottle_keep_events", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_bottle_keep_events", "spree_pos_bottle_keeps", column: "bottle_keep_id"
  add_foreign_key "spree_pos_bottle_keep_events", "spree_pos_workspaces", column: "workspace_id", on_delete: :nullify
  add_foreign_key "spree_pos_bottle_keeps", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_bottle_keeps", "spree_orders", column: "source_order_id"
  add_foreign_key "spree_pos_bottle_keeps", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_bottle_keeps", "spree_pos_customers", column: "customer_profile_id"
  add_foreign_key "spree_pos_bottle_keeps", "spree_pos_sale_lines", column: "source_sale_line_id", on_delete: :nullify
  add_foreign_key "spree_pos_bottle_keeps", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_bottle_keeps", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_branch_label_formats", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_branch_label_formats", "spree_pos_label_formats", column: "label_format_id"
  add_foreign_key "spree_pos_branch_label_formats", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_branch_modules", "spree_admin_users", column: "changed_by_id"
  add_foreign_key "spree_pos_branch_modules", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_branch_modules", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_branch_payment_methods", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_branch_payment_methods", "spree_pos_payment_methods", column: "pos_payment_method_id"
  add_foreign_key "spree_pos_branch_payment_methods", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_branch_products", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_branch_products", "spree_products", column: "product_id"
  add_foreign_key "spree_pos_branch_receipt_templates", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_branch_receipt_templates", "spree_pos_receipt_templates", column: "receipt_template_id"
  add_foreign_key "spree_pos_branch_receipt_templates", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_branches", "spree_pos_printers", column: "cup_label_printer_id"
  add_foreign_key "spree_pos_branches", "spree_pos_registers", column: "table_register_id", on_delete: :nullify
  add_foreign_key "spree_pos_branches", "spree_products", column: "reservation_fee_product_id"
  add_foreign_key "spree_pos_branches", "spree_stock_locations", column: "receiving_stock_location_id"
  add_foreign_key "spree_pos_branches", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_branches", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_branches", "spree_tax_categories", column: "service_charge_tax_category_id", on_delete: :nullify
  add_foreign_key "spree_pos_buffet_tier_items", "spree_pos_buffet_tiers", column: "buffet_tier_id", on_delete: :cascade
  add_foreign_key "spree_pos_buffet_tier_items", "spree_products", column: "product_id"
  add_foreign_key "spree_pos_buffet_tiers", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_buffet_tiers", "spree_products", column: "product_id"
  add_foreign_key "spree_pos_buffet_tiers", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_cash_movements", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_cash_movements", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_cash_movements", "spree_pos_liability_payouts", column: "liability_payout_id"
  add_foreign_key "spree_pos_cash_movements", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_cash_movements", "spree_pos_refund_requests", column: "refund_request_id"
  add_foreign_key "spree_pos_cash_movements", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_cash_movements", "spree_pos_shifts", column: "shift_id"
  add_foreign_key "spree_pos_cash_movements", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_collections", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_collections", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_collections", "spree_pos_credit_accounts", column: "credit_account_id"
  add_foreign_key "spree_pos_collections", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_collections", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_combo_components", "spree_pos_menu_items", column: "menu_item_id", on_delete: :cascade
  add_foreign_key "spree_pos_combo_components", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_command_receipts", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_command_receipts", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_command_receipts", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_course_labels", "spree_pos_branches", column: "branch_id", on_delete: :cascade
  add_foreign_key "spree_pos_credit_accounts", "spree_admin_users", column: "updated_by_id"
  add_foreign_key "spree_pos_credit_accounts", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_credit_accounts", "spree_pos_customers", column: "customer_profile_id"
  add_foreign_key "spree_pos_credit_accounts", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_credit_requests", "spree_admin_users", column: "decided_by_id"
  add_foreign_key "spree_pos_credit_requests", "spree_admin_users", column: "requester_id"
  add_foreign_key "spree_pos_credit_requests", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_credit_requests", "spree_pos_credit_reservations", column: "credit_reservation_id"
  add_foreign_key "spree_pos_credit_requests", "spree_pos_customers", column: "customer_profile_id"
  add_foreign_key "spree_pos_credit_requests", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_credit_requests", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_credit_reservations", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_credit_reservations", "spree_pos_credit_accounts", column: "credit_account_id"
  add_foreign_key "spree_pos_credit_reservations", "spree_pos_customers", column: "customer_profile_id"
  add_foreign_key "spree_pos_credit_reservations", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_credit_reservations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_customers", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_customers", "spree_customers", column: "customer_id"
  add_foreign_key "spree_pos_customers", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_deliveries", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_deliveries", "spree_admin_users", column: "delivered_by_id"
  add_foreign_key "spree_pos_deliveries", "spree_fees", column: "fee_id", on_delete: :nullify
  add_foreign_key "spree_pos_deliveries", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_deliveries", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_deliveries", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_deliveries", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_device_pairings", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_device_pairings", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_device_pairings", "spree_pos_devices", column: "device_id"
  add_foreign_key "spree_pos_device_pairings", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_device_pin_failures", "spree_pos_devices", column: "device_id"
  add_foreign_key "spree_pos_device_pin_failures", "spree_pos_staff_memberships", column: "staff_membership_id"
  add_foreign_key "spree_pos_device_staff_sessions", "spree_admin_users", column: "staff_id"
  add_foreign_key "spree_pos_device_staff_sessions", "spree_pos_devices", column: "device_id"
  add_foreign_key "spree_pos_device_table_pins", "spree_admin_users", column: "staff_id"
  add_foreign_key "spree_pos_device_table_pins", "spree_pos_devices", column: "device_id", on_delete: :cascade
  add_foreign_key "spree_pos_device_table_pins", "spree_pos_resources", column: "resource_id", on_delete: :cascade
  add_foreign_key "spree_pos_device_table_pins", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_devices", "spree_admin_users", column: "paired_by_id"
  add_foreign_key "spree_pos_devices", "spree_admin_users", column: "revoked_by_id"
  add_foreign_key "spree_pos_devices", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_devices", "spree_pos_kitchen_stations", column: "kitchen_station_id", on_delete: :nullify
  add_foreign_key "spree_pos_devices", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_devices", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_discount_allocations", "spree_discounts", column: "discount_id", on_delete: :cascade
  add_foreign_key "spree_pos_discount_allocations", "spree_pos_discount_intents", column: "discount_intent_id"
  add_foreign_key "spree_pos_discount_allocations", "spree_pos_line_discount_intents", column: "line_discount_intent_id", on_delete: :cascade
  add_foreign_key "spree_pos_discount_intents", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_discount_intents", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_einvoice_settings", "spree_admin_users", column: "changed_by_id"
  add_foreign_key "spree_pos_einvoice_settings", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_einvoice_settings", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_einvoices", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_einvoices", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_einvoices", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_einvoices", "spree_pos_einvoices", column: "original_einvoice_id"
  add_foreign_key "spree_pos_einvoices", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_einvoices", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_exchange_operations", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_exchange_operations", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_exchange_operations", "spree_pos_return_operations", column: "return_operation_id"
  add_foreign_key "spree_pos_exchange_operations", "spree_pos_workspaces", column: "replacement_workspace_id"
  add_foreign_key "spree_pos_exchange_operations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_feature_flags", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_feature_flags", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_funds_allocations", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_funds_allocations", "spree_payments", column: "payment_id"
  add_foreign_key "spree_pos_funds_allocations", "spree_pos_collections", column: "collection_id"
  add_foreign_key "spree_pos_funds_allocations", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_funds_allocations", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_funds_allocations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_admin_users", column: "applier_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_admin_users", column: "requester_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_inventory_adjustments", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_inventory_lots", "spree_pos_inventory_lots", column: "source_lot_id"
  add_foreign_key "spree_pos_inventory_lots", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_inventory_lots", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_inventory_lots", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_kitchen_sends", "spree_admin_users", column: "staff_id"
  add_foreign_key "spree_pos_kitchen_sends", "spree_pos_devices", column: "device_id"
  add_foreign_key "spree_pos_kitchen_sends", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_kitchen_stations", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_kitchen_stations", "spree_pos_kitchen_stations", column: "expo_station_id", on_delete: :nullify
  add_foreign_key "spree_pos_kitchen_stations", "spree_pos_printers", column: "printer_id", on_delete: :nullify
  add_foreign_key "spree_pos_kitchen_stations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_kitchen_ticket_items", "spree_pos_kitchen_tickets", column: "kitchen_ticket_id", on_delete: :cascade
  add_foreign_key "spree_pos_kitchen_ticket_items", "spree_pos_sale_lines", column: "sale_line_id", on_delete: :nullify
  add_foreign_key "spree_pos_kitchen_tickets", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_kitchen_tickets", "spree_pos_kitchen_sends", column: "kitchen_send_id"
  add_foreign_key "spree_pos_kitchen_tickets", "spree_pos_kitchen_stations", column: "kitchen_station_id"
  add_foreign_key "spree_pos_kitchen_tickets", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_kitchen_tickets", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_kitchen_voids", "spree_admin_users", column: "staff_id"
  add_foreign_key "spree_pos_kitchen_voids", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_kitchen_voids", "spree_pos_devices", column: "device_id"
  add_foreign_key "spree_pos_kitchen_voids", "spree_pos_kitchen_tickets", column: "kitchen_ticket_id"
  add_foreign_key "spree_pos_kitchen_voids", "spree_pos_sale_lines", column: "sale_line_id", on_delete: :nullify
  add_foreign_key "spree_pos_kitchen_voids", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_kitchen_voids", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_liability_payouts", "spree_admin_users", column: "requester_id"
  add_foreign_key "spree_pos_liability_payouts", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_liability_payouts", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_liability_payouts", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_line_components", "spree_pos_sale_lines", column: "sale_line_id", on_delete: :cascade
  add_foreign_key "spree_pos_line_components", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_line_discount_intents", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_line_discount_intents", "spree_pos_sale_lines", column: "sale_line_id", on_delete: :cascade
  add_foreign_key "spree_pos_line_discount_intents", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_line_modifiers", "spree_pos_modifier_options", column: "modifier_option_id", on_delete: :nullify
  add_foreign_key "spree_pos_line_modifiers", "spree_pos_sale_lines", column: "sale_line_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_availabilities", "spree_pos_branches", column: "branch_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_availabilities", "spree_pos_menu_items", column: "menu_item_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_categories", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_menu_favorites", "spree_pos_branches", column: "branch_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_favorites", "spree_pos_menu_items", column: "menu_item_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_item_modifier_groups", "spree_pos_menu_items", column: "menu_item_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_item_modifier_groups", "spree_pos_modifier_groups", column: "modifier_group_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_items", "spree_pos_menu_categories", column: "menu_category_id", on_delete: :nullify
  add_foreign_key "spree_pos_menu_items", "spree_products", column: "product_id"
  add_foreign_key "spree_pos_menu_items", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_menu_schedule_items", "spree_pos_menu_items", column: "menu_item_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_schedule_items", "spree_pos_menu_schedules", column: "menu_schedule_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_schedule_items", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_menu_schedules", "spree_pos_branches", column: "branch_id", on_delete: :cascade
  add_foreign_key "spree_pos_menu_schedules", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_modifier_groups", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_modifier_options", "spree_pos_modifier_groups", column: "modifier_group_id", on_delete: :cascade
  add_foreign_key "spree_pos_modifier_options", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_open_bottles", "spree_admin_users", column: "opened_by_id"
  add_foreign_key "spree_pos_open_bottles", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_open_bottles", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_open_bottles", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_order_number_counters", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_outbox_entries", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_payment_methods", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_payment_requests", "spree_admin_users", column: "requested_by_id"
  add_foreign_key "spree_pos_payment_requests", "spree_admin_users", column: "resolved_by_id"
  add_foreign_key "spree_pos_payment_requests", "spree_pos_devices", column: "device_id"
  add_foreign_key "spree_pos_payment_requests", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_payout_evidences", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_payout_evidences", "spree_pos_liability_payouts", column: "liability_payout_id"
  add_foreign_key "spree_pos_payout_evidences", "spree_pos_refund_requests", column: "refund_request_id"
  add_foreign_key "spree_pos_payout_evidences", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_platform_orders", "spree_admin_users", column: "entered_by_id"
  add_foreign_key "spree_pos_platform_orders", "spree_admin_users", column: "settled_by_id"
  add_foreign_key "spree_pos_platform_orders", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_platform_orders", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_platform_orders", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_platform_settings", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_platform_settings", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_pour_events", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_pour_events", "spree_pos_open_bottles", column: "open_bottle_id"
  add_foreign_key "spree_pos_pour_events", "spree_pos_sale_lines", column: "sale_line_id"
  add_foreign_key "spree_pos_pour_events", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_prebill_prints", "spree_admin_users", column: "staff_id"
  add_foreign_key "spree_pos_prebill_prints", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_prebill_prints", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_print_jobs", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_print_jobs", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_print_jobs", "spree_pos_devices", column: "claimed_by_device_id"
  add_foreign_key "spree_pos_print_jobs", "spree_pos_print_jobs", column: "copy_of_id", on_delete: :restrict
  add_foreign_key "spree_pos_print_jobs", "spree_pos_printers", column: "printer_id", on_delete: :restrict
  add_foreign_key "spree_pos_print_jobs", "spree_pos_receipt_prints", column: "receipt_print_id", on_delete: :restrict
  add_foreign_key "spree_pos_print_jobs", "spree_pos_receipt_templates", column: "receipt_template_id", on_delete: :restrict
  add_foreign_key "spree_pos_print_jobs", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_printers", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_printers", "spree_pos_devices", column: "print_station_device_id"
  add_foreign_key "spree_pos_printers", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_printers", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_receipt_evidences", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_receipt_evidences", "spree_pos_tender_attempts", column: "tender_attempt_id"
  add_foreign_key "spree_pos_receipt_evidences", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_receipt_prints", "spree_pos_printers", column: "printer_id", on_delete: :nullify
  add_foreign_key "spree_pos_receipt_prints", "spree_pos_receipt_templates", column: "receipt_template_id"
  add_foreign_key "spree_pos_receipt_template_versions", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_receipt_template_versions", "spree_pos_receipt_templates", column: "receipt_template_id"
  add_foreign_key "spree_pos_receipt_templates", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_receipt_templates", "spree_admin_users", column: "updated_by_id"
  add_foreign_key "spree_pos_receipt_templates", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_pos_credit_accounts", column: "credit_account_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_pos_credit_reservations", column: "credit_reservation_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_pos_funds_allocations", column: "funds_allocation_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_receivable_entries", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_received_funds", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_received_funds", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_received_funds", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_received_funds", "spree_pos_shifts", column: "shift_id"
  add_foreign_key "spree_pos_received_funds", "spree_pos_tender_attempts", column: "tender_attempt_id"
  add_foreign_key "spree_pos_received_funds", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_received_funds", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_pos_recipes", column: "recipe_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_pos_sale_lines", column: "sale_line_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_recipe_consumptions", "spree_variants", column: "ingredient_variant_id"
  add_foreign_key "spree_pos_recipe_ingredients", "spree_pos_recipes", column: "recipe_id", on_delete: :cascade
  add_foreign_key "spree_pos_recipe_ingredients", "spree_variants", column: "ingredient_variant_id"
  add_foreign_key "spree_pos_recipes", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_recipes", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_refund_requests", "spree_admin_users", column: "confirmer_id"
  add_foreign_key "spree_pos_refund_requests", "spree_admin_users", column: "requester_id"
  add_foreign_key "spree_pos_refund_requests", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_refund_requests", "spree_payments", column: "payment_id"
  add_foreign_key "spree_pos_refund_requests", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_refund_requests", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_refund_requests", "spree_pos_funds_allocations", column: "funds_allocation_id"
  add_foreign_key "spree_pos_refund_requests", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_refund_requests", "spree_pos_return_operations", column: "return_operation_id"
  add_foreign_key "spree_pos_refund_requests", "spree_pos_shifts", column: "shift_id"
  add_foreign_key "spree_pos_refund_requests", "spree_refunds", column: "refund_id"
  add_foreign_key "spree_pos_refund_requests", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_registers", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_registers", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_reservation_deposits", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_reservation_deposits", "spree_orders", column: "resolution_order_id"
  add_foreign_key "spree_pos_reservation_deposits", "spree_pos_funds_allocations", column: "funds_allocation_id"
  add_foreign_key "spree_pos_reservation_deposits", "spree_pos_liability_payouts", column: "liability_payout_id"
  add_foreign_key "spree_pos_reservation_deposits", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_reservation_deposits", "spree_pos_reservations", column: "reservation_id"
  add_foreign_key "spree_pos_reservation_resources", "spree_pos_reservations", column: "reservation_id", on_delete: :cascade
  add_foreign_key "spree_pos_reservation_resources", "spree_pos_resources", column: "resource_id"
  add_foreign_key "spree_pos_reservations", "spree_admin_users", column: "created_by_id"
  add_foreign_key "spree_pos_reservations", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_reservations", "spree_pos_customers", column: "customer_profile_id"
  add_foreign_key "spree_pos_reservations", "spree_pos_workspaces", column: "workspace_id", on_delete: :nullify
  add_foreign_key "spree_pos_reservations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_resources", "spree_pos_areas", column: "area_id"
  add_foreign_key "spree_pos_resources", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_resources", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_return_operations", "spree_admin_users", column: "receiver_id"
  add_foreign_key "spree_pos_return_operations", "spree_admin_users", column: "requester_id"
  add_foreign_key "spree_pos_return_operations", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_return_operations", "spree_pos_approvals", column: "approval_id"
  add_foreign_key "spree_pos_return_operations", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_return_operations", "spree_pos_branches", column: "sale_branch_id"
  add_foreign_key "spree_pos_return_operations", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_return_operations", "spree_returns", column: "core_return_id"
  add_foreign_key "spree_pos_return_operations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_return_reservations", "spree_fulfillment_items", column: "fulfillment_item_id"
  add_foreign_key "spree_pos_return_reservations", "spree_line_items", column: "line_item_id"
  add_foreign_key "spree_pos_return_reservations", "spree_pos_return_operations", column: "return_operation_id"
  add_foreign_key "spree_pos_return_reservations", "spree_pos_sale_lines", column: "sale_line_id"
  add_foreign_key "spree_pos_return_reservations", "spree_return_line_items", column: "return_line_item_id"
  add_foreign_key "spree_pos_return_reservations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_sale_lines", "spree_admin_users", column: "added_by_id"
  add_foreign_key "spree_pos_sale_lines", "spree_line_items", column: "line_item_id", on_delete: :cascade
  add_foreign_key "spree_pos_sale_lines", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_sale_lines", "spree_pos_buffet_tiers", column: "buffet_tier_id"
  add_foreign_key "spree_pos_sale_lines", "spree_pos_devices", column: "added_device_id"
  add_foreign_key "spree_pos_sale_lines", "spree_pos_sale_lines", column: "buffet_cover_line_id", on_delete: :nullify
  add_foreign_key "spree_pos_sale_lines", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_sale_lines", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_serial_units", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_serial_units", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_serial_units", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_shifts", "spree_admin_users", column: "owner_id"
  add_foreign_key "spree_pos_shifts", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_shifts", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_shifts", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_staff_memberships", "spree_admin_users", column: "staff_id"
  add_foreign_key "spree_pos_staff_memberships", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_staff_memberships", "spree_pos_staff_roles", column: "staff_role_id"
  add_foreign_key "spree_pos_staff_memberships", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_staff_roles", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_station_routes", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_station_routes", "spree_pos_kitchen_stations", column: "kitchen_station_id", on_delete: :cascade
  add_foreign_key "spree_pos_station_routes", "spree_products", column: "product_id", on_delete: :cascade
  add_foreign_key "spree_pos_station_routes", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_stock_alerts", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_stock_alerts", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_stock_alerts", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_fulfillments", column: "fulfillment_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_stock_discrepancies", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_store_profiles", "spree_admin_users", column: "changed_by_id"
  add_foreign_key "spree_pos_store_profiles", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_store_profiles", "spree_tax_categories", column: "alcohol_tax_category_id"
  add_foreign_key "spree_pos_store_profiles", "spree_tax_categories", column: "food_tax_category_id"
  add_foreign_key "spree_pos_tax_rate_schedules", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_tax_rate_schedules", "spree_tax_rates", column: "tax_rate_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_admin_users", column: "actor_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_pos_payment_methods", column: "pos_payment_method_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_pos_shifts", column: "shift_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_tender_attempts", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_tip_records", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_tip_records", "spree_pos_liability_payouts", column: "liability_payout_id"
  add_foreign_key "spree_pos_tip_records", "spree_pos_received_funds", column: "received_funds_id"
  add_foreign_key "spree_pos_tip_records", "spree_pos_shifts", column: "shift_id"
  add_foreign_key "spree_pos_tip_records", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_tip_records", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_tip_split_rules", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_fulfillment_items", column: "fulfillment_item_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_pos_inventory_lots", column: "inventory_lot_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_pos_sale_lines", column: "sale_line_id", on_delete: :cascade
  add_foreign_key "spree_pos_trace_allocations", "spree_pos_serial_units", column: "serial_unit_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_pos_workspaces", column: "workspace_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_trace_allocations", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_trace_enrollments", "spree_admin_users", column: "opened_by_id"
  add_foreign_key "spree_pos_trace_enrollments", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_trace_enrollments", "spree_stock_locations", column: "stock_location_id"
  add_foreign_key "spree_pos_trace_enrollments", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_trace_enrollments", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_trace_returns", "spree_pos_inventory_lots", column: "return_lot_id"
  add_foreign_key "spree_pos_trace_returns", "spree_pos_return_operations", column: "return_operation_id"
  add_foreign_key "spree_pos_trace_returns", "spree_pos_trace_allocations", column: "trace_allocation_id"
  add_foreign_key "spree_pos_trace_returns", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_units", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_variant_units", "spree_pos_units", column: "base_unit_id"
  add_foreign_key "spree_pos_variant_units", "spree_pos_units", column: "price_unit_id"
  add_foreign_key "spree_pos_variant_units", "spree_pos_units", column: "sale_unit_id"
  add_foreign_key "spree_pos_variant_units", "spree_stores", column: "store_id"
  add_foreign_key "spree_pos_variant_units", "spree_variants", column: "variant_id"
  add_foreign_key "spree_pos_workspaces", "spree_admin_users", column: "lease_holder_id"
  add_foreign_key "spree_pos_workspaces", "spree_orders", column: "order_id"
  add_foreign_key "spree_pos_workspaces", "spree_pos_branches", column: "branch_id"
  add_foreign_key "spree_pos_workspaces", "spree_pos_customers", column: "pos_customer_id"
  add_foreign_key "spree_pos_workspaces", "spree_pos_registers", column: "register_id"
  add_foreign_key "spree_pos_workspaces", "spree_pos_resources", column: "resource_id"
  add_foreign_key "spree_pos_workspaces", "spree_pos_shifts", column: "shift_id"
  add_foreign_key "spree_pos_workspaces", "spree_stores", column: "store_id"
  add_foreign_key "spree_product_translations", "spree_products"
  add_foreign_key "spree_store_translations", "spree_stores"
  add_foreign_key "spree_taxonomy_translations", "spree_taxonomies"
  add_foreign_key "spree_vietqr_payment_allocations", "spree_orders", column: "order_id"
  add_foreign_key "spree_vietqr_payment_allocations", "spree_payment_methods", column: "payment_method_id"
  add_foreign_key "spree_vietqr_payment_allocations", "spree_payments", column: "payment_id"
  add_foreign_key "spree_vietqr_payment_allocations", "spree_vietqr_receiving_accounts", column: "receiving_account_id"
  add_foreign_key "spree_vietqr_payment_allocations", "spree_vietqr_webhook_events", column: "webhook_event_id"
  add_foreign_key "spree_vietqr_receiving_accounts", "spree_payment_methods", column: "payment_method_id"
  add_foreign_key "spree_vietqr_webhook_events", "spree_payment_methods", column: "payment_method_id"
  add_foreign_key "spree_vietqr_webhook_events", "spree_payments", column: "payment_id"
  add_foreign_key "spree_vietqr_webhook_events", "spree_vietqr_payment_allocations", column: "payment_allocation_id"
  add_foreign_key "spree_vietqr_webhook_events", "spree_vietqr_receiving_accounts", column: "receiving_account_id"
end
