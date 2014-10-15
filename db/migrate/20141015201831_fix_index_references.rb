class FixIndexReferences < ActiveRecord::Migration
  def change
    add_index :references, [:citing_paper_id, :number],          unique:true
    remove_index :references, [:cited_paper_id, :number]
  end
end
