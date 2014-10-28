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

require 'test_helper'

class CitationGroupTest < ActiveSupport::TestCase
  test 'can create a citation group' do
    r1 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_e), ref_id:'ref-1', number: 1, uri:'uri://1')
    r2 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_f), ref_id:'ref-2', number: 2, uri:'uri://2')

    g = CitationGroup.new(citing_paper: papers(:paper_d),
                          group_id:'g1',
                          section: 'Foo',
                          citation: '[1,2]',
                          truncated_before: true,
                          truncated_after: false,
                          text_before: 'bar',
                          text_before: 'baz',
                          references: [r1, r2])
    assert(g.save)
    assert_equal([r1, r2], g.references)
    assert_equal(g.references[0].cited_paper, papers(:paper_e))
  end

  test 'ordering is added for references' do
    r1 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_e), ref_id:'ref-1', number: 1, uri:'uri://1')
    r2 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_f), ref_id:'ref-2', number: 2, uri:'uri://2')
    g  = CitationGroup.new(citing_paper: papers(:paper_d), group_id:'g1',
                           references: [r1, r2])
    assert(g.save)
    assert_equal(1, g.citation_group_references[0].position)
    assert_equal(2, g.citation_group_references[1].position)
  end

  test 'references are ordered by ordering' do
    g = CitationGroup.new(citing_paper:papers(:paper_d), group_id:'g1')
    g.citation_group_references << CitationGroupReference.new(reference: references(:ref_1), position: 2)
    g.citation_group_references << CitationGroupReference.new(reference: references(:ref_2), position: 1)
    assert(g.save)
    assert_equal([references(:ref_2), references(:ref_1)], g.references)
  end

  test 'citation_group destroys citation_group_references, but not references ' do
    r1 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_e), ref_id:'ref-1', number: 1, uri:'uri://1')
    g = CitationGroup.new(citing_paper: papers(:paper_d), group_id:'g1',
                          references: [r1])
    g.save!
    cgr = g.citation_group_references[0]
    assert(g.destroy)
    assert(cgr.destroyed?)
    assert_not(r1.destroyed?)
  end
end
