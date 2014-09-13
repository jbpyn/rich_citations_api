require 'test_helper'

class PaperTest < ActiveSupport::TestCase
  test 'should not save Paper without URI' do
    paper = Paper.new
    assert_not paper.save
  end

  test 'should not save Paper a bad URI' do
    paper = Paper.new(uri: "x")
    assert_not paper.save
  end

  test 'should have a list of citations' do
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/b")
    a.citations += [Citation.new(cited_paper: b, text: { 'blue' => 2 } ), Citation.new(cited_paper: c, text: { 'red' =>  1 })]
    a.save
    assert_equal(a.citations[0].cited_paper, b)
    assert_equal(a.citations[0].citing_paper, a)
    assert_equal(a.citations[0].text, { 'blue' =>  2 })
    assert_equal(a.citations[1].cited_paper, c)
    assert_equal(a.citations[1].citing_paper, a)
    assert_equal(a.citations[1].text, { 'red' =>  1 })
  end

  test 'should have CITING papers' do
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/b")
    a.citing_papers += [b, c]
    a.save
    assert_equal(a.citing_papers, [b, c])
  end    

  test 'should have CITED papers' do
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/b")
    a.cited_papers += [b, c]
    a.save
    assert_equal(a.cited_papers, [b, c])
  end

  test 'should round trip bibliographic json' do
    a = Paper.create(uri: "http://example.org/a", bibliographic: { 'red' => [1,2] } )
    assert_equal(a.bibliographic, { 'red' => [1,2] })

    a.reload
    assert_equal(a.bibliographic, { 'red' => [1,2] } )

    b = Paper.find(a.id)
    assert_equal(b.bibliographic, { 'red' => [1,2] } )
  end

  test 'can set bibliographic to nil' do
    a = Paper.create(uri: "http://example.org/a", bibliographic: nil )
    assert_nil(a.bibliographic)

    b = Paper.find(a.id)
    assert_nil(b.bibliographic)
  end

  test 'should round trip extended json' do
    a = Paper.create(uri: "http://example.org/a", extended: { 'red' => [1,2] } )
    assert_equal(a.extended, { 'red' => [1,2] })

    a.reload
    assert_equal(a.extended, { 'red' => [1,2] } )

    b = Paper.find(a.id)
    assert_equal(b.extended, { 'red' => [1,2] } )
  end

  test 'can set extended to nil' do
    a = Paper.create(uri: "http://example.org/a", extended: nil )
    assert_nil(a.extended)

    b = Paper.find(a.id)
    assert_nil(b.extended)
  end
  
end
