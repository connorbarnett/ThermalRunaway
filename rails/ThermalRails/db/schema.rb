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

ActiveRecord::Schema.define(version: 20140529031030) do

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comparisons", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "winning_company_id"
    t.integer  "losing_company_id"
    t.string   "vote_location"
    t.string   "device_id"
    t.boolean  "was_skip"
    t.string   "winning_company_name"
    t.string   "losing_company_name"
  end

  add_index "comparisons", ["losing_company_id"], name: "index_comparisons_on_losing_company_id"
  add_index "comparisons", ["winning_company_id"], name: "index_comparisons_on_winning_company_id"

  create_table "votes", force: true do |t|
    t.string   "company"
    t.string   "vote_type"
    t.string   "vote_location"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "device_id"
  end

end
