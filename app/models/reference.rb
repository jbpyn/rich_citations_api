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

class Reference < Base

  include ::Serializer::Reference
  
  # relationships
  belongs_to :cited_paper,  class: Paper, inverse_of: :referenced_by, validate:true, autosave:true
  belongs_to :citing_paper, class: Paper, inverse_of: :references

  has_many   :citation_group_references, -> { order(:position) },
             counter_cache: 'mention_count',
             inverse_of: :reference, dependent: :destroy, autosave: true
  has_many   :citation_groups, -> { order('citation_groups.position') },
             through: :citation_group_references, class: CitationGroup,
             inverse_of: :references

  # uniqueness validation is done in the db schema to avoid hitting
  # the database
  validates :citing_paper, presence: true
  validates :number,       presence: true
  validates :uri,          presence: true, uri: true
  validates :ref_id,       presence: true

  json_attribute :self_citations
  def update_mention_count
    if new_record?
      self.mention_count = citation_group_references.count
    else
      count = citation_group_references.count
      update_column('mention_count', count) if count != mention_count
    end
  end

  default_scope -> { order(:number) }

  delegate :bibliographic,
           to: :cited_paper

  delegate :uri_source,
           to: :cited_paper

  def is_random_uri?
    /^cited:/ === uri
  end
end
