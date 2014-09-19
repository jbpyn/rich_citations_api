class AddPositionToCitationGroups < ActiveRecord::Migration
  def change
    add_column :citation_groups, :position, :integer
  end
end
