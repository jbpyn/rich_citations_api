class Citation < ActiveRecord::Base
  belongs_to :cited_paper, class: Paper
  belongs_to :citing_paper, class: Paper
  validates :citing_paper, uniqueness: {scope: :cited_paper}
end
