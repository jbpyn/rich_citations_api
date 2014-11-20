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
  module Reference
    def self.included base
      base.extend ::Serializer::ClassMethods
    end

    def to_json(opts = { })
      result = LazyFieldedJson.new(
        opts.compact.fetch(:fields, [:number, :uri, :uri_source, :id, :original_citation,
                                     :accessed_at, :score, :citation_groups, :bib_source, :word_count, :bibliographic,
                                     :self_citations
                                    ]))
      result.add(:number) { self.number }
      result.add(:uri) { self.uri }
      result.add(:uri_source) { self.uri_source }
      result.add(:id) { self.ref_id }
      result.add(:original_citation) { self.original_citation }
      result.add(:accessed_at) { self.accessed_at }
      result.add(:score) { self.score }
      result.add(:citation_groups) { self.citation_groups.map(&:group_id).presence }
      result.add(:bib_source) { self.cited_paper.bib_source }
      result.add(:word_count) { self.cited_paper.word_count }
      result.add(:bibliographic) { self.bibliographic }
      result.add(:self_citations) { self.self_citations }
      result.build
    end

    def set_from_json(json, context = {})
      uri_raw  = json['uri']
      self.uri = (uri_raw && Helper.normalize_uri(uri_raw)) || random_citation_uri
      self.ref_id = json['id']

      bibliographic = json['bibliographic']

      cited_paper ||= context[:papers] && context[:papers].find { |p| p.uri == uri } 
      cited_paper ||= ::Paper.find_by(uri: uri)

      unless cited_paper || bibliographic
        fail "Cannot assign metadata unless the paper exists or bibliographic metadata is provided for #{ref_id}" #@todo
      end

      if bibliographic
        cited_paper ||= ::Paper.new(uri: uri)
        cited_paper.assign_bibliographic_metadata(bibliographic)
      end

      cited_paper.uri_source = json['uri_source']
      cited_paper.bib_source = json['bib_source']
      cited_paper.word_count = json['word_count']

      self.uri               = uri
      self.ref_id            = ref_id
      self.number            = json['number']
      self.original_citation = Helper.sanitize_html(json['original_citation'])
      self.accessed_at       = json['accessed_at']
      self.score             = json['score']
      self.cited_paper       = cited_paper
      self.self_citations    = json['self_citations']
    end

    def random_citation_uri
      "cited:#{SecureRandom.uuid}"
    end
  end
end
