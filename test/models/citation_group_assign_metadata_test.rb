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

class CitationGroupAssignMetadataTest < ActiveSupport::TestCase

  test "it should assign the basic metadata" do
    g = CitationGroup.new
    g.assign_metadata('id'              => 'group-1',
                      'context' => {
                        'truncated_before' => true,
                        'text_before'      => 'text before',
                        'citation'         => 't e x t',
                        'text_after'       => 'text after',
                        'truncated_after'  => true
                      },
                      'word_position'   => 42,
                      'section'         => 'Introduction')

    assert_equal g.group_id,         'group-1'
    assert_equal g.truncated_before, true
    assert_equal g.text_before,      'text before'
    assert_equal g.citation,         't e x t'
    assert_equal g.text_after,       'text after'
    assert_equal g.truncated_after,  true
    assert_equal g.word_position,    42
    assert_equal g.section,          'Introduction'
  end

  test "it should sanitize html for the basic metadata" do
    g = CitationGroup.new
    g.assign_metadata('id'              => 'group-1',
                      'context' => {
                        'text_before'     => '<span>text before</span>',
                        'citation'        => '<span>t e x t</span>',
                        'text_after'      => '<span>text after</span>'})

    assert_equal g.text_before,     'text before'
    assert_equal g.citation,        't e x t'
    assert_equal g.text_after,      'text after'
  end

  test 'it should work with missing truncate' do
    r1 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_e), ref_id:'ref-1', number: 1, uri:'uri://1')
    r2 = Reference.new(citing_paper: papers(:paper_d), cited_paper: papers(:paper_f), ref_id:'ref-2', number: 2, uri:'uri://2')
    g = CitationGroup.new(citing_paper: papers(:paper_a), references: [r1, r2])
    g.assign_metadata('id'              => 'group-1',
                      'context' => {
                        'text_before'      => 'text before',
                        'citation'         => 't e x t',
                        'text_after'       => 'text after',
                        'truncated_after'  => false
                      })
    g.save!
    g.reload
    assert_equal(false, g.truncated_before)
    assert_equal(false, g.truncated_after)
  end
  
  test "it should assign references" do
    p = papers(:paper_a)
    g = CitationGroup.new(citing_paper:p)
    g.assign_metadata('references'      => ['ref-2', 'ref-1'])

    assert_equal g.references.size, 2
    assert_equal g.references[0], references(:ref_2)
    assert_equal g.references[1], references(:ref_1)
  end

  test "it should round-trip the metadata" do
    p = papers(:paper_a)
    g = CitationGroup.new(citing_paper:p)

    metadata = { 'id'              => 'group-1',
                 'references'      => ['ref-2', 'ref-1'],
                 'context' => {
                   'truncated_before' => false,
                   'text_before'      => 'text before',
                   'citation'         => 't e x t',
                   'text_after'       => 'text after',
                   'truncated_after'  => true
                 },
                 'word_position'   => 42,
                 'section'         => 'Introduction' }

    g.assign_metadata(metadata)
    assert_equal metadata, g.metadata
  end

  test "it should raise an exception if a reference does not exist" do
    p = papers(:paper_a)
    g = CitationGroup.new(citing_paper:p)

    assert_raises(RuntimeError) {
      g.assign_metadata('references'      => ['ref-doesnt-exist'] )
    }
  end

end
