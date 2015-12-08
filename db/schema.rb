# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151208145913) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admins", force: :cascade do |t|
    t.string   "username",                 default: "", null: false
    t.string   "email",                    default: "", null: false
    t.string   "encrypted_password",       default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",          default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "scoped_organization_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  add_index "admins", ["username"], name: "index_admins_on_username", unique: true

  create_table "data_api_versions", force: :cascade do |t|
    t.integer  "item_id",    null: false
    t.string   "item_type",  null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "data_api_versions", ["item_id", "item_type"], name: "index_data_api_versions_on_item_id_and_item_type"

  create_table "data_apis", force: :cascade do |t|
    t.string   "name",                                   null: false
    t.string   "path",                                   null: false
    t.string   "organization_code"
    t.string   "primary_key",        default: "id",      null: false
    t.text     "schema"
    t.text     "has"
    t.string   "default_order",      default: "id DESC", null: false
    t.string   "database_url"
    t.boolean  "maintain_schema",    default: true,      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accessible",         default: false,     null: false
    t.boolean  "public",             default: false,     null: false
    t.boolean  "owned_by_user",      default: false,     null: false
    t.string   "owner_primary_key"
    t.string   "owner_foreign_key"
    t.string   "description"
    t.text     "notes"
    t.string   "table_name",                             null: false
    t.boolean  "owner_writable",     default: false,     null: false
    t.string   "management_api_key",                     null: false
  end

  add_index "data_apis", ["accessible"], name: "index_data_apis_on_accessible"
  add_index "data_apis", ["name"], name: "index_data_apis_on_name", unique: true
  add_index "data_apis", ["organization_code"], name: "index_data_apis_on_organization_code"
  add_index "data_apis", ["owned_by_user"], name: "index_data_apis_on_owned_by_user"
  add_index "data_apis", ["owner_writable"], name: "index_data_apis_on_owner_writable"
  add_index "data_apis", ["path"], name: "index_data_apis_on_path", unique: true
  add_index "data_apis", ["public"], name: "index_data_apis_on_public"

  create_table "departments", force: :cascade do |t|
    t.string   "organization_code",           null: false
    t.string   "code",                        null: false
    t.string   "name",                        null: false
    t.string   "short_name",                  null: false
    t.string   "parent_code"
    t.string   "group",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["code"], name: "index_departments_on_code"
  add_index "departments", ["organization_code"], name: "index_departments_on_organization_code"
  add_index "departments", ["parent_code"], name: "index_departments_on_parent_code"

  create_table "email_patterns", force: :cascade do |t|
    t.integer  "priority",                                   limit: 3, default: 100,   null: false
    t.string   "organization_code",                                                    null: false
    t.integer  "corresponded_identity",                      limit: 1,                 null: false
    t.string   "email_regexp",                                                         null: false
    t.text     "uid_postparser"
    t.text     "department_code_postparser"
    t.text     "started_at_postparser"
    t.text     "identity_detail_postparser"
    t.boolean  "permit_changing_department_in_group",                  default: false, null: false
    t.boolean  "permit_changing_department_in_organization",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "skip_confirmation",                                    default: false, null: false
    t.boolean  "permit_changing_started_at",                           default: false, null: false
  end

  add_index "email_patterns", ["organization_code"], name: "index_email_patterns_on_organization_code"
  add_index "email_patterns", ["priority"], name: "index_email_patterns_on_priority"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "notifications", force: :cascade do |t|
    t.string   "uuid",                           null: false
    t.integer  "user_id"
    t.integer  "application_id"
    t.string   "subject"
    t.text     "message"
    t.string   "url"
    t.text     "payload"
    t.datetime "checked_at"
    t.datetime "clicked_at"
    t.boolean  "push",           default: false, null: false
    t.datetime "pushed_at"
    t.boolean  "email",          default: false, null: false
    t.datetime "emailed_at"
    t.boolean  "sms",            default: false, null: false
    t.datetime "sms_sent_at"
    t.boolean  "fb",             default: false, null: false
    t.datetime "fb_sent_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "notifications", ["checked_at"], name: "index_notifications_on_checked_at"
  add_index "notifications", ["clicked_at"], name: "index_notifications_on_clicked_at"
  add_index "notifications", ["email"], name: "index_notifications_on_email"
  add_index "notifications", ["emailed_at"], name: "index_notifications_on_emailed_at"
  add_index "notifications", ["fb"], name: "index_notifications_on_fb"
  add_index "notifications", ["fb_sent_at"], name: "index_notifications_on_fb_sent_at"
  add_index "notifications", ["push"], name: "index_notifications_on_push"
  add_index "notifications", ["pushed_at"], name: "index_notifications_on_pushed_at"
  add_index "notifications", ["sms"], name: "index_notifications_on_sms"
  add_index "notifications", ["sms_sent_at"], name: "index_notifications_on_sms_sent_at"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"
  add_index "notifications", ["uuid"], name: "index_notifications_on_uuid", unique: true

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                                       null: false
    t.text     "description"
    t.string   "app_url"
    t.integer  "owner_id",                                   null: false
    t.string   "owner_type",                                 null: false
    t.string   "uid",                                        null: false
    t.string   "secret",                                     null: false
    t.text     "redirect_uri",                               null: false
    t.string   "scopes",                     default: "",    null: false
    t.text     "extensional_scopes"
    t.text     "data"
    t.boolean  "blocked",                    default: false, null: false
    t.integer  "sms_quota",                  default: 0,     null: false
    t.integer  "rth",                        default: 0,     null: false
    t.datetime "rth_refreshed_at"
    t.integer  "rtd",                        default: 0,     null: false
    t.date     "rtd_refreshed_at"
    t.integer  "core_rth",                   default: 0,     null: false
    t.datetime "core_rth_refreshed_at"
    t.integer  "core_rtd",                   default: 0,     null: false
    t.date     "core_rtd_refreshed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_direct_data_access",   default: false, null: false
    t.boolean  "permit_push_notifications",  default: false
    t.boolean  "permit_email_notifications", default: false
    t.boolean  "permit_sms_notifications",   default: false
    t.boolean  "permit_fb_notifications",    default: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true

  create_table "organizations", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["code"], name: "index_organizations_on_code", unique: true

  create_table "service_navigations", force: :cascade do |t|
    t.string   "name",                                            null: false
    t.string   "url",                                             null: false
    t.string   "color"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.datetime "background_image_updated_at"
    t.string   "background_pattern_file_name"
    t.string   "background_pattern_content_type"
    t.integer  "background_pattern_file_size"
    t.datetime "background_pattern_updated_at"
    t.string   "description"
    t.text     "introduction"
    t.integer  "order",                           default: 100,   null: false
    t.boolean  "visible",                         default: false, null: false
    t.boolean  "opened",                          default: false, null: false
    t.boolean  "show_on_index",                   default: false, null: false
    t.boolean  "show_on_mobile_index",            default: false, null: false
    t.integer  "index_order",                     default: 100,   null: false
    t.integer  "index_size",                      default: 1,     null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "user_data", force: :cascade do |t|
    t.integer  "user_id",                                                 null: false
    t.integer  "gender",                        limit: 1, default: 0,     null: false
    t.integer  "birth_year"
    t.integer  "birth_month",                   limit: 1
    t.integer  "birth_day",                     limit: 1
    t.string   "url",                                     default: "",    null: false
    t.text     "brief",                                   default: "",    null: false
    t.text     "motto",                                   default: "",    null: false
    t.string   "mobile"
    t.string   "unconfirmed_mobile"
    t.string   "mobile_confirmation_token"
    t.datetime "mobile_confirmation_sent_at"
    t.integer  "mobile_confirm_tries",                    default: 0,     null: false
    t.text     "fb_devices"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "fb_friends"
    t.string   "unconfirmed_organization_code"
    t.string   "unconfirmed_department_code"
    t.string   "unconfirmed_started_year"
    t.integer  "avatar_crop_x"
    t.integer  "avatar_crop_y"
    t.integer  "avatar_crop_w"
    t.integer  "avatar_crop_h"
    t.boolean  "avatar_local",                            default: false, null: false
    t.boolean  "cover_photo_local",                       default: false, null: false
  end

  add_index "user_data", ["user_id"], name: "index_user_data_on_user_id"

  create_table "user_devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.integer  "type",       limit: 1
    t.string   "name"
    t.text     "device_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_devices", ["type"], name: "index_user_devices_on_type"
  add_index "user_devices", ["user_id"], name: "index_user_devices_on_user_id"
  add_index "user_devices", ["uuid"], name: "index_user_devices_on_uuid"

  create_table "user_emails", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.string   "email",                null: false
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_emails", ["confirmation_token"], name: "index_user_emails_on_confirmation_token", unique: true
  add_index "user_emails", ["confirmed_at"], name: "index_user_emails_on_confirmed_at"
  add_index "user_emails", ["email"], name: "index_user_emails_on_email"
  add_index "user_emails", ["user_id"], name: "index_user_emails_on_user_id"

  create_table "user_identities", force: :cascade do |t|
    t.integer  "email_pattern_id"
    t.integer  "user_id"
    t.string   "email",                                                      null: false
    t.string   "organization_code",                                          null: false
    t.integer  "identity",                                   default: 0,     null: false
    t.string   "uid",                                                        null: false
    t.string   "original_department_code"
    t.string   "department_code"
    t.string   "identity_detail",                            default: "",    null: false
    t.date     "started_at"
    t.boolean  "permit_changing_department_in_group",        default: false, null: false
    t.boolean  "permit_changing_department_in_organization", default: false, null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "skip_confirmation",                          default: false, null: false
    t.boolean  "permit_changing_started_at",                 default: false, null: false
  end

  add_index "user_identities", ["email"], name: "index_user_identities_on_email"
  add_index "user_identities", ["email_pattern_id"], name: "index_user_identities_on_email_pattern_id"
  add_index "user_identities", ["organization_code"], name: "index_user_identities_on_organization_code"
  add_index "user_identities", ["uid"], name: "index_user_identities_on_uid"
  add_index "user_identities", ["user_id"], name: "index_user_identities_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                    default: "", null: false
    t.string   "encrypted_password",       default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",          default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "primary_identity_id"
    t.string   "name",                     default: "", null: false
    t.string   "username"
    t.string   "external_avatar_url"
    t.string   "external_cover_photo_url"
    t.string   "fbid"
    t.text     "fbtoken"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",                                  null: false
    t.string   "fbemail"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["fbemail"], name: "index_users_on_fbemail"
  add_index "users", ["primary_identity_id"], name: "index_users_on_primary_identity_id", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true

end
