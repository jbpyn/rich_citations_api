class AddLimits < ActiveRecord::Migration
  def change
    change_column :citation_groups, :group_id,  :string, limit: 255, null: false
    change_column :papers,          :uri,       :string, limit: 255, null: false
    change_column :references,      :uri,       :string, limit: 255, null: false
    change_column :users,           :email,     :string, limit: 255, null: false
    change_column :users,           :full_name, :string, limit: 255, null: false
  end
end
