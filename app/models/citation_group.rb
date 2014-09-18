class CitationGroup < ActiveRecord::Base
  belongs_to :citing_paper, foreign_key: :citing_paper_id, class: Paper
  has_many :citation_group_references, -> { order(:ordering) }, before_add: :add_citation_ordering
  has_many :references, through: :citation_group_references, class: Reference

  def add_citation_ordering(cg_ref)
    if cg_ref.ordering.blank?
      cg_ref.ordering = citation_group_references.size
    end
  end
end
