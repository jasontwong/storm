class AddTempPassAndTempPassExpToMember < ActiveRecord::Migration
  def change
    add_column :members, :temp_pass, :string
    add_column :members, :temp_pass_expiration, :date
  end
end
