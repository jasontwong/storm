class RemoveExtraCrap < ActiveRecord::Migration
  def up
    drop_table :changelogs
    drop_table :client_groups
    drop_table :client_groups_client_permissions
    drop_table :client_permissions
    drop_table :client_permissions_clients
    drop_table :code_scan_locations
    drop_table :order_details
    drop_table :orders
    drop_table :product_categories
    drop_table :products
    drop_table :products_survey_questions
    remove_column :member_survey_answers, :product_id
  end
  
  def down
    create_table "changelogs", force: true do |t|
      t.string   "model_action"
      t.string   "model"
      t.text     "meta"
      t.datetime "created_at",   null: false
      t.datetime "updated_at",   null: false
      t.integer  "model_id"
    end

    create_table "client_groups", force: true do |t|
      t.string   "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "client_groups_client_permissions", id: false, force: true do |t|
      t.integer "client_group_id"
      t.integer "client_permission_id"
    end

    create_table "client_permissions", force: true do |t|
      t.string   "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "client_permissions_clients", id: false, force: true do |t|
      t.integer "client_id"
      t.integer "client_permission_id"
    end

    create_table "code_scan_locations", force: true do |t|
      t.decimal  "latitude",   precision: 10, scale: 6
      t.decimal  "longitude",  precision: 10, scale: 6
      t.integer  "member_id"
      t.integer  "code_id"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
      t.boolean  "success"
    end

    create_table "order_details", force: true do |t|
      t.integer  "order_id"
      t.integer  "product_id"
      t.string   "name"
      t.integer  "quantity"
      t.decimal  "discount",   precision: 10, scale: 0
      t.integer  "code_id"
      t.decimal  "price",      precision: 10, scale: 0
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    create_table "orders", force: true do |t|
      t.integer  "member_id"
      t.integer  "code_id"
      t.integer  "company_id"
      t.integer  "store_id"
      t.decimal  "amount",        precision: 10, scale: 0
      t.decimal  "survey_worth",  precision: 10, scale: 0
      t.decimal  "checkin_worth", precision: 10, scale: 0
      t.string   "server"
      t.datetime "created_at",                             null: false
      t.datetime "updated_at",                             null: false
    end

    create_table "product_categories", force: true do |t|
      t.string   "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "products", force: true do |t|
      t.string   "name"
      t.decimal  "price",               precision: 10, scale: 0
      t.string   "size"
      t.string   "company_id"
      t.datetime "created_at",                                   null: false
      t.datetime "updated_at",                                   null: false
      t.integer  "product_category_id"
      t.integer  "parent_id"
    end

    create_table "products_survey_questions", id: false, force: true do |t|
      t.integer "product_id"
      t.integer "survey_question_id"
    end

    change_table :member_survey_answers do |t|
      t.integer  "product_id"
    end

  end
end
