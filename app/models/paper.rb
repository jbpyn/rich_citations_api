require 'uri'

class Paper < ActiveRecord::Base
  validates :uri, presence: true
  validate :valid_uri

  private

  def valid_uri
    parsed = URI.parse(uri)
    errors.add(:uri, 'must be a URI') if parsed.scheme.nil?
  rescue URI::InvalidURIError
    errors.add(:uri, 'must be a URI')
  end
end
