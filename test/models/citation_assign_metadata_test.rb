require 'test_helper'

class CitationAssignMetadataTest < ActiveSupport::TestCase

  test "it should link to to an existing paper without assigning metadata" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Citation.new
    c.assign_metadata('ref.x',
                      'ref'      => 'ref.x',
                      'index'    => 2,
                      'uri'      => 'http://example.org/a',
                      'mentions' => 2                   )

    assert_equal c.uri,   'http://example.org/a'
    assert_equal c.ref,   'ref.x'
    assert_equal c.index, 2
    assert_equal c.text,  { 'mentions' => 2 }

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Original Title'})
  end

  test "it should update an existing papers metadata if it is provided" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Citation.new
    c.assign_metadata('ref.x',
                      'ref'           => 'ref.x',
                      'index'         => 2,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Updated Title'},
                      'mentions'      => 2                               )

    assert_equal c.uri,   'http://example.org/a'
    assert_equal c.ref,   'ref.x'
    assert_equal c.index, 2
    assert_equal c.text,  { 'mentions' => 2 }

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Updated Title'})
  end

  test "it should create a cited paper if necessary" do
    p = Paper.for_uri('http://example.org/a')
    assert_nil(p)

    c = Citation.new
    c.assign_metadata('ref.x',
                      'ref'           => 'ref.x',
                      'index'         => 2,
                      'uri'           => 'http://example.org/a',
                      'bibliographic' => {'title' => 'Title'},
                      'mentions'      => 2                               )

    assert_equal c.uri,   'http://example.org/a'
    assert_equal c.ref,   'ref.x'
    assert_equal c.index, 2
    assert_equal c.text,  { 'mentions' => 2 }

    p = Paper.for_uri('http://example.org/a')
    assert_equal c.cited_paper, p
    assert_equal(p.bibliographic, {'title' => 'Title'})
  end

  test "it should raise an exception if the cited paper does not exist and no bibliographic data is provided" do
    p = Paper.for_uri('http://example.org/a')
    assert_nil(p)

    c = Citation.new
    assert_raises(RuntimeError) {
      c.assign_metadata('ref.x',
                        'ref'           => 'ref.x',
                        'index'         => 2,
                        'uri'           => 'http://example.org/a',
                        'mentions'      => 2                               )
    }
  end

  test "it should raise an exception if the provided ref and metadata ref do not match" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Citation.new
    assert_raise(RuntimeError) {
      c.assign_metadata('ref.x',
                        'ref'      => 'ref.y',
                        'index'    => 2,
                        'uri'      => 'http://example.org/a',
                        'mentions' => 2                   )
    }

  end

end
