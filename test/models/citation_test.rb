require 'test_helper'

class CitationTest < ActiveSupport::TestCase

  test 'can create Citation' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    citation = Citation.new(text: 'xyz', cited_paper: a, cited_paper: b)
    assert citation.save
  end

  test 'Citations are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    assert Citation.new(text: 'foo', cited_paper: a, cited_paper: b).save
    assert Citation.new(text: 'bar', cited_paper: b, cited_paper: a).save
    assert_not Citation.new(text: 'baz', cited_paper: a, cited_paper: b).save
    assert_not Citation.new(text: 'bay', cited_paper: b, cited_paper: a).save
  end

  test 'should round trip text json' do
    p = Paper.new(uri: 'http://example.org/a')

    a = Citation.create(cited_paper:p, text: { 'red' => [1,2] } )
    assert_equal(a.text, { 'red' => [1,2] })

    a.reload
    assert_equal(a.text, { 'red' => [1,2] } )

    b = Citation.find(a.id)
    assert_equal(b.text, { 'red' => [1,2] } )
  end

  test 'can set text to nil' do
    p = Paper.new(uri: 'http://example.org/a')

    a = Citation.create(cited_paper:p, text: nil )
    assert_nil(a.text)

    b = Citation.find(a.id)
    assert_nil(b.text)
  end

end
