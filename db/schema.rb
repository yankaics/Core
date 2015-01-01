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

ActiveRecord::Schema.define(version: 20141230171421) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admins", force: true do |t|
    t.string   "username",            default: "", null: false
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",     default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", unique: true, using: :btree
  add_index "admins", ["username"], name: "index_admins_on_username", unique: true, using: :btree

  create_table "departments", force: true do |t|
    t.string   "organization_code",           null: false
    t.string   "code",                        null: false
    t.string   "name",                        null: false
    t.string   "short_name",                  null: false
    t.string   "parent_code"
    t.string   "group",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["organization_code"], name: "index_departments_on_organization_code", using: :btree

  create_table "email_patterns", force: true do |t|
    t.integer  "priority",                                      default: 100, null: false
    t.string   "organization_code",                                           null: false
    t.integer  "corresponded_identity",               limit: 2,               null: false
    t.string   "email_regexp",                                                null: false
    t.text     "uid_postparser"
    t.text     "department_code_postparser"
    t.text     "started_at_postparser"
    t.text     "identity_detail_postparser"
    t.string   "permit_changing_department_in_group",           default: "f", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["code"], name: "index_organizations_on_code", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "user_data", force: true do |t|
    t.integer  "user_id",                            null: false
    t.integer  "gender",      limit: 2, default: 0,  null: false
    t.integer  "birth_year"
    t.integer  "birth_month", limit: 2
    t.integer  "birth_day",   limit: 2
    t.string   "url",                   default: "", null: false
    t.text     "brief",                 default: "", null: false
    t.text     "motto",                 default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_emails", force: true do |t|
    t.integer  "user_id",      null: false
    t.string   "email",        null: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_identities", force: true do |t|
    t.integer  "email_pattern_id"
    t.integer  "user_id"
    t.string   "email",                                               null: false
    t.string   "organization_code",                                   null: false
    t.integer  "identity",                            default: 0,     null: false
    t.string   "uid",                                                 null: false
    t.string   "original_department_code"
    t.string   "department_code"
    t.string   "identity_detail",                     default: "",    null: false
    t.date     "started_at"
    t.boolean  "permit_changing_department_in_group", default: false, null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "primary_identity_id"
    t.string   "name",                   default: "", null: false
    t.string   "avatar_url",             default: "", null: false
    t.string   "cover_photo_url",        default: "", null: false
    t.string   "fbid",                   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
