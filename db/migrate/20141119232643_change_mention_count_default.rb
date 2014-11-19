class ChangeMentionCountDefault < ActiveRecord::Migration
  def change
    change_column :references, :mention_count, :integer, default: 1
  end
end
