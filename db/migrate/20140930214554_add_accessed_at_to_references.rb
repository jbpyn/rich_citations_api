class AddAccessedAtToReferences < ActiveRecord::Migration
  def change
    add_column :references, :accessed_at, :datetime
  end
end
