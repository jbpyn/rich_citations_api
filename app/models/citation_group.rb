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

class CitationGroup < Base
  belongs_to :citing_paper, foreign_key: :citing_paper_id, class: Paper, inverse_of: :citation_groups
  has_many   :citation_group_references, -> { order(:position) },
             inverse_of: :citation_group, dependent: :destroy
  has_many   :references, -> { reorder('citation_group_references.position') },
             through: :citation_group_references, class: Reference,
             inverse_of: :citation_groups

  validates :citing_paper,              presence:true
  validates :citation_group_references, presence:true
  validates :group_id,                  presence:true, uniqueness:{scope: :citing_paper}

  acts_as_list scope: :citing_paper

  def metadata
    md = { 'id'              => group_id,
           'word_position'   => word_position,
           'section'         => section,
           'references'      => references.map { |r| r.ref_id }.presence
         }.compact
    md['context'] = {
      'truncate_before' => truncate_before,
      'text_before'     => text_before,
      'citation'        => citation,
      'text_after'      => text_after,
      'truncate_after'  => truncate_after
    }.compact
    md
  end

  alias to_json metadata

  def assign_metadata(metadata)
    metadata = metadata.dup
    group_id = metadata.delete('id')
    context = (metadata.delete('context') || {}).dup
    reference_ids = metadata.delete('references')
    reference_ids && reference_ids.each do |ref_id|
      reference = citing_paper.reference_for_id(ref_id)
      raise "Reference #{ref_id.inspect} not found in citation group #{group_id.inspect}" unless reference
      self.references << reference
    end

    self.group_id        = group_id
    self.truncate_before = context.delete('truncate_before') || false
    self.text_before     = sanitize_html( context.delete('text_before') )
    self.citation        = sanitize_html( context.delete('citation') )
    self.text_after      = sanitize_html( context.delete('text_after') )
    self.truncate_after  = context.delete('truncate_after') || false
    self.word_position   = metadata.delete('word_position')
    self.section         = metadata.delete('section')
  end

end
