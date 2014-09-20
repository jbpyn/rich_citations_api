require 'test_helper'

class ReferenceAssignMetadataTest < ActiveSupport::TestCase

  test "it should link to to an existing paper without assigning metadata" do
    p = Paper.create!(uri:'http://example.org/a', bibliographic:{'title' => 'Original Title'} )

    c = Reference.new
    c.assign_metadata('id'       => 'ref.x',
                      'number'   => 2,
                      'uri'      => 'http://example.org/a',
                      'mentions' => 2                   )

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number,  2
    assert_equal c.text,   { 'mentions' => 2 }

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
                      'mentions'      => 2                               )
    c.save!

    assert_equal c.uri,    'http://example.org/a'
    assert_equal c.ref_id, 'ref.x'
    assert_equal c.number,  2
    assert_equal c.text,   { 'mentions' => 2 }

    assert_equal c.cited_paper, p
    p.reload
    assert_equal(p.bibliographic, {'title' => 'Updated Title'})
  end

  test "it should not update an existing paper if there is an error" do
    skip "Write this test when there are some validations that would cause saving to fail"
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
    assert_equal c.text,   { 'mentions' => 2 }

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
    assert_equal c.text,   { 'mentions' => 2 }

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

    metadata = { 'id'             => 'ref.x',
                 'number'         => 2,
                 'uri'           => 'http://example.org/a',
                 'bibliographic' => {'title' => 'Updated Title'},
                 'mentions'      => 2                              }

    c = Reference.new
    c.assign_metadata(metadata)

    assert_equal(c.metadata(true), metadata)
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
