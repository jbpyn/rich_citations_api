class AddCitingPaperId < ActiveRecord::Migration
  def change
    add_index(:citation_groups, :citing_paper_id)
  end
end
