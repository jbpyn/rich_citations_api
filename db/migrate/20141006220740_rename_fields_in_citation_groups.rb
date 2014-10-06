class RenameFieldsInCitationGroups < ActiveRecord::Migration
  def change
    rename_column :citation_groups, :text, :citation
    rename_column :citation_groups, :ellipses_before, :truncate_before
    rename_column :citation_groups, :ellipses_after, :truncate_after
  end
end
