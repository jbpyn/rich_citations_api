class AddSelfCitationToReferences < ActiveRecord::Migration
  def change
    add_column :references, :self_citations, :text
  end
end
