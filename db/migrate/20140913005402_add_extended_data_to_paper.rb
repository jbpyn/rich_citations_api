class AddExtendedDataToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :extended, :text
  end
end
