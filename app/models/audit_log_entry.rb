class AuditLogEntry < ActiveRecord::Base

  belongs_to :user
  belongs_to :paper

  validates :user,  presence:true
  validates :paper, presence:true

end
