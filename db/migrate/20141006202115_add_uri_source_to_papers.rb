class AddUriSourceToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :uri_source, :string
  end
end
