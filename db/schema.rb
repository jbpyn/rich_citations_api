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

ActiveRecord::Schema.define(version: 20140918202453) do

  create_table "citation_group_references", force: true do |t|
    t.integer "citation_group_id"
    t.integer "reference_id"
    t.integer "position"
  end

  create_table "citation_groups", force: true do |t|
    t.boolean "ellipses_before"
    t.text    "text_before"
    t.text    "text"
    t.text    "text_after"
    t.boolean "ellipses_after"
    t.integer "word_position"
    t.text    "section"
    t.integer "citing_paper_id"
  end

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

end
