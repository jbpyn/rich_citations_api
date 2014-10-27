class AddReferencesCountCacheToPaper < ActiveRecord::Migration
  def self.up  
    add_column :papers, :references_count, :integer, default: 0

    Paper.reset_column_information
    Paper.find_each do |p|
      p.update_attribute :references_count, p.references.count
    end
  end

  def self.down
    remove_column :papers, :references_count
  end
end
