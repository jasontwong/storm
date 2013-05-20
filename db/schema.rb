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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130520150713) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "logo"
    t.string   "location"
    t.string   "phone"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "member_attributes", :force => true do |t|
    t.integer "member_id"
    t.string  "name"
    t.string  "value"
  end

  create_table "members", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "salt"
    t.string   "fb_username"
    t.string   "fb_password"
    t.boolean  "active",      :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.decimal  "price"
    t.string   "size"
    t.string   "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rewards", :force => true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.string   "description"
    t.integer  "cost"
    t.datetime "starts"
    t.datetime "expires"
    t.integer  "uses_left"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "stores", :force => true do |t|
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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
