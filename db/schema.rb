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

ActiveRecord::Schema.define(version: 20140914145633) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "days", force: true do |t|
    t.integer  "leg_id"
    t.integer  "order"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "days", ["leg_id"], name: "index_days_on_leg_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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

  create_table "images", force: true do |t|
    t.string   "url"
    t.string   "source"
    t.string   "source_url"
    t.string   "subtitle"
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.integer  "uploader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["uploader_id"], name: "index_images_on_uploader_id", using: :btree

  create_table "items", force: true do |t|
    t.integer  "leg_id"
    t.integer  "day_id"
    t.integer  "location_id"
    t.integer  "order"
    t.string   "mark"
    t.string   "category"
    t.string   "source"
    t.string   "source_url"
    t.boolean  "lodging"
    t.boolean  "meal"
    t.text     "notes"
    t.integer  "arrival_id"
    t.integer  "departure_id"
    t.boolean  "show_tab"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["arrival_id"], name: "index_items_on_arrival_id", using: :btree
  add_index "items", ["day_id"], name: "index_items_on_day_id", using: :btree
  add_index "items", ["departure_id"], name: "index_items_on_departure_id", using: :btree
  add_index "items", ["leg_id"], name: "index_items_on_leg_id", using: :btree
  add_index "items", ["location_id"], name: "index_items_on_location_id", using: :btree
  add_index "items", ["order"], name: "index_items_on_order", using: :btree

  create_table "legs", force: true do |t|
    t.string   "name"
    t.integer  "order"
    t.boolean  "bucket",     default: false
    t.text     "notes"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "legs", ["plan_id"], name: "index_legs_on_plan_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "local_name"
    t.string   "postal_code"
    t.string   "street_address"
    t.string   "cross_street"
    t.string   "phone"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.float    "lat"
    t.float    "lon"
    t.string   "url"
    t.string   "genre"
    t.string   "subgenre"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.text     "description"
    t.integer  "duration"
    t.text     "notes"
    t.text     "tips",        default: [],                    array: true
    t.string   "permission",  default: "public"
    t.float    "rating"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                           null: false
  end

  add_index "plans", ["slug"], name: "index_plans_on_slug", unique: true, using: :btree
  add_index "plans", ["user_id"], name: "index_plans_on_user_id", using: :btree

  create_table "travels", force: true do |t|
    t.string   "mode"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "departs_at"
    t.datetime "arrives_at"
    t.string   "vessel"
    t.integer  "next_step_id"
    t.text     "notes"
    t.string   "carrier"
    t.string   "departure_terminal"
    t.string   "arrival_terminal"
    t.string   "confirmation_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "travels", ["from_id"], name: "index_travels_on_from_id", using: :btree
  add_index "travels", ["next_step_id"], name: "index_travels_on_next_step_id", using: :btree
  add_index "travels", ["to_id"], name: "index_travels_on_to_id", using: :btree

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
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                                null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
