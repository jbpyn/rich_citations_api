class Paper < ActiveRecord::Base

  # relationships
  has_many :references,     foreign_key: :citing_paper_id,                    inverse_of: :citing_paper
  has_many :referenced_by,  foreign_key: :cited_paper_id,   class: Reference, inverse_of: :cited_paper
  has_many :cited_papers,   through:     :references,       class: Paper,     inverse_of:  :citing_papers
  has_many :citing_papers,  through:     :referenced_by,    class: Paper,     inverse_of:  :cited_papers
  has_many :audit_log_entries, inverse_of: :paper
  has_many :citation_groups, -> { order('position ASC') }, foreign_key: :citing_paper_id, dependent: :destroy, inverse_of: :citing_paper

  # validations
  validates :uri, presence:true, uri:true, uniqueness:true


  json_attribute :bibliographic
  json_attribute :extra, :foo

  def to_param
    "?id=#{URI.encode_www_form_component(uri)}"
  end
  
  def self.for_uri(uri)
    where(uri:uri).first
  end

  def reference_for_id(ref_id)
    references.detect{ |ref| ref.ref_id == ref_id }
  end

  def metadata(include_cited_paper=false)
    (extra || {}).merge(
      'uri'             => uri,
      'bibliographic'   => bibliographic,
      'references'      => references_metadata(include_cited_paper),
      'citation_groups' => citation_groups_metadata
    ).compact
  end
  alias to_json metadata

  def assign_metadata(metadata)
    metadata = metadata.dup

    # This is order dependent

    references = metadata.delete('references')
    create_references_from_metadata(references) if references.present?

    citation_groups = metadata.delete('citation_groups')
    create_citation_groups_from_metadata(citation_groups) if citation_groups.present?

    self.uri           = metadata.delete('uri')
    self.bibliographic = metadata.delete('bibliographic')
    self.extra         = metadata
  end

  def update_metadata(metadata, updating_user)
    assign_metadata(metadata)
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
