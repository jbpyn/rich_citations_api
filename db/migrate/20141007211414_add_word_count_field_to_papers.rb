class AddWordCountFieldToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :word_count, :integer
  end
end
