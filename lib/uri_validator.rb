require 'uri'

class UriValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return if value.blank?
    parsed = URI.parse(value)
    record.errors.add(attribute, 'must be a URI') if parsed.scheme.nil?
  rescue URI::InvalidURIError
    record.errors.add(attribute, 'must be a URI')
  end

end