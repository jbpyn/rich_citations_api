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
  # Mixin module for Paper JSON Serialization.
  module Paper
    JSON_SCHEMA = JSON.parse(File.read(File.join(Rails.root, 'schemas', 'base.json')))

    def self.included base
      base.extend ClassMethods
    end

    def to_json(opts = {})
      result = LazyFieldedJson.new(
        opts.compact.fetch(:fields_paper, [:uri, :bibliographic, :references,
                                           :uri_source, :bib_source, :word_count,
                                           :citation_groups]))
      result.add(:uri) { uri }
      result.add(:bibliographic) { bibliographic }
      result.add(:references) { references.map { |r| r.to_json(opts) } }
      result.add(:uri_source) { uri_source }
      result.add(:bib_source) { bib_source }
      result.add(:word_count) { word_count }
      result.add(:citation_groups) { citation_groups.map { |g| g.to_json(opts) }.presence }
      result.build
    end

    BIB_CLEAN_FIELDS = %w(title container-title abstract subtitle)

    def assign_bibliographic_metadata(json)
      return unless json.present?
      self.bibliographic = Helper.sanitize_json_fields(json, BIB_CLEAN_FIELDS).compact
    end

    def set_from_json(json, context = {})
      return false unless JSON::Validator.validate(JSON_SCHEMA, json)
      uris = json['references'] && json['references'].map { |ref| ref['uri'] }
      assign_bibliographic_metadata(json['bibliographic'])

      ::Reference.new_from_json_array(json['references'], papers: ::Paper.where(uri: uris)).each do |ref|
        references << ref
      end
      json['citation_groups'].present? && json['citation_groups'].each do |json_g|
        g = ::CitationGroup.new
        citation_groups << g
        g.set_from_json(json_g)
      end

      self.uri           = Helper.normalize_uri(json['uri'])
      self.uri_source    = json['uri_source']
      self.bib_source    = json['bib_source']
      self.word_count    = json['word_count']
      true
    end
  end
end
