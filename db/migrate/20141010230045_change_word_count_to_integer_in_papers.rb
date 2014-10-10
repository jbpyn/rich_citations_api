class ChangeWordCountToIntegerInPapers < ActiveRecord::Migration
  def change
    change_column :papers, :word_count, :integer
  end
end
