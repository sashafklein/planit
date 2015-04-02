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

ActiveRecord::Schema.define(version: 20150402012420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "days", force: :cascade do |t|
    t.integer  "leg_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "days", ["leg_id"], name: "index_days_on_leg_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "flags", force: :cascade do |t|
    t.text     "details"
    t.string   "name"
    t.integer  "object_id"
    t.string   "object_type"
    t.json     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["object_type", "object_id"], name: "index_flags_on_object_type_and_object_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "url",            limit: 255
    t.string   "source",         limit: 255
    t.string   "source_url",     limit: 255
    t.string   "subtitle",       limit: 255
    t.string   "imageable_type", limit: 255
    t.integer  "imageable_id"
    t.integer  "uploader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["uploader_id"], name: "index_images_on_uploader_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "mark_id"
    t.integer  "plan_id"
    t.integer  "day_id"
    t.integer  "order"
    t.integer  "day_of_week",             default: 0
    t.string   "start_time",  limit: 255
    t.float    "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",               default: true
    t.json     "extra",                   default: {}
  end

  add_index "items", ["day_id"], name: "index_items_on_day_id", using: :btree
  add_index "items", ["mark_id"], name: "index_items_on_mark_id", using: :btree
  add_index "items", ["plan_id"], name: "index_items_on_plan_id", using: :btree

  create_table "legs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "order"
    t.boolean  "bucket",                 default: false
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "legs", ["plan_id"], name: "index_legs_on_plan_id", using: :btree

  create_table "marks", force: :cascade do |t|
    t.integer  "leg_id"
    t.integer  "place_id"
    t.string   "mark",           limit: 255
    t.string   "category",       limit: 255
    t.string   "source",         limit: 255
    t.string   "source_url",     limit: 255
    t.boolean  "lodging"
    t.boolean  "meal"
    t.integer  "arrival_id"
    t.integer  "departure_id"
    t.boolean  "show_tab"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "groupable_type", limit: 255
    t.integer  "groupable_id"
    t.boolean  "published",                  default: true
    t.boolean  "been",                       default: false
    t.boolean  "loved",                      default: false
    t.boolean  "deleted",                    default: false
  end

  add_index "marks", ["arrival_id"], name: "index_marks_on_arrival_id", using: :btree
  add_index "marks", ["departure_id"], name: "index_marks_on_departure_id", using: :btree
  add_index "marks", ["groupable_id"], name: "index_marks_on_groupable_id", using: :btree
  add_index "marks", ["groupable_type"], name: "index_marks_on_groupable_type", using: :btree
  add_index "marks", ["leg_id"], name: "index_marks_on_leg_id", using: :btree
  add_index "marks", ["place_id"], name: "index_marks_on_place_id", using: :btree
  add_index "marks", ["user_id"], name: "index_marks_on_user_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "source_id"
    t.string   "source_type"
    t.text     "body"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "notes", ["object_type", "object_id"], name: "index_notes_on_object_type_and_object_id", using: :btree
  add_index "notes", ["source_type", "source_id"], name: "index_notes_on_source_type_and_source_id", using: :btree

  create_table "nps_feedbacks", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "nps_feedbacks", ["user_id"], name: "index_nps_feedbacks_on_user_id", using: :btree

  create_table "one_time_tasks", force: :cascade do |t|
    t.string   "action"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "agent_id"
    t.string   "agent_type"
    t.string   "detail"
    t.json     "extras"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "one_time_tasks", ["agent_type", "agent_id"], name: "index_one_time_tasks_on_agent_type_and_agent_id", using: :btree
  add_index "one_time_tasks", ["target_type", "target_id"], name: "index_one_time_tasks_on_target_type_and_target_id", using: :btree

  create_table "page_feedbacks", force: :cascade do |t|
    t.text     "details"
    t.string   "url"
    t.integer  "nps_feedback_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "page_feedbacks", ["nps_feedback_id"], name: "index_page_feedbacks_on_nps_feedback_id", using: :btree
  add_index "page_feedbacks", ["user_id"], name: "index_page_feedbacks_on_user_id", using: :btree

  create_table "place_options", force: :cascade do |t|
    t.integer  "price_tier"
    t.integer  "feature_type"
    t.integer  "mark_id"
    t.float    "lat"
    t.float    "lon"
    t.boolean  "wifi",              default: false
    t.boolean  "reservations",      default: false
    t.text     "description"
    t.text     "sublocality"
    t.text     "completion_steps",  default: [],                 array: true
    t.string   "street_addresses",  default: [],                 array: true
    t.string   "names",             default: [],                 array: true
    t.string   "meta_categories",   default: [],                 array: true
    t.string   "categories",        default: [],                 array: true
    t.string   "phones",            default: [],                 array: true
    t.string   "full_address"
    t.string   "subregion"
    t.string   "menu"
    t.string   "mobile_menu"
    t.string   "foursquare_id"
    t.string   "scrape_url"
    t.string   "timezone_string"
    t.string   "reservations_link"
    t.string   "website"
    t.string   "email"
    t.string   "contact_name"
    t.string   "postal_code"
    t.string   "cross_street"
    t.string   "country"
    t.string   "region"
    t.string   "locality"
    t.string   "price_note"
    t.json     "extra",             default: {}
    t.json     "hours",             default: {}
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "place_options", ["mark_id"], name: "index_place_options_on_mark_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "postal_code",       limit: 255
    t.string   "cross_street",      limit: 255
    t.string   "country",           limit: 255
    t.string   "region",            limit: 255
    t.string   "locality",          limit: 255
    t.float    "lat"
    t.float    "lon"
    t.string   "website",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "names",                         default: [],    array: true
    t.string   "email",             limit: 255
    t.string   "contact_name",      limit: 255
    t.integer  "price_tier"
    t.string   "price_note",        limit: 255
    t.text     "description"
    t.string   "subregion",         limit: 255
    t.string   "street_addresses",              default: [],    array: true
    t.string   "full_address",      limit: 255
    t.string   "categories",                    default: [],    array: true
    t.text     "completion_steps",              default: [],    array: true
    t.text     "sublocality"
    t.boolean  "wifi",                          default: false
    t.string   "menu",              limit: 255
    t.string   "mobile_menu",       limit: 255
    t.string   "foursquare_id",     limit: 255
    t.string   "scrape_url",        limit: 255
    t.string   "timezone_string",   limit: 255
    t.boolean  "reservations",                  default: false
    t.string   "reservations_link", limit: 255
    t.string   "meta_categories",               default: [],    array: true
    t.string   "phones",                        default: [],    array: true
    t.json     "extra",                         default: {}
    t.json     "hours",                         default: {}
    t.integer  "feature_type",                  default: 0
    t.boolean  "published",                     default: true
  end

  create_table "plans", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "user_id"
    t.text     "description"
    t.integer  "duration"
    t.text     "notes"
    t.string   "permission",  limit: 255, default: "public"
    t.float    "rating"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",        limit: 255,                    null: false
    t.boolean  "published",               default: true
  end

  add_index "plans", ["slug"], name: "index_plans_on_slug", unique: true, using: :btree
  add_index "plans", ["user_id"], name: "index_plans_on_user_id", using: :btree

  create_table "shares", force: :cascade do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.text     "notes"
    t.integer  "sharer_id"
    t.integer  "sharee_id"
    t.string   "url"
    t.boolean  "viewed",      default: false
    t.boolean  "accepted",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "shares", ["object_type", "object_id"], name: "index_shares_on_object_type_and_object_id", using: :btree
  add_index "shares", ["sharee_id"], name: "index_shares_on_sharee_id", using: :btree
  add_index "shares", ["sharer_id"], name: "index_shares_on_sharer_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.string   "name"
    t.string   "full_url"
    t.string   "trimmed_url"
    t.string   "base_url"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sources", ["object_type", "object_id"], name: "index_sources_on_object_type_and_object_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "travels", force: :cascade do |t|
    t.string   "mode",               limit: 255
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "departs_at"
    t.datetime "arrives_at"
    t.string   "vessel",             limit: 255
    t.integer  "next_step_id"
    t.text     "notes"
    t.string   "carrier",            limit: 255
    t.string   "departure_terminal", limit: 255
    t.string   "arrival_terminal",   limit: 255
    t.string   "confirmation_code",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "travels", ["from_id"], name: "index_travels_on_from_id", using: :btree
  add_index "travels", ["next_step_id"], name: "index_travels_on_next_step_id", using: :btree
  add_index "travels", ["to_id"], name: "index_travels_on_to_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                   limit: 255,              null: false
    t.integer  "role",                               default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
