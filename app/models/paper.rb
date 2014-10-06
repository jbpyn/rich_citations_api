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

class Paper < Base

  # relationships
  has_many :references,     foreign_key: :citing_paper_id,                    inverse_of: :citing_paper
  has_many :referenced_by,  foreign_key: :cited_paper_id,   class: Reference, inverse_of: :cited_paper
  has_many :cited_papers,   through:     :references,       class: Paper,     inverse_of:  :citing_papers
  has_many :citing_papers,  through:     :referenced_by,    class: Paper,     inverse_of:  :cited_papers
  has_many :audit_log_entries, inverse_of: :paper
  has_many :citation_groups, -> { order('position ASC') }, foreign_key: :citing_paper_id, dependent: :destroy, inverse_of: :citing_paper

  # validations
  validates :uri, presence:true, uri:true, uniqueness:true

  JSON_SCHEMA = JSON.parse(File.read(File.join(Rails.root, 'schemas', 'base.json')))

  json_attribute :bibliographic

  def to_param
    uri
  end
  
  def self.for_uri(uri)
    where(uri:uri).first
  end

  def reference_for_id(ref_id)
    references.detect{ |ref| ref.ref_id == ref_id }
  end

  def metadata(include_cited_paper=false)
    { 'uri'             => uri,
      'bibliographic'   => bibliographic,
      'references'      => references_metadata(include_cited_paper),
      'uri_source'      => uri_source,
      'citation_groups' => citation_groups_metadata
    }.compact
  end
  alias to_json metadata

  def assign_metadata(metadata)
    return false unless JSON::Validator.validate(JSON_SCHEMA, metadata)

    metadata = metadata.dup

    # This is order dependent

    assign_bibliographic_metadata( metadata.delete('bibliographic') )

    references = metadata.delete('references')
    create_references_from_metadata(references) if references.present?

    citation_groups = metadata.delete('citation_groups')
    create_citation_groups_from_metadata(citation_groups) if citation_groups.present?

    self.uri           = metadata.delete('uri')
    self.uri_source    = metadata.delete('uri_source')
    true
  end

  def assign_bibliographic_metadata(metadata)
    if metadata.present?
      metadata = metadata.dup

      metadata['title']           = sanitize_html(metadata['title'] )
      metadata['container-title'] = sanitize_html(metadata['container-title'] )
      metadata['abstract']        = sanitize_html(metadata['abstract'])

      subtitles = metadata['subtitle']
      if subtitles.present?
        subtitles.each_index do |i| subtitles[i] = sanitize_html(subtitles[i]) end
      end
    end

    self.bibliographic = metadata && metadata.compact
  end

  def update_metadata(metadata, updating_user)
    return false unless assign_metadata(metadata)
    saved = self.save
    AuditLogEntry.create(paper:self, user:updating_user) if saved
    saved
  end

  private

  def references_metadata(include_cited_papers=false)
    return nil if references.empty?

    references.map { |r| r.metadata(include_cited_papers) }
  end

  def citation_groups_metadata
    return nil if citation_groups.empty?

    citation_groups.map { |g| g.metadata }
  end

  def create_references_from_metadata(metadata)
    metadata && metadata.each do |metadata|
      reference = Reference.new
      references << reference
      reference.assign_metadata(metadata)
    end
  end

  def create_citation_groups_from_metadata(metadata)
    metadata && metadata.each do |metadata|
      citation_group = CitationGroup.new
      citation_groups << citation_group
      citation_group.assign_metadata(metadata)
    end
  end

end
