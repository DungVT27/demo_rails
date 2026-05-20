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

ActiveRecord::Schema[8.1].define(version: 2026_05_20_030315) do
  create_table "bookings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "booking_date", null: false
    t.time "booking_time", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "status", default: 0, null: false
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["deleted_at"], name: "index_bookings_on_deleted_at"
    t.index ["store_id"], name: "index_bookings_on_store_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "stores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address", null: false
    t.decimal "booking_fee", precision: 8, scale: 2, default: "0.0", null: false
    t.time "closing_time", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.string "name", null: false
    t.time "opening_time", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_stores_on_deleted_at"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookings", "stores"
  add_foreign_key "bookings", "users"
end
