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

ActiveRecord::Schema[8.0].define(version: 2025_07_29_125307) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.text "html_content"
    t.text "css_content"
    t.text "js_content"
    t.text "editable_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "component_type"
    t.text "template_patterns", default: "{{}}"
  end

  create_table "theme_page_components", force: :cascade do |t|
    t.bigint "theme_page_id", null: false
    t.bigint "component_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_theme_page_components_on_component_id"
    t.index ["theme_page_id"], name: "index_theme_page_components_on_theme_page_id"
  end

  create_table "theme_pages", force: :cascade do |t|
    t.bigint "theme_id", null: false
    t.string "page_type"
    t.text "component_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_theme_pages_on_theme_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.string "placeholder_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.string "name"
    t.string "subdomain"
    t.text "content_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_websites_on_theme_id"
    t.index ["user_id"], name: "index_websites_on_user_id"
  end

  add_foreign_key "theme_page_components", "components"
  add_foreign_key "theme_page_components", "theme_pages"
  add_foreign_key "theme_pages", "themes"
  add_foreign_key "websites", "themes"
  add_foreign_key "websites", "users"
end
