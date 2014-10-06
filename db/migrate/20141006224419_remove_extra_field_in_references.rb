class RemoveExtraFieldInReferences < ActiveRecord::Migration
  def change
    remove_column :references, :extra
  end
end
