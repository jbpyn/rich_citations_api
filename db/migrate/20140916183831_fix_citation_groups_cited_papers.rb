class FixCitationGroupsCitedPapers < ActiveRecord::Migration
  def change
    rename_table :citation_groups_cited_papers, :citation_group_references
    rename_column :citation_group_references, :paper_id, :reference_id
    add_column :citation_group_references, :ordering, :integer
  end
end
