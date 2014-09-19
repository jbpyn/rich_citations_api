class CitationGroupReference < ActiveRecord::Base
  belongs_to :citation_group
  belongs_to :reference

  acts_as_list scope: :citation_group
end
