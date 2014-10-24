class AddCitationGroupsCounterCache < ActiveRecord::Migration
  def self.up  
    add_column :references, :mention_count, :integer, default: 0

    Reference.reset_column_information
    Reference.all.each do |r|
      r.update_attribute :mention_count, r.citation_group_references.count
    end
  end

  def self.down
    remove_column :references, :mention_count
  end
end
