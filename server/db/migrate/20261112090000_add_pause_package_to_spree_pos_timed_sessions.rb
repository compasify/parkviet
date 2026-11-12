# frozen_string_literal: true

# Pausing a clock, prepaid packages and minutes cards on a session. A
# segment records why it ended; a session sold with a package keeps the
# package's minutes, name and price as sold, and one paid by a minutes card
# names the card. `alerts` remembers which deadline each alert was sent
# for, so the alert job sends it once. A quote line says what priced it: the
# rate plan, the package, the minutes card or a bonus of a promotion.
# Rate plans list the packages sold on them.
class AddPausePackageToSpreePosTimedSessions < ActiveRecord::Migration[8.1]
  SESSION_CHECK = "status IN ('running', 'paused', 'stopped') AND played_minutes >= 0 AND billed_minutes >= 0 AND amount >= 0 AND " \
                  "quote_version >= 0 AND (status <> 'stopped' OR stopped_at IS NOT NULL) AND " \
                  '(stopped_at IS NULL OR stopped_at >= started_at) AND (planned_end_at IS NULL OR planned_end_at > started_at)'
  SEGMENT_CHECK = "kind IN ('play', 'pause') AND (ended_at IS NULL OR ended_at > started_at) AND (kind <> 'play' OR rate_plan_id IS NOT NULL)"
  QUOTE_CHECK = "day_type IN ('weekday', 'weekend', 'holiday') AND ends_at >= starts_at AND minutes >= 0 AND amount >= 0 AND " \
                'price_per_hour >= 0 AND surcharge_percent >= 0'

  def up
    add_column :spree_pos_timed_segments, :ended_reason, :string, limit: 16
    remove_check_constraint :spree_pos_timed_segments, name: 'chk_pos_timed_segments_values'
    add_check_constraint :spree_pos_timed_segments,
                         "#{SEGMENT_CHECK} AND (ended_reason IS NULL OR ended_reason IN ('pause', 'resume', 'move', 'stop', 'split_window'))",
                         name: 'chk_pos_timed_segments_values'

    add_column :spree_pos_timed_sessions, :prepaid_minutes, :integer
    add_column :spree_pos_timed_sessions, :package_name, :string, limit: 120
    add_column :spree_pos_timed_sessions, :package_price, :decimal, precision: 19, scale: 4
    add_reference :spree_pos_timed_sessions, :stored_value_account, foreign_key: { to_table: :spree_pos_stored_value_accounts }
    add_column :spree_pos_timed_sessions, :alerts, :jsonb, null: false, default: {}
    remove_check_constraint :spree_pos_timed_sessions, name: 'chk_pos_timed_sessions_values'
    add_check_constraint :spree_pos_timed_sessions,
                         "#{SESSION_CHECK} AND (prepaid_minutes IS NULL OR prepaid_minutes BETWEEN 1 AND 1440) AND " \
                         '(package_price IS NULL OR package_price >= 0) AND ((prepaid_minutes IS NULL) = (package_price IS NULL)) AND ' \
                         "jsonb_typeof(alerts) = 'object'",
                         name: 'chk_pos_timed_sessions_values'

    add_column :spree_pos_timed_quote_lines, :kind, :string, limit: 16, null: false, default: 'rate'
    add_column :spree_pos_timed_quote_lines, :timed_promotion_id, :bigint
    remove_check_constraint :spree_pos_timed_quote_lines, name: 'chk_pos_timed_quote_lines_values'
    add_check_constraint :spree_pos_timed_quote_lines,
                         "#{QUOTE_CHECK} AND kind IN ('rate', 'package', 'card', 'bonus') AND (kind <> 'bonus' OR amount = 0)",
                         name: 'chk_pos_timed_quote_lines_values'

    add_column :spree_pos_rate_plans, :packages, :jsonb, null: false, default: []
    add_check_constraint :spree_pos_rate_plans, "jsonb_typeof(packages) = 'array'", name: 'chk_pos_rate_plans_packages'
  end

  def down
    remove_check_constraint :spree_pos_rate_plans, name: 'chk_pos_rate_plans_packages'
    remove_column :spree_pos_rate_plans, :packages
    remove_check_constraint :spree_pos_timed_quote_lines, name: 'chk_pos_timed_quote_lines_values'
    remove_column :spree_pos_timed_quote_lines, :timed_promotion_id
    remove_column :spree_pos_timed_quote_lines, :kind
    add_check_constraint :spree_pos_timed_quote_lines, QUOTE_CHECK, name: 'chk_pos_timed_quote_lines_values'
    remove_check_constraint :spree_pos_timed_sessions, name: 'chk_pos_timed_sessions_values'
    remove_column :spree_pos_timed_sessions, :alerts
    remove_reference :spree_pos_timed_sessions, :stored_value_account
    remove_column :spree_pos_timed_sessions, :package_price
    remove_column :spree_pos_timed_sessions, :package_name
    remove_column :spree_pos_timed_sessions, :prepaid_minutes
    add_check_constraint :spree_pos_timed_sessions, SESSION_CHECK, name: 'chk_pos_timed_sessions_values'
    remove_check_constraint :spree_pos_timed_segments, name: 'chk_pos_timed_segments_values'
    remove_column :spree_pos_timed_segments, :ended_reason
    add_check_constraint :spree_pos_timed_segments, SEGMENT_CHECK, name: 'chk_pos_timed_segments_values'
  end
end
