class AddCitedPapersIndex < ActiveRecord::Migration
  def change
    add_index(:papers, :references_count, name: 'cited_paper', where: '"references_count" > 0')
  end
end
