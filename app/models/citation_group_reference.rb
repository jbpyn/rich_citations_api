class CitationGroupReference < ActiveRecord::Base
  belongs_to :citation_group, inverse_of: :citation_group_references
  belongs_to :reference,      inverse_of: :citation_group_references

  validates :citation_group, presence:true
  validates :reference,      presence:true

  acts_as_list scope: :citation_group

end
