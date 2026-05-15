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

ActiveRecord::Schema[8.0].define(version: 2026_05_14_300004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_logs", force: :cascade do |t|
    t.bigint "accessor_id", null: false
    t.bigint "accessed_user_id", null: false
    t.string "accessor_role", null: false
    t.integer "reason", null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.bigint "sport_id"
    t.boolean "anomaly_flagged", default: false, null: false
    t.decimal "anomaly_score", precision: 4, scale: 3
    t.text "anomaly_reason"
    t.boolean "anomaly_reviewed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessed_user_id", "created_at"], name: "index_access_logs_on_accessed_user_id_and_created_at"
    t.index ["accessed_user_id"], name: "index_access_logs_on_accessed_user_id"
    t.index ["accessor_id", "created_at"], name: "index_access_logs_on_accessor_id_and_created_at"
    t.index ["accessor_id"], name: "index_access_logs_on_accessor_id"
    t.index ["anomaly_flagged"], name: "index_access_logs_on_anomaly_flagged"
    t.index ["resource_type", "resource_id"], name: "index_access_logs_on_resource_type_and_resource_id"
  end

  create_table "access_notifications", force: :cascade do |t|
    t.bigint "notified_user_id", null: false
    t.bigint "access_log_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_log_id"], name: "index_access_notifications_on_access_log_id"
    t.index ["notified_user_id", "read_at"], name: "index_access_notifications_on_notified_user_id_and_read_at"
    t.index ["notified_user_id"], name: "index_access_notifications_on_notified_user_id"
  end

  create_table "activities", force: :cascade do |t|
    t.integer "event_type", null: false
    t.bigint "actor_id"
    t.string "subject_type"
    t.bigint "subject_id"
    t.bigint "season_id"
    t.bigint "school_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_activities_on_actor_id"
    t.index ["event_type"], name: "index_activities_on_event_type"
    t.index ["school_id", "occurred_at"], name: "index_activities_on_school_id_and_occurred_at"
    t.index ["school_id"], name: "index_activities_on_school_id"
    t.index ["season_id", "occurred_at"], name: "index_activities_on_season_id_and_occurred_at"
    t.index ["season_id"], name: "index_activities_on_season_id"
    t.index ["subject_type", "subject_id"], name: "index_activities_on_subject"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.bigint "created_by_id", null: false
    t.string "title", null: false
    t.integer "event_type", default: 0, null: false
    t.integer "home_away", default: 0, null: false
    t.string "location"
    t.string "opponent"
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.text "notes"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_calendar_events_on_created_by_id"
    t.index ["sport_id", "starts_at"], name: "index_calendar_events_on_sport_id_and_starts_at"
    t.index ["sport_id"], name: "index_calendar_events_on_sport_id"
  end

  create_table "channel_memberships", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "user_id"], name: "index_channel_memberships_on_channel_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_channel_memberships_on_user_id"
  end

  create_table "channels", force: :cascade do |t|
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "channel_type", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.boolean "student_created", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "system_generated", default: false, null: false
    t.bigint "season_id", null: false
    t.index ["created_by_id"], name: "index_channels_on_created_by_id"
    t.index ["deleted_at"], name: "index_channels_on_deleted_at"
    t.index ["season_id"], name: "index_channels_on_season_id"
  end

  create_table "commissioner_events", force: :cascade do |t|
    t.bigint "sport_template_id", null: false
    t.bigint "district_id", null: false
    t.string "title", null: false
    t.string "event_type", default: "meet", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.string "venue"
    t.string "status", default: "scheduled", null: false
    t.boolean "has_results", default: false, null: false
    t.string "result_summary"
    t.text "notes", default: ""
    t.text "teams_json", default: "[]"
    t.text "matchup_pairs_json", default: "[]"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_commissioner_events_on_district_id"
    t.index ["sport_template_id"], name: "index_commissioner_events_on_sport_template_id"
  end

  create_table "coop_authorizations", force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.bigint "school_id", null: false
    t.bigint "athletic_director_id"
    t.integer "status", default: 0, null: false
    t.datetime "approved_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athletic_director_id"], name: "index_coop_authorizations_on_athletic_director_id"
    t.index ["school_id"], name: "index_coop_authorizations_on_school_id"
    t.index ["sport_id", "school_id"], name: "index_coop_authorizations_on_sport_id_and_school_id", unique: true
  end

  create_table "device_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.string "platform"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_device_tokens_on_user_id"
  end

  create_table "direct_messages", force: :cascade do |t|
    t.bigint "dm_conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "content", null: false
    t.datetime "read_at"
    t.boolean "flagged", default: false, null: false
    t.decimal "moderation_score", precision: 4, scale: 3
    t.text "flag_reason"
    t.boolean "flag_reviewed", default: false, null: false
    t.bigint "flag_reviewed_by_id"
    t.datetime "flag_reviewed_at"
    t.string "flag_action"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "flag_category"
    t.index ["deleted_at"], name: "index_direct_messages_on_deleted_at"
    t.index ["dm_conversation_id", "created_at"], name: "index_direct_messages_on_dm_conversation_id_and_created_at"
    t.index ["dm_conversation_id"], name: "index_direct_messages_on_dm_conversation_id"
    t.index ["flagged"], name: "index_direct_messages_on_flagged"
    t.index ["sender_id"], name: "index_direct_messages_on_sender_id"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "country", default: "US", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subdomain"
    t.string "email_domain"
    t.jsonb "feature_flags", default: {}, null: false
    t.index ["feature_flags"], name: "index_districts_on_feature_flags", using: :gin
    t.index ["name"], name: "index_districts_on_name", unique: true
    t.index ["subdomain"], name: "index_districts_on_subdomain", unique: true
  end

  create_table "dm_conversations", force: :cascade do |t|
    t.bigint "participant_a_id", null: false
    t.bigint "participant_b_id", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "season_id", null: false
    t.index ["participant_a_id", "participant_b_id", "season_id"], name: "index_dm_conversations_unique", unique: true
    t.index ["participant_b_id"], name: "index_dm_conversations_on_participant_b_id"
    t.index ["season_id"], name: "index_dm_conversations_on_season_id"
  end

  create_table "institution_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "role", null: false
    t.bigint "district_id"
    t.bigint "school_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.index ["district_id"], name: "index_institution_roles_on_district_id"
    t.index ["school_id"], name: "index_institution_roles_on_school_id"
    t.index ["user_id", "role", "district_id", "school_id"], name: "index_institution_roles_unique", unique: true
    t.index ["user_id"], name: "index_institution_roles_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "token", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", null: false
    t.boolean "is_captain", default: false, null: false
    t.bigint "season_id", null: false
    t.bigint "invited_by_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "dob"
    t.string "jersey_number"
    t.string "grade"
    t.string "level"
    t.string "position"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["season_id", "email"], name: "index_invitations_on_season_id_and_email", unique: true
    t.index ["season_id"], name: "index_invitations_on_season_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "meet_results", force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.bigint "home_school_id", null: false
    t.bigint "away_school_id"
    t.string "away_school_name"
    t.date "date", null: false
    t.string "venue"
    t.boolean "cross_division", default: false, null: false
    t.integer "home_score", default: 0, null: false
    t.integer "away_score", default: 0, null: false
    t.text "ai_summary"
    t.text "ai_standouts_json", default: "[]", null: false
    t.text "ai_focus"
    t.bigint "uploaded_by_id"
    t.string "status", default: "pending_opponent", null: false
    t.text "events_json", default: "[]", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_school_id"], name: "index_meet_results_on_away_school_id"
    t.index ["home_school_id"], name: "index_meet_results_on_home_school_id"
    t.index ["sport_id"], name: "index_meet_results_on_sport_id"
    t.index ["uploaded_by_id"], name: "index_meet_results_on_uploaded_by_id"
  end

  create_table "message_challenges", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "challenger_id", null: false
    t.text "reason"
    t.string "status", default: "pending", null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenger_id"], name: "index_message_challenges_on_challenger_id"
    t.index ["message_id", "status"], name: "index_message_challenges_on_message_id_and_status"
    t.index ["message_id"], name: "index_message_challenges_on_message_id"
    t.index ["reviewed_by_id"], name: "index_message_challenges_on_reviewed_by_id"
  end

  create_table "message_flags", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "flagged_by_id", null: false
    t.text "reason"
    t.integer "status", default: 0, null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.bigint "escalated_to_id"
    t.datetime "escalated_at"
    t.bigint "resolved_by_id"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flagged_by_id"], name: "index_message_flags_on_flagged_by_id"
    t.index ["message_id", "flagged_by_id"], name: "index_message_flags_on_message_id_and_flagged_by_id", unique: true
    t.index ["message_id"], name: "index_message_flags_on_message_id"
    t.index ["status"], name: "index_message_flags_on_status"
  end

  create_table "message_threads", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "parent_message_id", null: false
    t.integer "reply_count", default: 0, null: false
    t.datetime "last_reply_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_message_threads_on_channel_id"
    t.index ["parent_message_id"], name: "index_message_threads_on_parent_message_id", unique: true
  end

  create_table "message_translations", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.string "language", null: false
    t.text "translated_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "language"], name: "index_message_translations_on_message_id_and_language", unique: true
    t.index ["message_id"], name: "index_message_translations_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "message_thread_id"
    t.bigint "sender_id", null: false
    t.text "content", null: false
    t.boolean "flagged", default: false, null: false
    t.decimal "moderation_score", precision: 4, scale: 3
    t.text "flag_reason"
    t.boolean "flag_reviewed", default: false, null: false
    t.bigint "flag_reviewed_by_id"
    t.datetime "flag_reviewed_at"
    t.string "flag_action"
    t.datetime "deleted_at"
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "pinned_at"
    t.bigint "pinned_by_id"
    t.string "flag_category"
    t.index ["channel_id", "created_at"], name: "index_messages_on_channel_id_and_created_at"
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["deleted_at"], name: "index_messages_on_deleted_at"
    t.index ["flagged"], name: "index_messages_on_flagged"
    t.index ["message_thread_id"], name: "index_messages_on_message_thread_id"
    t.index ["pinned_at"], name: "index_messages_on_pinned_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "moderation_notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "message_id"
    t.bigint "direct_message_id"
    t.integer "notification_type", null: false
    t.integer "recipient_role", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direct_message_id"], name: "index_moderation_notifications_on_direct_message_id"
    t.index ["message_id"], name: "index_moderation_notifications_on_message_id"
    t.index ["notification_type"], name: "index_moderation_notifications_on_notification_type"
    t.index ["recipient_id", "read_at"], name: "index_mod_notifications_on_recipient_and_read"
    t.index ["recipient_id"], name: "index_moderation_notifications_on_recipient_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.string "notification_type", null: false
    t.string "title", null: false
    t.string "body"
    t.text "metadata", default: "{}"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "parent_student_relationships", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "student_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "student_id"], name: "index_parent_student_relationships_on_parent_id_and_student_id", unique: true
    t.index ["student_id"], name: "index_parent_student_relationships_on_student_id"
  end

  create_table "parent_view_requests", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "child_id", null: false
    t.text "reason", null: false
    t.string "status", default: "pending", null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_parent_view_requests_on_child_id"
    t.index ["parent_id", "child_id"], name: "index_parent_view_requests_on_parent_id_and_child_id"
    t.index ["parent_id"], name: "index_parent_view_requests_on_parent_id"
    t.index ["reviewed_by_id"], name: "index_parent_view_requests_on_reviewed_by_id"
    t.index ["status"], name: "index_parent_view_requests_on_status"
  end

  create_table "qualification_flags", force: :cascade do |t|
    t.bigint "meet_result_id", null: false
    t.string "athlete_name", null: false
    t.string "school_abbr"
    t.string "event_name", null: false
    t.string "time_str"
    t.string "level", null: false
    t.string "standard_time"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meet_result_id"], name: "index_qualification_flags_on_meet_result_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "message_id"
    t.bigint "user_id", null: false
    t.string "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "direct_message_id"
    t.bigint "sport_emoji_id"
    t.index ["direct_message_id", "user_id", "emoji"], name: "index_reactions_on_dm_id_user_id_emoji", unique: true, where: "(direct_message_id IS NOT NULL)"
    t.index ["direct_message_id"], name: "index_reactions_on_direct_message_id"
    t.index ["message_id", "user_id", "emoji"], name: "index_reactions_on_message_id_user_id_emoji", unique: true, where: "(message_id IS NOT NULL)"
    t.index ["sport_emoji_id"], name: "index_reactions_on_sport_emoji_id"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "safety_review_signals", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "sport_template_id"
    t.string "category", null: false
    t.integer "decision", null: false
    t.string "sender_role", null: false
    t.string "channel_type"
    t.float "gemma_confidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_safety_review_signals_on_created_at"
    t.index ["school_id", "sport_template_id", "category"], name: "index_srs_on_school_sport_category"
    t.index ["school_id"], name: "index_safety_review_signals_on_school_id"
    t.index ["sport_template_id"], name: "index_safety_review_signals_on_sport_template_id"
  end

  create_table "schools", force: :cascade do |t|
    t.bigint "district_id", null: false
    t.string "name", null: false
    t.string "city"
    t.string "state"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon_url"
    t.string "banner_url"
    t.index ["district_id", "name"], name: "index_schools_on_district_id_and_name", unique: true
    t.index ["district_id"], name: "index_schools_on_district_id"
  end

  create_table "season_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "season_id", null: false
    t.integer "role", null: false
    t.boolean "is_captain", default: false, null: false
    t.integer "status", default: 0, null: false
    t.datetime "joined_at"
    t.datetime "removed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jersey_number"
    t.string "grade"
    t.string "level"
    t.string "position"
    t.index ["season_id"], name: "index_season_memberships_on_season_id"
    t.index ["user_id", "season_id"], name: "index_season_memberships_on_user_id_and_season_id", unique: true
    t.index ["user_id"], name: "index_season_memberships_on_user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.string "name", null: false
    t.string "school_year", null: false
    t.date "starts_at"
    t.date "ends_at"
    t.integer "status", default: 0, null: false
    t.datetime "archived_at"
    t.bigint "archived_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_by_id"], name: "index_seasons_on_archived_by_id"
    t.index ["sport_id", "school_year"], name: "index_seasons_on_sport_id_and_school_year", unique: true
    t.index ["sport_id"], name: "index_seasons_on_sport_id"
    t.index ["sport_id"], name: "index_seasons_on_sport_id_when_active", unique: true, where: "(status = 0)"
  end

  create_table "sport_commissionerships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sport_template_id", null: false
    t.bigint "district_id", null: false
    t.bigint "assigned_by_id"
    t.integer "status", default: 0, null: false
    t.datetime "assigned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_sport_commissionerships_on_assigned_by_id"
    t.index ["district_id"], name: "index_sport_commissionerships_on_district_id"
    t.index ["sport_template_id"], name: "index_sport_commissionerships_on_sport_template_id"
    t.index ["user_id", "sport_template_id", "district_id"], name: "index_sport_commissionerships_unique", unique: true
    t.index ["user_id"], name: "index_sport_commissionerships_on_user_id"
  end

  create_table "sport_emojis", force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.bigint "requested_by_id", null: false
    t.string "name", null: false
    t.string "image_url", null: false
    t.integer "status", default: 0, null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "appeal_reason"
    t.datetime "appealed_at"
    t.bigint "appeal_reviewed_by_id"
    t.datetime "appeal_reviewed_at"
    t.boolean "gemma_overridden", default: false, null: false
    t.index ["appealed_at"], name: "index_sport_emojis_on_appealed_at"
    t.index ["gemma_overridden"], name: "index_sport_emojis_on_gemma_overridden"
    t.index ["sport_id", "name"], name: "index_sport_emojis_on_sport_id_and_name", unique: true
    t.index ["sport_id"], name: "index_sport_emojis_on_sport_id"
    t.index ["status"], name: "index_sport_emojis_on_status"
  end

  create_table "sport_templates", force: :cascade do |t|
    t.bigint "district_id", null: false
    t.string "name", null: false
    t.integer "athletic_season", default: 0, null: false
    t.integer "gender_config", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id", "name"], name: "index_sport_templates_on_district_id_and_name", unique: true
    t.index ["district_id"], name: "index_sport_templates_on_district_id"
  end

  create_table "sports", force: :cascade do |t|
    t.string "sport_type"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id", null: false
    t.bigint "sport_template_id"
    t.integer "gender", default: 1, null: false
    t.string "levels", default: [], array: true
    t.index ["school_id"], name: "index_sports_on_school_id"
    t.index ["sport_template_id", "school_id", "gender"], name: "index_sports_on_sport_template_id_and_school_id_and_gender", unique: true
    t.index ["sport_template_id"], name: "index_sports_on_sport_template_id"
  end

  create_table "team_event_annotations", force: :cascade do |t|
    t.bigint "calendar_event_id", null: false
    t.bigint "season_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "warmup_time"
    t.text "team_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_event_id", "season_id"], name: "index_annotations_on_event_and_season", unique: true
    t.index ["calendar_event_id"], name: "index_team_event_annotations_on_calendar_event_id"
    t.index ["season_id"], name: "index_team_event_annotations_on_season_id"
    t.index ["updated_by_id"], name: "index_team_event_annotations_on_updated_by_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", null: false
    t.integer "scope", default: 0, null: false
    t.integer "variant", null: false
    t.bigint "school_id"
    t.bigint "created_by_id"
    t.string "color_background", null: false
    t.string "color_surface", null: false
    t.string "color_surface_variant", null: false
    t.string "color_border", null: false
    t.string "color_primary", null: false
    t.string "color_accent", null: false
    t.string "color_text_primary", null: false
    t.string "color_text_secondary", null: false
    t.string "color_text_on_primary", null: false
    t.string "color_text_on_accent", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_themes_on_active"
    t.index ["created_by_id"], name: "index_themes_on_created_by_id"
    t.index ["school_id", "variant"], name: "index_themes_on_school_id_and_variant_unique", unique: true, where: "(scope = 1)"
    t.index ["school_id"], name: "index_themes_on_school_id"
    t.index ["scope"], name: "index_themes_on_scope"
  end

  create_table "time_standards", force: :cascade do |t|
    t.bigint "sport_template_id", null: false
    t.string "gender", default: "girls", null: false
    t.string "event_name", null: false
    t.string "kingco"
    t.string "districts_wildcard"
    t.string "districts"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sport_template_id", "gender", "event_name"], name: "idx_time_standards_unique", unique: true
    t.index ["sport_template_id"], name: "index_time_standards_on_sport_template_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "password_digest"
    t.string "profile_photo_url"
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.bigint "invited_by_id"
    t.string "oauth_provider"
    t.string "oauth_uid"
    t.text "oauth_token"
    t.text "oauth_refresh_token"
    t.datetime "oauth_expires_at"
    t.string "jti"
    t.boolean "active", default: true, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "theme_id"
    t.string "preferred_language"
    t.jsonb "accessibility", default: {}, null: false
    t.jsonb "preferences", default: {}, null: false
    t.string "microsoft_uid"
    t.date "dob"
    t.index ["accessibility"], name: "index_users_on_accessibility", using: :gin
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["microsoft_uid"], name: "index_users_on_microsoft_uid", unique: true
    t.index ["preferences"], name: "index_users_on_preferences", using: :gin
    t.index ["theme_id"], name: "index_users_on_theme_id"
  end

  create_table "venues", force: :cascade do |t|
    t.bigint "school_id"
    t.string "name", null: false
    t.string "facility_type", default: "other", null: false
    t.string "address", default: "", null: false
    t.text "availability_json", default: "[]"
    t.boolean "temporarily_closed", default: false, null: false
    t.string "closed_reason", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_venues_on_school_id"
  end

  add_foreign_key "access_logs", "sports"
  add_foreign_key "access_logs", "users", column: "accessed_user_id"
  add_foreign_key "access_logs", "users", column: "accessor_id"
  add_foreign_key "access_notifications", "access_logs"
  add_foreign_key "access_notifications", "users", column: "notified_user_id"
  add_foreign_key "activities", "schools"
  add_foreign_key "activities", "seasons"
  add_foreign_key "activities", "users", column: "actor_id"
  add_foreign_key "calendar_events", "sports"
  add_foreign_key "calendar_events", "users", column: "created_by_id"
  add_foreign_key "channel_memberships", "channels"
  add_foreign_key "channel_memberships", "users"
  add_foreign_key "channels", "seasons"
  add_foreign_key "channels", "users", column: "created_by_id"
  add_foreign_key "commissioner_events", "districts"
  add_foreign_key "commissioner_events", "sport_templates"
  add_foreign_key "coop_authorizations", "schools"
  add_foreign_key "coop_authorizations", "sports"
  add_foreign_key "coop_authorizations", "users", column: "athletic_director_id"
  add_foreign_key "device_tokens", "users"
  add_foreign_key "direct_messages", "dm_conversations"
  add_foreign_key "direct_messages", "users", column: "flag_reviewed_by_id"
  add_foreign_key "direct_messages", "users", column: "sender_id"
  add_foreign_key "dm_conversations", "seasons"
  add_foreign_key "dm_conversations", "users", column: "participant_a_id"
  add_foreign_key "dm_conversations", "users", column: "participant_b_id"
  add_foreign_key "institution_roles", "districts"
  add_foreign_key "institution_roles", "schools"
  add_foreign_key "institution_roles", "users"
  add_foreign_key "invitations", "seasons"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "meet_results", "schools", column: "away_school_id"
  add_foreign_key "meet_results", "schools", column: "home_school_id"
  add_foreign_key "meet_results", "sports"
  add_foreign_key "meet_results", "users", column: "uploaded_by_id"
  add_foreign_key "message_challenges", "messages"
  add_foreign_key "message_challenges", "users", column: "challenger_id"
  add_foreign_key "message_challenges", "users", column: "reviewed_by_id"
  add_foreign_key "message_flags", "messages"
  add_foreign_key "message_flags", "users", column: "escalated_to_id"
  add_foreign_key "message_flags", "users", column: "flagged_by_id"
  add_foreign_key "message_flags", "users", column: "resolved_by_id"
  add_foreign_key "message_flags", "users", column: "reviewed_by_id"
  add_foreign_key "message_threads", "channels"
  add_foreign_key "message_translations", "messages"
  add_foreign_key "messages", "channels"
  add_foreign_key "messages", "message_threads"
  add_foreign_key "messages", "users", column: "deleted_by_id"
  add_foreign_key "messages", "users", column: "flag_reviewed_by_id"
  add_foreign_key "messages", "users", column: "pinned_by_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "moderation_notifications", "direct_messages"
  add_foreign_key "moderation_notifications", "messages"
  add_foreign_key "moderation_notifications", "users", column: "recipient_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "parent_student_relationships", "users", column: "parent_id"
  add_foreign_key "parent_student_relationships", "users", column: "student_id"
  add_foreign_key "parent_view_requests", "users", column: "child_id"
  add_foreign_key "parent_view_requests", "users", column: "parent_id"
  add_foreign_key "parent_view_requests", "users", column: "reviewed_by_id"
  add_foreign_key "qualification_flags", "meet_results"
  add_foreign_key "reactions", "direct_messages"
  add_foreign_key "reactions", "messages"
  add_foreign_key "reactions", "sport_emojis"
  add_foreign_key "reactions", "users"
  add_foreign_key "safety_review_signals", "schools"
  add_foreign_key "safety_review_signals", "sport_templates"
  add_foreign_key "schools", "districts"
  add_foreign_key "season_memberships", "seasons"
  add_foreign_key "season_memberships", "users"
  add_foreign_key "seasons", "sports"
  add_foreign_key "seasons", "users", column: "archived_by_id"
  add_foreign_key "sport_commissionerships", "districts"
  add_foreign_key "sport_commissionerships", "sport_templates"
  add_foreign_key "sport_commissionerships", "users"
  add_foreign_key "sport_commissionerships", "users", column: "assigned_by_id"
  add_foreign_key "sport_emojis", "sports"
  add_foreign_key "sport_emojis", "users", column: "appeal_reviewed_by_id"
  add_foreign_key "sport_emojis", "users", column: "requested_by_id"
  add_foreign_key "sport_emojis", "users", column: "reviewed_by_id"
  add_foreign_key "sport_templates", "districts"
  add_foreign_key "sports", "schools"
  add_foreign_key "sports", "sport_templates"
  add_foreign_key "team_event_annotations", "calendar_events"
  add_foreign_key "team_event_annotations", "seasons"
  add_foreign_key "team_event_annotations", "users", column: "updated_by_id"
  add_foreign_key "themes", "schools"
  add_foreign_key "themes", "users", column: "created_by_id"
  add_foreign_key "time_standards", "sport_templates"
  add_foreign_key "users", "themes"
  add_foreign_key "venues", "schools"
end
