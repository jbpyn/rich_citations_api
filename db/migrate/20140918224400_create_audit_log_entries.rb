class CreateAuditLogEntries < ActiveRecord::Migration
  def change
    create_table :audit_log_entries do |t|
      t.references :user,       null:false
      t.references :paper,      null:false
      t.datetime   :created_at, null:false
    end
    add_index :audit_log_entries, :user_id
    add_index :audit_log_entries, :paper_id
  end
end
