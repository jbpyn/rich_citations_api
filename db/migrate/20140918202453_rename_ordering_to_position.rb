class RenameOrderingToPosition < ActiveRecord::Migration
  def change
    rename_column :citation_group_references, :ordering, :position
  end
end
