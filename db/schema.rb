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

ActiveRecord::Schema[8.0].define(version: 2026_05_09_221851) do
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
    t.bigint "sport_id", null: false
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
    t.index ["created_by_id"], name: "index_channels_on_created_by_id"
    t.index ["deleted_at"], name: "index_channels_on_deleted_at"
    t.index ["sport_id"], name: "index_channels_on_sport_id"
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
    t.index ["name"], name: "index_districts_on_name", unique: true
  end

  create_table "dm_conversations", force: :cascade do |t|
    t.bigint "participant_a_id", null: false
    t.bigint "participant_b_id", null: false
    t.bigint "sport_id", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_a_id", "participant_b_id", "sport_id"], name: "index_dm_conversations_unique", unique: true
    t.index ["participant_b_id"], name: "index_dm_conversations_on_participant_b_id"
    t.index ["sport_id"], name: "index_dm_conversations_on_sport_id"
  end

  create_table "institution_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "role", null: false
    t.bigint "district_id"
    t.bigint "school_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_institution_roles_on_district_id"
    t.index ["school_id"], name: "index_institution_roles_on_school_id"
    t.index ["user_id", "role", "district_id", "school_id"], name: "index_institution_roles_unique", unique: true
    t.index ["user_id"], name: "index_institution_roles_on_user_id"
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

  create_table "parent_student_relationships", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "student_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "student_id"], name: "index_parent_student_relationships_on_parent_id_and_student_id", unique: true
    t.index ["student_id"], name: "index_parent_student_relationships_on_student_id"
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

  create_table "schools", force: :cascade do |t|
    t.bigint "district_id", null: false
    t.string "name", null: false
    t.string "city"
    t.string "state"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id", "name"], name: "index_schools_on_district_id_and_name", unique: true
    t.index ["district_id"], name: "index_schools_on_district_id"
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

  create_table "sport_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sport_id", null: false
    t.bigint "school_id", null: false
    t.integer "role", null: false
    t.boolean "active", default: true, null: false
    t.date "joined_date"
    t.date "left_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_captain", default: false, null: false
    t.index ["school_id"], name: "index_sport_memberships_on_school_id"
    t.index ["sport_id", "role"], name: "index_sport_memberships_on_sport_id_and_role"
    t.index ["sport_id"], name: "index_sport_memberships_on_sport_id"
    t.index ["user_id", "sport_id"], name: "index_sport_memberships_on_user_id_and_sport_id", unique: true
  end

  create_table "sports", force: :cascade do |t|
    t.string "name", null: false
    t.string "sport_type"
    t.string "season"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id", null: false
    t.index ["school_id"], name: "index_sports_on_school_id"
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
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["theme_id"], name: "index_users_on_theme_id"
  end

  add_foreign_key "access_logs", "sports"
  add_foreign_key "access_logs", "users", column: "accessed_user_id"
  add_foreign_key "access_logs", "users", column: "accessor_id"
  add_foreign_key "access_notifications", "access_logs"
  add_foreign_key "access_notifications", "users", column: "notified_user_id"
  add_foreign_key "channel_memberships", "channels"
  add_foreign_key "channel_memberships", "users"
  add_foreign_key "channels", "sports"
  add_foreign_key "channels", "users", column: "created_by_id"
  add_foreign_key "coop_authorizations", "schools"
  add_foreign_key "coop_authorizations", "sports"
  add_foreign_key "coop_authorizations", "users", column: "athletic_director_id"
  add_foreign_key "device_tokens", "users"
  add_foreign_key "direct_messages", "dm_conversations"
  add_foreign_key "direct_messages", "users", column: "flag_reviewed_by_id"
  add_foreign_key "direct_messages", "users", column: "sender_id"
  add_foreign_key "dm_conversations", "sports"
  add_foreign_key "dm_conversations", "users", column: "participant_a_id"
  add_foreign_key "dm_conversations", "users", column: "participant_b_id"
  add_foreign_key "institution_roles", "districts"
  add_foreign_key "institution_roles", "schools"
  add_foreign_key "institution_roles", "users"
  add_foreign_key "message_flags", "messages"
  add_foreign_key "message_flags", "users", column: "escalated_to_id"
  add_foreign_key "message_flags", "users", column: "flagged_by_id"
  add_foreign_key "message_flags", "users", column: "resolved_by_id"
  add_foreign_key "message_flags", "users", column: "reviewed_by_id"
  add_foreign_key "message_threads", "channels"
  add_foreign_key "messages", "channels"
  add_foreign_key "messages", "message_threads"
  add_foreign_key "messages", "users", column: "deleted_by_id"
  add_foreign_key "messages", "users", column: "flag_reviewed_by_id"
  add_foreign_key "messages", "users", column: "pinned_by_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "moderation_notifications", "direct_messages"
  add_foreign_key "moderation_notifications", "messages"
  add_foreign_key "moderation_notifications", "users", column: "recipient_id"
  add_foreign_key "parent_student_relationships", "users", column: "parent_id"
  add_foreign_key "parent_student_relationships", "users", column: "student_id"
  add_foreign_key "reactions", "direct_messages"
  add_foreign_key "reactions", "messages"
  add_foreign_key "reactions", "sport_emojis"
  add_foreign_key "reactions", "users"
  add_foreign_key "schools", "districts"
  add_foreign_key "sport_emojis", "sports"
  add_foreign_key "sport_emojis", "users", column: "appeal_reviewed_by_id"
  add_foreign_key "sport_emojis", "users", column: "requested_by_id"
  add_foreign_key "sport_emojis", "users", column: "reviewed_by_id"
  add_foreign_key "sport_memberships", "schools"
  add_foreign_key "sport_memberships", "sports"
  add_foreign_key "sport_memberships", "users"
  add_foreign_key "sports", "schools"
  add_foreign_key "themes", "schools"
  add_foreign_key "themes", "users", column: "created_by_id"
  add_foreign_key "users", "themes"
end
