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

ActiveRecord::Schema.define(version: 20150109180350) do

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

  create_table "cities", force: true do |t|
    t.string   "name",        default: "", null: false
    t.string   "permalink",   default: "", null: false
    t.string   "header",      default: ""
    t.text     "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["name"], name: "index_cities_on_name", unique: true, using: :btree
  add_index "cities", ["permalink"], name: "index_cities_on_permalink", unique: true, using: :btree

  create_table "days", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "days", ["name"], name: "index_days_on_name", unique: true, using: :btree

  create_table "event_days", force: true do |t|
    t.integer  "event_id",   null: false
    t.integer  "day_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_days", ["day_id"], name: "index_event_days_on_day_id", using: :btree
  add_index "event_days", ["event_id", "day_id"], name: "index_event_days_on_event_id_and_day_id", unique: true, using: :btree
  add_index "event_days", ["event_id"], name: "index_event_days_on_event_id", using: :btree

  create_table "event_descriptions", force: true do |t|
    t.text     "content"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_descriptions", ["event_id"], name: "index_event_descriptions_on_event_id", unique: true, using: :btree

  create_table "event_meta_types", force: true do |t|
    t.string   "name",          default: "", null: false
    t.integer  "event_type_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_types", force: true do |t|
    t.string   "name",       default: "", null: false
    t.string   "permalink",  default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_types", ["name"], name: "index_event_types_on_name", unique: true, using: :btree
  add_index "event_types", ["permalink"], name: "index_event_types_on_permalink", unique: true, using: :btree

  create_table "events", force: true do |t|
    t.string   "name",                      default: "", null: false
    t.string   "teaser",        limit: 140, default: ""
    t.string   "permalink",                 default: "", null: false
    t.string   "address",                   default: ""
    t.integer  "user_id",                                null: false
    t.integer  "event_type_id",                          null: false
    t.integer  "city_id",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["city_id"], name: "index_events_on_city_id", using: :btree
  add_index "events", ["event_type_id"], name: "index_events_on_event_type_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "attachment",     default: "", null: false
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name",                   default: "",    null: false
    t.boolean  "admin",                  default: false, null: false
    t.string   "provider",               default: ""
    t.string   "uid",                    default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
