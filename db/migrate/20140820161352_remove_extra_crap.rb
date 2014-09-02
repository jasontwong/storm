class RemoveExtraCrap < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists? :changelogs
      drop_table :changelogs
    end
    if ActiveRecord::Base.connection.table_exists? :client_groups
      drop_table :client_groups
    end
    if ActiveRecord::Base.connection.table_exists? :client_groups_permissions
      drop_table :client_groups_permissions
    end
    if ActiveRecord::Base.connection.table_exists? :client_groups_client_permissions
      drop_table :client_groups_client_permissions
    end
    if ActiveRecord::Base.connection.table_exists? :client_permissions
      drop_table :client_permissions
    end
    if ActiveRecord::Base.connection.table_exists? :client_permissions_clients
      drop_table :client_permissions_clients
    end
    if ActiveRecord::Base.connection.table_exists? :code_scan_locations
      drop_table :code_scan_locations
    end
    if ActiveRecord::Base.connection.table_exists? :order_details
      drop_table :order_details
    end
    if ActiveRecord::Base.connection.table_exists? :orders
      drop_table :orders
    end
    if ActiveRecord::Base.connection.table_exists? :product_categories
      drop_table :product_categories
    end
    if ActiveRecord::Base.connection.table_exists? :products
      drop_table :products
    end
    if ActiveRecord::Base.connection.table_exists? :products_survey_questions
      drop_table :products_survey_questions
    end
    if column_exists? :member_survey_answers, :product_id
      remove_column :member_survey_answers, :product_id
    end
  end
  
  def down
  end
end
