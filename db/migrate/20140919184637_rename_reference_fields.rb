class RenameReferenceFields < ActiveRecord::Migration
  def change
    rename_column :references, :ref,   :ref_id
    rename_column :references, :index, :number
  end
end
