class AddUniqueIndexes < ActiveRecord::Migration
  def change
    add_index :references, [:citing_paper_id, :uri], unique: true
    add_index :references, [:citing_paper_id, :ref_id], unique: true
    add_index :references, [:citing_paper_id, :cited_paper_id], unique: true
    add_index :citation_groups, [:citing_paper_id, :group_id], unique: true
  end
end
