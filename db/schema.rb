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

ActiveRecord::Schema.define(version: 20160226075002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "fema_codes", force: :cascade do |t|
    t.string   "property_id"
    t.string   "property_name"
    t.string   "fema_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "state_code"
    t.string   "state_id"
    t.string   "pin"
    t.string   "details"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.string   "website"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "gsa_rates", force: :cascade do |t|
    t.string   "state"
    t.string   "primary_destination"
    t.string   "county"
    t.string   "jan"
    t.string   "feb"
    t.string   "mar"
    t.string   "apr"
    t.string   "may"
    t.string   "jun"
    t.string   "jul"
    t.string   "aug"
    t.string   "sep"
    t.string   "oct"
    t.string   "nov"
    t.string   "dec"
    t.string   "mim"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "invalid_urls", force: :cascade do |t|
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrapes", force: :cascade do |t|
    t.string   "name"
    t.string   "link"
    t.string   "rating"
    t.string   "s_address"
    t.string   "e_address"
    t.string   "city"
    t.string   "state"
    t.string   "pin"
    t.string   "star"
    t.string   "price"
    t.string   "total_reviews"
    t.string   "traveller_rating"
    t.text     "description"
    t.text     "amenities"
    t.text     "photos"
    t.text     "reviews"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "rooms"
  end

  create_table "tests", force: :cascade do |t|
    t.string   "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
