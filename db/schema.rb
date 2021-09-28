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

ActiveRecord::Schema.define(version: 2021_09_28_144205) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_collocations", force: :cascade do |t|
    t.string "collocable_type"
    t.bigint "collocable_id"
    t.bigint "postal_address_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collocable_type", "collocable_id"], name: "index_address_collocations_on_collocable"
    t.index ["postal_address_id"], name: "index_address_collocations_on_postal_address_id"
  end

  create_table "chunks", force: :cascade do |t|
    t.string "text"
    t.integer "line_index"
    t.integer "line"
    t.integer "page"
    t.bigint "pdf_document_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pdf_document_id"], name: "index_chunks_on_pdf_document_id"
  end

  create_table "pdf_documents", force: :cascade do |t|
    t.float "size"
    t.string "name"
    t.string "creator"
    t.integer "num_of_pages"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.boolean "read_permission"
    t.boolean "write_permission"
    t.boolean "delete_permission"
    t.boolean "aggregate_permission"
    t.boolean "assign_permission"
    t.bigint "user_id", null: false
    t.string "permissionable_type"
    t.bigint "permissionable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["permissionable_type", "permissionable_id"], name: "index_permissions_on_permissionable"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "postal_addresses", force: :cascade do |t|
    t.string "street_1"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "alias"
    t.date "birthdate"
    t.string "gender"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["first_name", "middle_name", "last_name", "birthdate"], name: "by_name_and_birthdate"
  end

  create_table "stakes", force: :cascade do |t|
    t.string "name"
    t.string "designation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_stakes_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "profile_id", null: false
    t.boolean "admin", default: false
    t.index ["profile_id"], name: "index_users_on_profile_id"
  end

  create_table "ward_member_records", force: :cascade do |t|
    t.bigint "ward_id", null: false
    t.bigint "profile_id", null: false
    t.date "received_on"
    t.date "removed_on"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["profile_id"], name: "index_ward_member_records_on_profile_id"
    t.index ["ward_id"], name: "index_ward_member_records_on_ward_id"
  end

  create_table "wards", force: :cascade do |t|
    t.string "name"
    t.string "designation"
    t.bigint "stake_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_wards_on_name", unique: true
    t.index ["stake_id"], name: "index_wards_on_stake_id"
  end

  add_foreign_key "address_collocations", "postal_addresses"
  add_foreign_key "chunks", "pdf_documents"
  add_foreign_key "permissions", "users"
  add_foreign_key "users", "profiles"
  add_foreign_key "ward_member_records", "profiles"
  add_foreign_key "ward_member_records", "wards"
  add_foreign_key "wards", "stakes"
end
