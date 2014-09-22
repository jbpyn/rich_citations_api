class RefactorCitationGroups < ActiveRecord::Migration
  def change

    change_column :citation_groups, :citing_paper_id, :integer, null:false
    change_column :citation_groups, :position,        :integer, null:false
    add_index     :citation_groups, [:citing_paper_id, :position]

    change_column :citation_group_references, :citation_group_id, :integer, null:false
    change_column :citation_group_references, :reference_id,      :integer, null:false
    change_column :citation_group_references, :position,          :integer, null:false
    add_index :citation_group_references, [:citation_group_id, :position], name:'index_citation_group_references_on_group_id_and_position'
    add_index :citation_group_references, :reference_id

  end
end
