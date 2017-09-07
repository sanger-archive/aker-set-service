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

ActiveRecord::Schema.define(version: 20170823122238) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "aker_materials", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "aker_set_materials", force: :cascade do |t|
    t.uuid     "aker_set_id"
    t.uuid     "aker_material_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["aker_material_id"], name: "index_aker_set_materials_on_aker_material_id", using: :btree
    t.index ["aker_set_id"], name: "index_aker_set_materials_on_aker_set_id", using: :btree
  end

  create_table "aker_sets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "locked",     default: false, null: false
    t.string   "owner_id"
  end

  add_foreign_key "aker_set_materials", "aker_materials"
  add_foreign_key "aker_set_materials", "aker_sets"
end
