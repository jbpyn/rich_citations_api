class AddLiteralToReferences < ActiveRecord::Migration
  def change
    add_column :references, :literal, :string
  end
end
