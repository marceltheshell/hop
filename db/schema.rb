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

ActiveRecord::Schema.define(version: 20170519171028) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "citext"

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "address_type"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_addresses_on_user_id", using: :btree
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.jsonb    "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "cameras", force: :cascade do |t|
    t.integer  "venue_id"
    t.integer  "style"
    t.string   "tap_id"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.index ["tap_id"], name: "index_cameras_on_tap_id", using: :btree
    t.index ["venue_id"], name: "index_cameras_on_venue_id", using: :btree
  end

  create_table "identifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "identification_type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.binary   "encrypted_payload"
    t.uuid     "image_id"
    t.index ["user_id"], name: "index_identifications_on_user_id", using: :btree
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_transaction_id"
    t.uuid     "dc_uuid",                          null: false
    t.jsonb    "payload",             default: {}, null: false
    t.integer  "status",              default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["dc_uuid"], name: "index_line_items_on_dc_uuid", unique: true, using: :btree
    t.index ["user_id"], name: "index_line_items_on_user_id", using: :btree
    t.index ["user_transaction_id"], name: "index_line_items_on_user_transaction_id", using: :btree
  end

  create_table "payment_methods", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "token",             null: false
    t.binary   "encrypted_payload"
    t.index ["user_id"], name: "index_payment_methods_on_user_id", using: :btree
  end

  create_table "user_transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "description"
    t.integer  "amount_in_cents"
    t.integer  "balance_in_cents"
    t.jsonb    "metadata"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "employee_id"
    t.string   "venue_id"
    t.string   "tap_id"
    t.integer  "qty"
    t.index ["created_at"], name: "index_user_transactions_on_created_at", using: :btree
    t.index ["employee_id"], name: "index_user_transactions_on_employee_id", using: :btree
    t.index ["type"], name: "index_user_transactions_on_type", using: :btree
    t.index ["user_id"], name: "index_user_transactions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.citext   "email"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.float    "height_in_cm"
    t.float    "weight_in_kg"
    t.string   "gender"
    t.string   "phone"
    t.string   "password_digest"
    t.datetime "deactivated_at"
    t.string   "rfid"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "type"
    t.string   "role"
    t.string   "rfid_history",    default: [],              array: true
    t.uuid     "image_id"
    t.date     "dob"
    t.string   "pin"
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["phone"], name: "index_users_on_phone", using: :btree
    t.index ["pin"], name: "index_users_on_pin", using: :btree
    t.index ["rfid"], name: "index_users_on_rfid", unique: true, using: :btree
    t.index ["rfid_history"], name: "index_users_on_rfid_history", using: :gin
  end

  create_table "venues", force: :cascade do |t|
    t.string   "name"
    t.string   "drinkcommand_id"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal"
    t.text     "location"
    t.text     "hours"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["drinkcommand_id"], name: "index_venues_on_drinkcommand_id", using: :btree
  end

  add_foreign_key "addresses", "users", on_delete: :cascade
  add_foreign_key "cameras", "venues", on_delete: :cascade
  add_foreign_key "identifications", "users", on_delete: :cascade
  add_foreign_key "payment_methods", "users", on_delete: :cascade
  add_foreign_key "user_transactions", "users", on_delete: :cascade
end
