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

ActiveRecord::Schema[8.1].define(version: 2025_12_29_022515) do
  create_table "doctors", force: :cascade do |t|
    t.text "bio", null: false
    t.datetime "created_at", null: false
    t.integer "experience_years"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.string "photo_path"
    t.text "specialties", null: false
    t.datetime "updated_at", null: false
    t.index ["last_name", "first_name", "middle_name"], name: "index_doctors_on_last_name_and_first_name_and_middle_name"
  end

  create_table "service_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_service_categories_on_name", unique: true
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "service_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name"
    t.index ["price"], name: "index_services_on_price"
    t.index ["service_category_id"], name: "index_services_on_service_category_id"
  end

  create_table "tests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "services", "service_categories"
end
