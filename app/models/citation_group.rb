class CitationGroup < ActiveRecord::Base
  belongs_to :citing_paper, foreign_key: :citing_paper_id, class: Paper, inverse_of: :citation_groups
  has_many   :citation_group_references, -> { order(:position) },
             inverse_of: :citation_group, dependent: :destroy
  has_many   :references, -> { reorder('citation_group_references.position') },
             through: :citation_group_references, class: Reference,
             inverse_of: :citation_groups

  validates :citing_paper,              presence:true
  validates :citation_group_references, presence:true
  validates :group_id,                  presence:true, uniqueness:{scope: :citing_paper}

  acts_as_list scope: :citing_paper

  json_attribute :extra

  def metadata
    extra.merge(
            'id'              => group_id,
            'ellipses_before' => ellipses_before,
            'text_before'     => text_before,
            'text'            => text,
            'text_after'      => text_after,
            'ellipses_after'  => ellipses_after,
            'word_position'   => word_position,
            'section'         => section,
            'references'      => references.map { |r| r.ref_id }.presence
        ).compact
  end

  def assign_metadata(metadata)
    metadata = metadata.dup
    group_id = metadata.delete('id')

    reference_ids = metadata.delete('references')
    reference_ids && reference_ids.each do |ref_id|
      reference = citing_paper.reference_for_id(ref_id)
      raise "Reference #{ref_id.inspect} not found in citation group #{group_id.inspect}" unless reference
      self.references << reference
    end

    self.group_id        = group_id
    self.ellipses_before = metadata.delete('ellipses_before')
    self.text_before     = metadata.delete('text_before')
    self.text            = metadata.delete('text')
    self.text_after      = metadata.delete('text_after')
    self.ellipses_after  = metadata.delete('ellipses_after')
    self.word_position   = metadata.delete('word_position')
    self.section         = metadata.delete('section')
    self.extra           = metadata
  end

end
