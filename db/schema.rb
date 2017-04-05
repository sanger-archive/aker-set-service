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

ActiveRecord::Schema.define(version: 20170405102344) do

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
    t.integer  "owner_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name", unique: true, using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "accessible_type"
    t.integer  "accessible_id"
    t.string   "permittable_type"
    t.integer  "permittable_id"
    t.boolean  "r",                default: false
    t.boolean  "w",                default: false
    t.boolean  "x",                default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["accessible_type", "accessible_id"], name: "index_permissions_on_accessible_type_and_accessible_id", using: :btree
    t.index ["permittable_type", "permittable_id"], name: "index_permissions_on_permittable_type_and_permittable_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
  end

  add_foreign_key "aker_set_materials", "aker_materials"
  add_foreign_key "aker_set_materials", "aker_sets"
  add_foreign_key "aker_sets", "users", column: "owner_id"
end
