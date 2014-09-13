class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :uri
      t.text :bibliographic

      t.timestamps
    end
  end
end
