class AddBibSourceFieldToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :bib_source, :string
  end
end
