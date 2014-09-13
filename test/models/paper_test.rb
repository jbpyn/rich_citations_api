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
    a.citations += [Citation.new(cited_paper: b, text: 'foo'), Citation.new(cited_paper: c, text: 'bar')]
    a.save
    assert_equal(a.citations[0].cited_paper, b)
    assert_equal(a.citations[0].citing_paper, a)
    assert_equal(a.citations[0].text, 'foo')
    assert_equal(a.citations[1].cited_paper, c)
    assert_equal(a.citations[1].citing_paper, a)
    assert_equal(a.citations[1].text, 'bar')
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
end
