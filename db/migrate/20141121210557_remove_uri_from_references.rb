class RemoveUriFromReferences < ActiveRecord::Migration
  def change
    remove_column :references, :uri
  end
end
