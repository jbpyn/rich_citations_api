class RefactorPapersTable < ActiveRecord::Migration
  def change
    change_column :papers, :uri,        :string,   null:false
    change_column :papers, :created_at, :datetime, null:false
    change_column :papers, :updated_at, :datetime, null:false

    rename_column :papers, :extended, :extra

    add_index :papers, :uri, unique:true
  end
end
