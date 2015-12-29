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
    c.set_from_json('id'       => 'ref.x',
                      'number'   => 2,
                      'original_citation'  => 'Literal Text',
                      'uri'      => 'http://example.org/a')

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number,  2
    assert_equal c.original_citation, 'Literal Text'

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Original Title'})
  end

  test "it should clean unsafe attributes from reference metadata" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new
    c.set_from_json('id'       => 'ref.x',
                      'number'   => 2,
                      'uri'      => 'http://example.org/a',
                      'original_citation'  => '<span>Literal</span>'   )

    assert_equal c.original_citation, 'Literal'
  end

  test "it should clean unsafe attributes from bibliographic metadata" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new
    c.set_from_json('id'       => 'ref.x',
                      'number'   => 2,
                      'uri'      => 'http://example.org/a',
                      'bibliographic' => {
                          'title'           => '<span>Title</span>',
                          'container-title' => '<span>Publication</span>',
                          'abstract'        => '<span>Abstract</span>',
                          'subtitle'        => ['<span>Subtitle 1</span>', '<span>Subtitle 2</span>']
                      }                  )

    assert_equal c.bibliographic, { 'title' => 'Title', 'container-title' => 'Publication', 'abstract' => 'Abstract',
                                    'subtitle' => ['Subtitle 1', 'Subtitle 2'] }
  end

  test "it should normalize URIs" do
    c = Reference.new
    c.set_from_json('id'       => 'ref.x',
                      'number'   => 2,
                      'uri'      => 'http://EXAMPLE.COM/%7ehello',
                      'bibliographic' => {})

    assert_equal 'http://example.com/~hello', c.uri
  end

  test "it should update an existing papers metadata if it is provided" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new(citing_paper:citing)
    c.set_from_json('id'            => 'ref.x',
                      'number'        => 2,
                      'uri'           => 'http://example.org/a',
                      'uri_source'    => 'foo',
                      'bib_source'    => 'bar',
                      'score'         => 2.5,
                      'word_count'    => 99,
                      'bibliographic' => {'title' => 'Updated Title'})
    c.save!

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number,  2
    assert_equal 99, c.cited_paper.word_count
    assert_equal 'foo', c.cited_paper.uri_source
    assert_equal 'bar', c.cited_paper.bib_source
    assert_equal 2.5, c.score

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Updated Title'})
  end

  test "it should not update an existing paper if there is an error" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new(citing_paper:citing)
    c.set_from_json('id'            => 'ref.x',
                      'number'        => nil,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Updated Title'})
    assert !c.save

    p.reload
    assert_equal(p.bibliographic, {'title' => 'Original Title'})
  end

  test "it should create a cited paper if necessary" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.find_by(uri: 'http://example.org/a')
    assert_nil(p)

    c = Reference.new(citing_paper:citing)
    c.set_from_json('id'            => 'ref.x',
                      'number'        => 2,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Title'})
    c.save!

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number, 2

    p = Paper.find_by(uri: 'http://example.org/a')
    assert_equal c.cited_paper, p
    assert_equal(p.bibliographic, {'title' => 'Title'})
  end

  test "it should give a cited paper a uri if none is available" do
    citing = Paper.create!(uri:'http://example.org/citing')

    c = Reference.new(citing_paper:citing)
    c.set_from_json('id'            => 'ref.x',
                      'number'        => 2,
                      # 'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Title'})
    c.save!

    assert_equal c.is_random_uri?, true
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number, 2

    p = Paper.find_by(uri: c.uri)
    assert_equal c.cited_paper, p
    assert_equal(p.bibliographic, {'title' => 'Title'})
  end

  test "it should not create a reference or the cited paper if there are errors" do
    citing = Paper.create!(uri:'http://example.org/citing')

    p = Paper.find_by(uri: 'http://example.org/a')
    assert_nil(p)

    c = Reference.new(citing_paper:citing)
    c.set_from_json('id'            => 'ref.x',
                      'number'        => 2,
                      'uri'           => 'bad_uri',
                      'bibliographic' => {'title' => 'Title'})

    assert_equal c.save, false

    p = Paper.find_by(uri: 'http://example.org/a')
    assert_nil(p)
  end

  test "it should round-trip the metadata" do
    p1 = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    metadata = { 'id'                => 'ref.x',
                 'number'            => 2,
                 'original_citation' => 'Literal Text',
                 'uri'               => 'http://example.org/a',
                 'uri_source'        => 'foo',
                 'bib_source'        => 'bar',
                 'score'             => 2.5,
                 'word_count'        => 99,
                 'bibliographic'     => {'title' => 'Updated Title'},
                 'citation_groups'   => ['group-1', 'group-2' ],
                 'self_citations'    => ['Doe, John']}

    r = Reference.new
    r.set_from_json(metadata)
    r.citation_groups << [ CitationGroup.new(group_id:'group-2'), CitationGroup.new(group_id:'group-1') ]

    assert_equal(r.to_json, metadata)
  end

  test "it should raise an exception if the cited paper does not exist and no bibliographic data is provided" do
    p = Paper.find_by(uri: 'http://example.org/a')
    assert_nil(p)

    c = Reference.new
    assert_raises(RuntimeError) {
      c.set_from_json('id'            => 'ref.x',
                        'number'        => 2,
                        'uri'           => 'http://example.org/a')
    }
  end
end
