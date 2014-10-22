module Renderer
  class Base
    def format_author(a)
      return nil if a.nil?
      return a['literal'] if a['literal'].present?
      "#{a['family']}, #{a['given']}"
    end
  end
end
