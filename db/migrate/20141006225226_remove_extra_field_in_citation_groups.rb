class RemoveExtraFieldInCitationGroups < ActiveRecord::Migration
  def change
    remove_column :citation_groups, :extra
  end
end
