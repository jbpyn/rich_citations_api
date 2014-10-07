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

ActiveRecord::Schema.define(version: 20141007211414) do

  create_table "audit_log_entries", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "paper_id",   null: false
    t.datetime "created_at", null: false
  end

  add_index "audit_log_entries", ["paper_id"], name: "index_audit_log_entries_on_paper_id"
  add_index "audit_log_entries", ["user_id"], name: "index_audit_log_entries_on_user_id"

  create_table "citation_group_references", force: true do |t|
    t.integer "citation_group_id", null: false
    t.integer "reference_id",      null: false
    t.integer "position",          null: false
  end

  add_index "citation_group_references", ["citation_group_id", "position"], name: "index_citation_group_references_on_group_id_and_position"
  add_index "citation_group_references", ["reference_id"], name: "index_citation_group_references_on_reference_id"

  create_table "citation_groups", force: true do |t|
    t.boolean "truncate_before"
    t.text    "text_before"
    t.text    "citation"
    t.text    "text_after"
    t.boolean "truncate_after"
    t.integer "word_position"
    t.text    "section"
    t.integer "citing_paper_id", null: false
    t.integer "position",        null: false
    t.string  "group_id",        null: false
  end

  add_index "citation_groups", ["citing_paper_id", "position"], name: "index_citation_groups_on_citing_paper_id_and_position"

  create_table "papers", force: true do |t|
    t.string   "uri",           null: false
    t.text     "bibliographic"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "uri_source"
    t.decimal  "word_count"
  end

  add_index "papers", ["uri"], name: "index_papers_on_uri", unique: true

  create_table "references", force: true do |t|
    t.string   "uri",                           null: false
    t.integer  "number",                        null: false
    t.integer  "citing_paper_id",               null: false
    t.integer  "cited_paper_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "ref_id",            limit: 255, null: false
    t.string   "original_citation"
    t.datetime "accessed_at"
  end

  add_index "references", ["cited_paper_id", "number"], name: "index_references_on_cited_paper_id_and_number", unique: true
  add_index "references", ["citing_paper_id"], name: "index_references_on_citing_paper_id"

  create_table "users", force: true do |t|
    t.string   "api_key",    limit: 36, null: false
    t.string   "full_name"
    t.string   "email"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", unique: true

end
