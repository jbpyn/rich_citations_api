class AddCitedPaperIdIndexToReferences < ActiveRecord::Migration
  def change
    add_index :references, :cited_paper_id
  end
end
