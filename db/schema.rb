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

ActiveRecord::Schema.define(version: 20140529085643) do

  create_table "elements", force: true do |t|
    t.string   "name"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elements", ["entity_id"], name: "index_elements_on_entity_id", using: :btree

  create_table "eras", force: true do |t|
    t.string   "name"
    t.date     "starts_on"
    t.date     "ends_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eventcategories", force: true do |t|
    t.string   "name"
    t.integer  "pecking_order"
    t.boolean  "schoolwide"
    t.boolean  "publish"
    t.boolean  "public"
    t.boolean  "for_users"
    t.boolean  "unimportant"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.text     "body"
    t.integer  "eventcategory_id",                 null: false
    t.integer  "eventsource_id",                   null: false
    t.integer  "owner_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "approximate",      default: false
    t.boolean  "non_existent",     default: false
    t.boolean  "private",          default: false
    t.integer  "reference_id"
    t.string   "reference_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "all_day",          default: false
  end

  create_table "eventsources", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.date     "starts_on",          null: false
    t.date     "ends_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visible_group_id"
    t.string   "visible_group_type"
  end

  create_table "locations", force: true do |t|
    t.string   "short_name"
    t.string   "name"
    t.integer  "source_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",    default: false
  end

  add_index "locations", ["source_id"], name: "index_locations_on_source_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "group_id",   null: false
    t.integer  "element_id", null: false
    t.date     "starts_on",  null: false
    t.date     "ends_on"
    t.date     "as_at"
    t.boolean  "inverse",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  add_index "memberships", ["element_id"], name: "index_memberships_on_element_id", using: :btree
  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree

  create_table "pupils", force: true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "forename"
    t.string   "known_as"
    t.string   "email"
    t.string   "candidate_no"
    t.integer  "start_year"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",      default: false
  end

  add_index "pupils", ["source_id"], name: "index_pupils_on_source_id", using: :btree

  create_table "staffs", force: true do |t|
    t.string   "name"
    t.string   "initials"
    t.string   "surname"
    t.string   "title"
    t.string   "forename"
    t.string   "email"
    t.integer  "source_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",    default: false
  end

  add_index "staffs", ["source_id"], name: "index_staffs_on_source_id", using: :btree

  create_table "tutorgroups", force: true do |t|
    t.string   "name"
    t.string   "house"
    t.integer  "staff_id"
    t.integer  "era_id"
    t.integer  "start_year"
    t.boolean  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
