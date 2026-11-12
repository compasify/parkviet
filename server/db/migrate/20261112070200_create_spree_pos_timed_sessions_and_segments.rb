# frozen_string_literal: true

# Play time on a room or a billiard table. A session is the clock of one
# timed sale line; it is made of segments (play, and later pause), each on
# one room at the rate plan of that room. A room runs one clock at a time.
# Stopping a session writes its quote lines, the priced pieces printed on
# the bill and the invoice, and the line's minutes and price.
class CreateSpreePosTimedSessionsAndSegments < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'btree_gist' unless extension_enabled?('btree_gist')

    create_table :spree_pos_timed_sessions do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines }, index: { unique: true }
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.string :status, null: false, limit: 16, default: 'running'
      t.datetime :started_at, null: false
      t.datetime :stopped_at
      # When the guests said they would leave; prepaid packages use it later.
      t.datetime :planned_end_at
      t.integer :played_minutes, null: false, default: 0
      t.integer :billed_minutes, null: false, default: 0
      t.decimal :amount, precision: 19, scale: 4, null: false, default: 0
      t.string :currency, limit: 3, null: false
      # Moves with every change of the segments, so a quote can be compared.
      t.integer :quote_version, null: false, default: 0
      t.references :started_by, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.references :stopped_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.timestamps
    end
    add_index :spree_pos_timed_sessions, %i[resource_id status], name: 'idx_pos_timed_sessions_resource'
    add_index :spree_pos_timed_sessions, :resource_id, unique: true, where: "status IN ('running', 'paused')",
                                                       name: 'idx_pos_timed_sessions_one_clock'
    add_check_constraint :spree_pos_timed_sessions,
                         "status IN ('running', 'paused', 'stopped') AND played_minutes >= 0 AND billed_minutes >= 0 AND amount >= 0 AND " \
                         "quote_version >= 0 AND (status <> 'stopped' OR stopped_at IS NOT NULL) AND " \
                         '(stopped_at IS NULL OR stopped_at >= started_at) AND (planned_end_at IS NULL OR planned_end_at > started_at)',
                         name: 'chk_pos_timed_sessions_values'

    create_table :spree_pos_timed_segments do |t|
      t.references :timed_session, null: false, foreign_key: { to_table: :spree_pos_timed_sessions, on_delete: :cascade }, index: false
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.string :kind, null: false, limit: 16, default: 'play'
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.references :rate_plan, foreign_key: { to_table: :spree_pos_rate_plans }
      t.integer :rate_plan_version
      t.boolean :edited, null: false, default: false
      t.timestamps
    end
    add_index :spree_pos_timed_segments, %i[timed_session_id started_at], name: 'idx_pos_timed_segments_session'
    add_index :spree_pos_timed_segments, :timed_session_id, unique: true, where: 'ended_at IS NULL', name: 'idx_pos_timed_segments_open'
    add_check_constraint :spree_pos_timed_segments,
                         "kind IN ('play', 'pause') AND (ended_at IS NULL OR ended_at > started_at) AND (kind <> 'play' OR rate_plan_id IS NOT NULL)",
                         name: 'chk_pos_timed_segments_values'
    # Segments of a session never overlap, whoever writes them.
    add_exclusion_constraint :spree_pos_timed_segments,
                             "timed_session_id WITH =, tsrange(started_at, COALESCE(ended_at, 'infinity'::timestamp)) WITH &&",
                             using: :gist, name: 'excl_pos_timed_segments_overlap'

    create_table :spree_pos_timed_quote_lines do |t|
      t.references :timed_session, null: false, foreign_key: { to_table: :spree_pos_timed_sessions, on_delete: :cascade }, index: false
      t.references :timed_segment, null: false, foreign_key: { to_table: :spree_pos_timed_segments, on_delete: :cascade }
      t.integer :position, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :day_type, null: false, limit: 16
      t.bigint :rate_rule_id
      t.string :label, limit: 40
      t.decimal :price_per_hour, precision: 19, scale: 4, null: false
      t.decimal :surcharge_percent, precision: 5, scale: 2, null: false, default: 0
      t.integer :minutes, null: false
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.timestamps
    end
    add_index :spree_pos_timed_quote_lines, %i[timed_session_id position], unique: true, name: 'idx_pos_timed_quote_lines_order'
    add_check_constraint :spree_pos_timed_quote_lines,
                         "day_type IN ('weekday', 'weekend', 'holiday') AND ends_at >= starts_at AND minutes >= 0 AND amount >= 0 AND " \
                         'price_per_hour >= 0 AND surcharge_percent >= 0',
                         name: 'chk_pos_timed_quote_lines_values'
  end
end
