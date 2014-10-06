class RemoveExtraFieldInPapers < ActiveRecord::Migration
  def change
    remove_column :papers, :extra
  end
end
