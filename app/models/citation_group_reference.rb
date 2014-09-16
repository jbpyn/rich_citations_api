class CitationGroupReference < ActiveRecord::Base
  belongs_to :citation_group
  belongs_to :reference
end
