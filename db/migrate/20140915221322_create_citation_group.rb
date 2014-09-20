class CreateCitationGroup < ActiveRecord::Migration
  def change
    create_table :citation_groups do |t|
      t.boolean :ellipses_before
      t.text :text_before
      t.text :text
      t.text :text_after
      t.boolean :ellipses_after
      t.integer :word_position
      t.text :section
      t.integer :citing_paper_id
    end
  end
end
