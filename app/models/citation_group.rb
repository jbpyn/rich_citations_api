class CitationGroup < ActiveRecord::Base
  has_many :citation_groups_cited_papers
  has_many :cited_papers, through: :citation_groups_cited_papers, class: Paper
  belongs_to :citing_paper, foreign_key: :citing_paper_id, class: Paper
end
