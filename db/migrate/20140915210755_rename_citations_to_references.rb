class RenameCitationsToReferences < ActiveRecord::Migration
  def change
    rename_table :citations, :references
  end
end
