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

module Serializer
  # Generic helper methods for Serializer mixins
  class Helper
    def self.normalize_uri(uri)
      return uri unless uri.match(/^http/)
      u = PostRank::URI.parse(uri)
      u.path = u.path.squeeze('/')
      u.query = u.query.presence
      u.to_s
    end

    def self.sanitize_html(html)
      if html.is_a? Array
        html.map { |s| sanitize_html(s) }
      else
        html.present? ? Loofah.fragment(html).scrub!(Helper::SANITIZER).scrub!(:strip).scrub!(:nofollow).to_s.presence : nil
      end
    end

    def self.sanitize_json_fields(json, field_list)
      json = json.dup
      field_list.each do |field|
        json[field] = self.sanitize_html(json[field])
      end
      json
    end

    SANITIZER = Rails::Html::PermitScrubber.new
    SANITIZER.tags = %w(a em i strong b u cite q mark abbr sub sup s wbr)
  end
end
