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

  test 'should have ' do
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/b")
    a.citations += [Citation.new(cited_paper: b), Citation.new(cited_paper: c)]
    a.save
    assert_equal(a.citations[0].cited_paper, b)
    assert_equal(a.citations[1].cited_paper, c)
  end
end
