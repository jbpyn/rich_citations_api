# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

class User < ActiveRecord::Base

  has_many :audit_log_entries, inverse_of: :user

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
