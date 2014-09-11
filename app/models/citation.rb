class Citation < ActiveRecord::Base
  belongs_to :cited_paper, class: Paper
  belongs_to :citing_paper, class: Paper
end
