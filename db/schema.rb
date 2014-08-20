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

ActiveRecord::Schema.define(version: 20140820022437) do

  create_table "api_keys", force: true do |t|
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", force: true do |t|
    t.integer  "company_id"
    t.string   "email"
    t.string   "password"
    t.integer  "client_group_id"
    t.string   "name"
    t.string   "salt"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "temp_password"
    t.boolean  "tos"
  end

  create_table "clients_stores", id: false, force: true do |t|
    t.integer "client_id"
    t.integer "store_id"
  end

  create_table "codes", force: true do |t|
    t.string   "qr"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "used"
    t.boolean  "active"
    t.datetime "last_used_time"
    t.text     "text"
    t.integer  "store_id"
    t.boolean  "static"
    t.integer  "major"
    t.integer  "minor"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "logo"
    t.string   "location"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_question_limit"
    t.text     "html"
    t.integer  "worth_type",            limit: 1
    t.text     "worth_meta"
    t.boolean  "active"
  end

  add_index "companies", ["active"], name: "index_companies_on_active", using: :btree

  create_table "member_answers", force: true do |t|
    t.integer  "member_id"
    t.integer  "code_id"
    t.string   "question"
    t.string   "answer"
    t.boolean  "completed"
    t.datetime "completed_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_attributes", force: true do |t|
    t.integer "member_id"
    t.string  "name"
    t.string  "value"
  end

  create_table "member_points", force: true do |t|
    t.integer  "member_id"
    t.integer  "company_id"
    t.decimal  "points",       precision: 10, scale: 0
    t.decimal  "total_points", precision: 10, scale: 0
    t.datetime "last_earned"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_rewards", force: true do |t|
    t.integer  "member_id"
    t.integer  "reward_id"
    t.boolean  "redeemed"
    t.integer  "store_id"
    t.integer  "printed"
    t.integer  "scanned"
    t.string   "code"
    t.binary   "bcode"
    t.datetime "redeemed_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_survey_answers", force: true do |t|
    t.integer  "member_survey_id"
    t.string   "question"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_question_id"
  end

  create_table "member_surveys", force: true do |t|
    t.integer  "code_id"
    t.integer  "member_id"
    t.integer  "company_id"
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed"
    t.datetime "completed_time"
    t.text     "comments"
    t.decimal  "worth",          precision: 10, scale: 0
  end

  create_table "members", force: true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "salt"
    t.string   "fb_username"
    t.string   "fb_password"
    t.boolean  "active",                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "other_id"
    t.string   "temp_pass"
    t.date     "temp_pass_expiration"
    t.integer  "fb_id",                limit: 8
  end

  create_table "rewards", force: true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.string   "description"
    t.integer  "cost"
    t.datetime "starts"
    t.datetime "expires"
    t.integer  "uses_left"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "images"
  end

  add_index "rewards", ["company_id"], name: "index_rewards_on_company_id", using: :btree

  create_table "stores", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "phone"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "receipt_type"
    t.string   "full_address"
  end

  add_index "stores", ["company_id"], name: "index_stores_on_company_id", using: :btree

  create_table "stores_surveys", id: false, force: true do |t|
    t.integer "store_id"
    t.integer "survey_id"
  end

  create_table "survey_question_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "survey_questions", force: true do |t|
    t.string   "question"
    t.string   "answer_type"
    t.text     "answer_meta"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.boolean  "dynamic"
    t.text     "dynamic_meta"
    t.integer  "survey_question_category_id"
  end

  create_table "survey_questions_surveys", id: false, force: true do |t|
    t.integer "survey_question_id"
    t.integer "survey_id"
  end

  create_table "surveys", force: true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.string   "description"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
