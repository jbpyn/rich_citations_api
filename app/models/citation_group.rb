class CitationGroup < ActiveRecord::Base
  belongs_to :citing_paper, foreign_key: :citing_paper_id, class: Paper, inverse_of: :citation_groups
  has_many   :citation_group_references, -> { order(:position) },
             inverse_of: :citation_group, dependent: :destroy
  has_many   :references, -> { reorder('citation_group_references.position') },
             through: :citation_group_references, class: Reference,
             inverse_of: :citation_groups

  validates :citing_paper,              presence:true
  validates :citation_group_references, presence:true

  acts_as_list scope: :citing_paper
end
