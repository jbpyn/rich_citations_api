class AddWordCountFieldToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :word_count, :number
  end
end
