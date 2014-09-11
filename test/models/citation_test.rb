require 'test_helper'

class CitationTest < ActiveSupport::TestCase
  test 'can create Citation' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    citation = Citation.new(text: 'xyz', cited_paper: a, cited_paper: b)
    assert citation.save
  end
end
