class User < ActiveRecord::Base

  before_validation :set_api_key
  validates :api_key, presence:true, uniqueness:true
  validates :email, email:true
  validate  :validate_record!

  def self.for_key(api_key)
    where(api_key:api_key).first
  end

  def display
    result = "id:#{id}: " +
             [ full_name ? "name:#{full_name}" : nil,
               email     ? "email:#{email}"    : nil ].compact.join(', ')
  end

  private

  # Must provide eat least an mail or name
  def validate_record!
    errors.add(:base, 'Must provide an email or name') unless full_name || email
  end

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end

end
