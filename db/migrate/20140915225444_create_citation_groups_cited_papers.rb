class CreateCitationGroupsCitedPapers < ActiveRecord::Migration
  def change
    create_table :citation_groups_cited_papers do |t|
      t.integer :citation_group_id
      t.integer :paper_id
    end
  end
end
