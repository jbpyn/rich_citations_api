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

class ReferenceAssignMetadataTest < ActiveSupport::TestCase

  test "it should link to to an existing paper without assigning metadata" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new
    c.assign_metadata('id'       => 'ref.x',
                      'number'   => 2,
                      'literal'  => 'Literal Text',
                      'uri'      => 'http://example.org/a',
                      'mentions' => 2                   )

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number,  2
    assert_equal c.literal, 'Literal Text'
    assert_equal c.extra,   { 'mentions' => 2 }

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Original Title'})
  end

  test "it should update an existing papers metadata if it is provided" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new(citing_paper:citing)
    c.assign_metadata('id'            => 'ref.x',
                      'number'        => 2,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Updated Title'},
                      'mentions'      => 3                               )
    c.save!

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number,  2
    assert_equal c.extra,   { 'mentions' => 3 }

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Updated Title'})
  end

  test "it should not update an existing paper if there is an error" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new(citing_paper:citing)
    c.assign_metadata('id'            => 'ref.x',
                      'number'        => nil,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Updated Title'},
                      'mentions'      => 3                               )
    assert !c.save

    p.reload
    assert_equal(p.bibliographic, {'title' => 'Original Title'})
  end

  test "it should create a cited paper if necessary" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.for_uri('http://example.org/a')
    assert_nil(p)

    c = Reference.new(citing_paper:citing)
    c.assign_metadata('id'            => 'ref.x',
                      'number'        => 2,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Title'},
                      'mentions'      => 2                               )
    c.save!

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number, 2
    assert_equal c.extra,   { 'mentions' => 2 }

    p = Paper.for_uri('http://example.org/a')
    assert_equal c.cited_paper, p
    assert_equal(p.bibliographic, {'title' => 'Title'})
  end

  test "it should give a cited paper a uri if none is available" do
    citing = Paper.create!(uri:'http://example.org/citing')

    c = Reference.new(citing_paper:citing)
    c.assign_metadata('id'            => 'ref.x',
                      'number'        => 2,
                      # 'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Title'},
                      'mentions'      => 2                               )
    c.save!

    assert_equal c.is_random_uri?, true
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number, 2
    assert_equal c.extra,   { 'mentions' => 2 }

    p = Paper.for_uri(c.uri)
    assert_equal c.cited_paper, p
    assert_equal(p.bibliographic, {'title' => 'Title'})
  end

  test "it should not create a reference or the cited paper if there are errors" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.for_uri('http://example.org/a')
    assert_nil(p)

    c = Reference.new(citing_paper:citing)
    c.assign_metadata('id'            => 'ref.x',
                      'number'        => 2,
                      'uri'           => 'bad_uri',
                      'bibliographic' => {'title' => 'Title'},
                      'mentions'      => 2                               )

    assert_equal c.save, false

    p = Paper.for_uri('http://example.org/a')
    assert_nil(p)
  end

  test "it should round-trip the metadata" do
    p1 = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    metadata = { 'id'              => 'ref.x',
                 'number'          => 2,
                 'literal'         => 'Literal Text',
                 'uri'             => 'http://example.org/a',
                 'bibliographic'   => {'title' => 'Updated Title'},
                 'citation_groups' => ['group-2', 'group-1' ],
                 'mentions'        => 2                              }

    r = Reference.new
    r.assign_metadata(metadata)
    r.citation_groups << [ CitationGroup.new(group_id:'group-2'), CitationGroup.new(group_id:'group-1') ]

    assert_equal(r.metadata(true), metadata)
  end

  test "it should raise an exception if the cited paper does not exist and no bibliographic data is provided" do
    p = Paper.for_uri('http://example.org/a')
    assert_nil(p)

    c = Reference.new
    assert_raises(RuntimeError) {
      c.assign_metadata('id'            => 'ref.x',
                        'number'        => 2,
                        'uri'           => 'http://example.org/a',
                        'mentions'      => 2                               )
    }
  end

end
