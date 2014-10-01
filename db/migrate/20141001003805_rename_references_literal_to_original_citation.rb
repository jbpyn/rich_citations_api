class RenameReferencesLiteralToOriginalCitation < ActiveRecord::Migration
  def change
    rename_column :references, :literal, :original_citation
  end
end
