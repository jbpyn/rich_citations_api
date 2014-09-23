class RefactorReferences < ActiveRecord::Migration
  def change
    change_column :references, :uri,             :string,   null:false
    change_column :references, :number,          :integer,  null:false
    change_column :references, :citing_paper_id, :integer,  null:false
    change_column :references, :created_at,      :datetime, null:false
    change_column :references, :updated_at,      :datetime, null:false

    rename_column :references, :text, :extra

    add_index :references, [:cited_paper_id, :number],          unique:true
    add_index :references, :citing_paper_id
  end
end
