require 'test_helper'

class CitationGroupAssignMetadataTest < ActiveSupport::TestCase

  test "it should assign the basic metadata" do
    g = CitationGroup.new
    g.assign_metadata('id'              => 'group-1',
                      'ellipses_before' => true,
                      'text_before'     => 'text before',
                      'text'            => 't e x t',
                      'text_after'      => 'text after',
                      'ellipses_after'  => true,
                      'word_position'   => 42,
                      'section'         => 'Introduction',
                      'extra_metadata'  => { 'count' => 2 }          )

    assert_equal g.group_id,        'group-1'
    assert_equal g.ellipses_before, true
    assert_equal g.text_before,     'text before'
    assert_equal g.text,            't e x t'
    assert_equal g.text_after,      'text after'
    assert_equal g.ellipses_after,  true
    assert_equal g.word_position,   42
    assert_equal g.section,         'Introduction'
    assert_equal g.extra,           'extra_metadata' => { 'count' => 2 }
  end

  test "it should assign references" do
    p = papers(:a)
    g = CitationGroup.new(citing_paper:p)
    g.assign_metadata('references'      => ['ref-2', 'ref-1'],
                      'extra_metadata'  => { 'count' => 2 }          )

    assert_equal g.references.size, 2
    assert_equal g.references[0], references(:ref_2)
    assert_equal g.references[1], references(:ref_1)

    assert_equal g.extra,           'extra_metadata' => { 'count' => 2 }
  end

  test "it should round-trip the metadata" do
    p = papers(:a)
    g = CitationGroup.new(citing_paper:p)

    metadata = { 'id'              => 'group-1',
                 'references'      => ['ref-2', 'ref-1'],
                 'ellipses_before' => false,
                 'text_before'     => 'text before',
                 'text'            => 't e x t',
                 'text_after'      => 'text after',
                 'ellipses_after'  => true,
                 'word_position'   => 42,
                 'section'         => 'Introduction',
                 'extra_metadata'  => { 'count' => 2 }          }

    g.assign_metadata(metadata)
    assert_equal g.metadata, metadata
  end

  test "it should raise an exception if a reference does not exist" do
    p = papers(:a)
    g = CitationGroup.new(citing_paper:p)

    assert_raises(RuntimeError) {
      g.assign_metadata('references'      => ['ref-doesnt-exist'] )
    }
  end

end
