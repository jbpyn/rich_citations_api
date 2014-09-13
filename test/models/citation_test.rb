require 'test_helper'

class CitationTest < ActiveSupport::TestCase

  test 'can create Citation' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    citation = Citation.new(text: 'xyz', citing_paper: a, cited_paper: b, ref:'ref-1', index:3, uri:'uri://1')
    assert citation.save
  end

  test 'Citations are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    assert     new_citation(index:0, text: 'foo', citing_paper: a, cited_paper: b).save
    assert     new_citation(index:1, text: 'bar', citing_paper: b, cited_paper: a).save
    assert_not new_citation(index:2, text: 'baz', citing_paper: a, cited_paper: b).save
    assert_not new_citation(index:3, text: 'bay', citing_paper: b, cited_paper: a).save
  end

  test 'should round trip text json' do
    p = Paper.new(uri: 'http://example.org/a')

    a = new_citation(index:0, cited_paper:p, text: { 'red' => [1,2] }, save:true )
    assert_equal(a.text, { 'red' => [1,2] })

    a.reload
    assert_equal(a.text, { 'red' => [1,2] } )

    b = Citation.find(a.id)
    assert_equal(b.text, { 'red' => [1,2] } )
  end

  test 'can set text to nil' do
    p = Paper.new(uri: 'http://example.org/a')

    a = new_citation(index:0, cited_paper:p, text: nil, save:true)
    assert_nil(a.text)

    b = Citation.find(a.id)
    assert_nil(b.text)
  end

  test 'Citations should be able to return their metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_citation(index:3, bibliographic: {'title' => 'cited 1'}, citing_paper: p, text:{ 'word_count' => 42})

    assert_equal(c1.metadata, {
                                  'uri'        => 'http://example.org/3',
                                  'ref'        => 'ref.3',
                                  'index'      => 3,
                                  'word_count' => 42
                              } )
  end

  test 'Citations should be able to return their metadata including cited metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_citation(index:3, bibliographic: {'title' => 'cited 1'}, citing_paper: p, text:{ 'word_count' => 42})

    assert_equal(c1.metadata(true), {
                                       'uri'           => 'http://example.org/3',
                                       'ref'           => 'ref.3',
                                       'index'         => 3,
                                       'word_count'    => 42,
                                       'bibliographic' => {'title' => 'cited 1'}
                                   } )
  end

end
