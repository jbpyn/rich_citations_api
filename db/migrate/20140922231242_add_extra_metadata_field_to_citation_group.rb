class AddExtraMetadataFieldToCitationGroup < ActiveRecord::Migration
  def change
    add_column    :citation_groups, :group_id, :string
    change_column :citation_groups, :group_id, :string, null:false
    add_column    :citation_groups, :extra,    :text
  end
end
