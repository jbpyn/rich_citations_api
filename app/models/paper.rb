# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

class Paper < Base

  # relationships
  has_many :references,     foreign_key: :citing_paper_id,                    inverse_of: :citing_paper, counter_cache: 'references_count'
  has_many :referenced_by,  foreign_key: :cited_paper_id,   class: Reference, inverse_of: :cited_paper
  has_many :cited_papers,   through:     :references,       class: Paper,     inverse_of:  :citing_papers
  has_many :citing_papers,  through:     :referenced_by,    class: Paper,     inverse_of:  :cited_papers
  has_many :audit_log_entries, inverse_of: :paper
  has_many :citation_groups, -> { order('position ASC') }, foreign_key: :citing_paper_id, dependent: :destroy, inverse_of: :citing_paper

  # validations
  validates :uri, presence:true, uri:true, uniqueness:true

  json_attribute :bibliographic

  # scope to preload everything in the paper
  scope :load_all, lambda {
    includes(citation_groups:
               { citation_group_references:
                   { reference: :cited_paper } })
  }

  # only papers that cite another paper
  scope :citing, -> { where('references_count > 0') }

  scope :random, -> (max) do
    max = count if max > count
    offset(rand(count - max + 1)).limit(max)
  end
  
  def to_param
    uri
  end

  after_save :update_mention_counts
  after_save :update_references_count

  include ::Serializer::Paper

  def update_references_count
    # cannot seem to get counter_cache to work without this
    update_column('references_count', references.count)
  end

  # counter cache only updates when using create, force it other times
  def update_mention_counts
    references.each(&:update_mention_count)
  end

  def reference_for_id(ref_id)
    references.find { |ref| ref.ref_id == ref_id }
  end

  def update_metadata(json, updating_user)
    return false unless set_from_json(json)
    saved = self.save
    AuditLogEntry.create(paper:self, user:updating_user) if saved
    saved
  end
end
