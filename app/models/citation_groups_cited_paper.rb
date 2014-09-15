class CitationGroupsCitedPaper < ActiveRecord::Base
  belongs_to :citation_group_paper
  belongs_to :cited_paper, class: Paper
end
