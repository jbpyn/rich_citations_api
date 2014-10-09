class AddScoreFieldToReferences < ActiveRecord::Migration
  def change
    add_column :references, :score, :float
  end
end
