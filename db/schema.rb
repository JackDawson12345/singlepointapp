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

ActiveRecord::Schema[8.0].define(version: 2025_07_31_084917) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_setups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "domain_name"
    t.string "package_type"
    t.string "support_option"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_status", default: "pending"
    t.string "stripe_payment_intent_id"
    t.datetime "paid_at"
    t.index ["domain_name"], name: "index_account_setups_on_domain_name", unique: true
    t.index ["payment_status"], name: "index_account_setups_on_payment_status"
    t.index ["stripe_payment_intent_id"], name: "index_account_setups_on_stripe_payment_intent_id"
    t.index ["user_id"], name: "index_account_setups_on_user_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.text "html_content"
    t.text "css_content"
    t.text "js_content"
    t.text "editable_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "component_type"
    t.text "template_patterns", default: "{}"
    t.boolean "global"
    t.text "field_types", default: "{}"
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
    t.string "package"
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

  create_table "website_customizations", force: :cascade do |t|
    t.bigint "website_id", null: false
    t.bigint "component_id", null: false
    t.bigint "theme_page_id", null: false
    t.string "field_name", null: false
    t.text "field_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_website_customizations_on_component_id"
    t.index ["theme_page_id"], name: "index_website_customizations_on_theme_page_id"
    t.index ["website_id", "component_id", "theme_page_id", "field_name"], name: "unique_website_component_field", unique: true
    t.index ["website_id", "component_id", "theme_page_id"], name: "index_website_customizations_on_website_component_page"
    t.index ["website_id", "field_name"], name: "index_website_customizations_on_website_id_and_field_name"
    t.index ["website_id"], name: "index_website_customizations_on_website_id"
  end

  create_table "websites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published"
    t.index ["theme_id"], name: "index_websites_on_theme_id"
    t.index ["user_id"], name: "index_websites_on_user_id"
  end

  add_foreign_key "account_setups", "users"
  add_foreign_key "theme_page_components", "components"
  add_foreign_key "theme_page_components", "theme_pages"
  add_foreign_key "theme_pages", "themes"
  add_foreign_key "website_customizations", "components"
  add_foreign_key "website_customizations", "theme_pages"
  add_foreign_key "website_customizations", "websites"
  add_foreign_key "websites", "themes"
  add_foreign_key "websites", "users"
end
