class FixTruncateInCitationGroups < ActiveRecord::Migration
  def change
    rename_column :citation_groups, :truncate_before, :truncated_before
    rename_column :citation_groups, :truncate_after,  :truncated_after
  end
end
