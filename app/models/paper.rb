require 'uri'

class Paper < ActiveRecord::Base
  validates :uri, presence: true
  validate :valid_uri
  has_many :citations, foreign_key: :citing_paper_id
  
  private

  def valid_uri
    parsed = URI.parse(uri)
    errors.add(:uri, 'must be a URI') if parsed.scheme.nil?
  rescue URI::InvalidURIError
    errors.add(:uri, 'must be a URI')
  end
end
