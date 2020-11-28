# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_07_204546) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.string "url"
    t.integer "user_id"
    t.string "name"
    t.text "extended_desc"
    t.datetime "orig_posting_time"
    t.boolean "in_rotation"
    t.boolean "private"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "old_user_site_id"
  end

  create_table "bookmarks_tags", force: :cascade do |t|
    t.bigint "bookmark_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bookmark_id"], name: "index_bookmarks_tags_on_bookmark_id"
    t.index ["tag_id"], name: "index_bookmarks_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_visits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "visit_timestamp"
    t.bigint "bookmark_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bookmark_id"], name: "index_user_visits_on_bookmark_id"
    t.index ["user_id"], name: "index_user_visits_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "password"
    t.string "email"
    t.string "full_name"
    t.string "nick"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookmarks_tags", "bookmarks"
  add_foreign_key "bookmarks_tags", "tags"
  add_foreign_key "user_visits", "bookmarks"
  add_foreign_key "user_visits", "users"
end
