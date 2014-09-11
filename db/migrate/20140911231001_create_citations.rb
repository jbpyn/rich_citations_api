class CreateCitations < ActiveRecord::Migration
  def change
    create_table :citations do |t|
      t.string :uri
      t.text :text
      t.integer :index
      t.integer :citing_paper_id
      t.integer :cited_paper_id

      t.timestamps
    end
  end
end
