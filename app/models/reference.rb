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

class Reference < Base

  # relationships
  belongs_to :cited_paper,  class: Paper, inverse_of: :referenced_by, validate:true, autosave:true
  belongs_to :citing_paper, class: Paper, inverse_of: :references

  has_many   :citation_group_references, -> { order(:position) },
             counter_cache: 'mention_count',
             inverse_of: :reference, dependent: :destroy
  has_many   :citation_groups, -> { order('citation_groups.position') },
             through: :citation_group_references, class: CitationGroup,
             inverse_of: :references

  # validations
  validates  :citing_paper, presence:true
  validates  :cited_paper,                 uniqueness: {scope: :citing_paper}
  validates  :number,       presence:true, uniqueness: {scope: :citing_paper}
  validates  :uri,          presence:true, uniqueness: {scope: :citing_paper}, uri:true
  validates  :ref_id,       presence:true, uniqueness: {scope: :citing_paper}

  def update_mention_count
    if new_record?
      self.mention_count = citation_group_references.count
    else
      update_column('mention_count', citation_group_references.count)
    end
  end

  default_scope -> { order(:number) }

  delegate :bibliographic,
           to: :cited_paper

  delegate :uri_source,
           to: :cited_paper

  def metadata(include_cited_paper=false)
    result = { 'number'            => number,
               'uri'               => uri,
               'uri_source'        => uri_source,
               'id'                => ref_id,
               'original_citation' => original_citation,
               'accessed_at'       => accessed_at,
               'score'             => score,
               'citation_groups'   => citation_groups.map(&:group_id).presence
             }

    if include_cited_paper && cited_paper
      result.merge!(
          'bib_source'    => cited_paper.bib_source,
          'word_count'    => cited_paper.word_count,
          'bibliographic' => bibliographic
      )
    end

    result.compact
  end
  alias to_json metadata

  #@todo: This method needs to make sure that it doesn't leave orphan
  #       Cited records when they are automatically generated (Have a random_citation_uri)
  def assign_metadata(metadata)
    metadata = metadata.dup
    uri_raw  = metadata.delete('uri')
    uri      = (uri_raw && normalize_uri(uri_raw)) || random_citation_uri
    ref_id   = metadata.delete('id')

    bibliographic   = metadata.delete('bibliographic')
    #@todo We ignore this data for now but should really validate it against paper/citation_groups/references
    citation_groups = metadata.delete('citation_groups')
    cited_paper     = Paper.for_uri(uri)

    unless cited_paper || bibliographic
      raise "Cannot assign metadata unless the paper exists or bibliographic metadata is provided for #{ref_id}" #@todo
    end

    if bibliographic
      cited_paper ||= Paper.new(uri:uri)
      cited_paper.assign_bibliographic_metadata(bibliographic)
    end

    cited_paper.uri_source = metadata.delete('uri_source')
    cited_paper.bib_source = metadata.delete('bib_source')
    cited_paper.word_count = metadata.delete('word_count')

    self.uri               = uri
    self.ref_id            = ref_id
    self.number            = metadata.delete('number')
    self.original_citation = sanitize_html( metadata.delete('original_citation') )
    self.accessed_at       = metadata.delete('accessed_at')
    self.score             = metadata.delete('score')
    self.cited_paper       = cited_paper
  end

  def is_random_uri?
    /^cited:/ === uri
  end

  private

  def random_citation_uri
    "cited:#{SecureRandom.uuid}"
  end


end
