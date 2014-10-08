class AddBibSourceFieldToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :bibr_source, :string
  end
end
