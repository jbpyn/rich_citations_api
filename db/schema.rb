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

ActiveRecord::Schema.define(version: 20140917173105) do

  create_table "papers", force: true do |t|
    t.string   "uri"
    t.text     "bibliographic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extended"
  end

  create_table "references", force: true do |t|
    t.string   "uri"
    t.text     "text"
    t.integer  "index"
    t.integer  "citing_paper_id"
    t.integer  "cited_paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ref",             null: false
  end

  create_table "users", force: true do |t|
    t.string   "api_key",    limit: 36, null: false
    t.string   "full_name"
    t.string   "email"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", unique: true

end
