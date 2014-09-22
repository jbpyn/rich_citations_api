class AuditLogEntry < ActiveRecord::Base

  belongs_to :user,  inverse_of: :audit_log_entries
  belongs_to :paper, inverse_of: :audit_log_entries

  validates :user,  presence:true
  validates :paper, presence:true

end
