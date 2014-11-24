class AllowMultipleRefsToSamePaper < ActiveRecord::Migration
  def change
    # remove uniqueness constraint on index
    remove_index :references, [:citing_paper_id, :cited_paper_id]
    add_index :references, [:citing_paper_id, :cited_paper_id]
  end
end
