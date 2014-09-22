class Paper < ActiveRecord::Base

  # relationships
  has_many :references,     foreign_key: :citing_paper_id,                    inverse_of: :citing_paper
  has_many :referenced_by,  foreign_key: :cited_paper_id,   class: Reference, inverse_of: :cited_paper
  has_many :cited_papers,   through:     :references,       class: Paper
  has_many :citing_papers,  through:     :referenced_by,    class: Paper
  has_many :audit_log_entries
  has_many :citation_groups, -> { order('position ASC') }, foreign_key: :citing_paper_id, dependent: :destroy

  # validations
  validates :uri, presence:true, uri:true, uniqueness:true


  json_attribute :bibliographic
  json_attribute :extra, :foo

  def self.for_uri(uri)
    where(uri:uri).first
  end

  def metadata(include_cited_paper=false)
    (extra || {}).merge(
      'uri'           => uri,
      'bibliographic' => bibliographic,
      'references'    => references_metadata(include_cited_paper)
    ).compact
  end
  alias :to_json metadata

  def assign_metadata(metadata)
    metadata = metadata.dup

    references = metadata.delete('references')
    create_references_from_metadata(references) if references.present?

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

  def create_references_from_metadata(metadata)
    metadata && metadata.each do |metadata|
      reference = Reference.new
      reference.assign_metadata(metadata)
      references << reference
    end
  end

end
