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

ActiveRecord::Schema.define(version: 20150130000728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

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

  create_table "flags", force: true do |t|
    t.text     "details"
    t.string   "name"
    t.integer  "object_id"
    t.string   "object_type"
    t.json     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["object_id", "object_type"], name: "index_flags_on_object_id_and_object_type", using: :btree

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
    t.integer  "mark_id"
    t.integer  "plan_id"
    t.integer  "day_id"
    t.integer  "order"
    t.integer  "day_of_week", default: 0
    t.string   "start_time"
    t.float    "duration"
    t.hstore   "extra",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",   default: true
  end

  add_index "items", ["day_id"], name: "index_items_on_day_id", using: :btree
  add_index "items", ["mark_id"], name: "index_items_on_mark_id", using: :btree
  add_index "items", ["plan_id"], name: "index_items_on_plan_id", using: :btree

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

  create_table "marks", force: true do |t|
    t.integer  "leg_id"
    t.integer  "place_id"
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
    t.integer  "user_id"
    t.string   "groupable_type"
    t.integer  "groupable_id"
    t.boolean  "published",      default: true
  end

  add_index "marks", ["arrival_id"], name: "index_marks_on_arrival_id", using: :btree
  add_index "marks", ["departure_id"], name: "index_marks_on_departure_id", using: :btree
  add_index "marks", ["groupable_id"], name: "index_marks_on_groupable_id", using: :btree
  add_index "marks", ["groupable_type"], name: "index_marks_on_groupable_type", using: :btree
  add_index "marks", ["leg_id"], name: "index_marks_on_leg_id", using: :btree
  add_index "marks", ["place_id"], name: "index_marks_on_place_id", using: :btree
  add_index "marks", ["user_id"], name: "index_marks_on_user_id", using: :btree

  create_table "places", force: true do |t|
    t.string   "postal_code"
    t.string   "cross_street"
    t.string   "country"
    t.string   "region"
    t.string   "locality"
    t.float    "lat"
    t.float    "lon"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "names",             default: [],    array: true
    t.string   "email"
    t.string   "contact_name"
    t.hstore   "hours",             default: {}
    t.integer  "price_tier"
    t.string   "price_note"
    t.text     "description"
    t.hstore   "extra",             default: {}
    t.string   "subregion"
    t.string   "street_addresses",  default: [],    array: true
    t.string   "full_address"
    t.string   "categories",        default: [],    array: true
    t.text     "completion_steps",  default: [],    array: true
    t.text     "sublocality"
    t.boolean  "wifi",              default: false
    t.string   "menu"
    t.string   "mobile_menu"
    t.string   "foursquare_id"
    t.string   "scrape_url"
    t.string   "timezone_string"
    t.boolean  "reservations",      default: false
    t.string   "reservations_link"
    t.string   "meta_categories",   default: [],    array: true
    t.string   "phones",            default: [],    array: true
  end

  create_table "plans", force: true do |t|
    t.string   "name"
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
    t.boolean  "published",   default: true
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
    t.integer  "role",                   default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
