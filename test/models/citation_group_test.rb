require 'test_helper'

class CitationGroupTest < ActiveSupport::TestCase
  test 'can create a citation group' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')

    r1 = Reference.new(text: 'foo', citing_paper: a, cited_paper: b, ref:'ref-1', index: 1, uri:'uri://1')
    r2 = Reference.new(text: 'bar', citing_paper: a, cited_paper: c, ref:'ref-1', index: 2, uri:'uri://2')

    g = CitationGroup.new(citing_paper: a,
                          section: 'Foo',
                          text: '[1,2]',
                          ellipses_before: true,
                          ellipses_after: false,
                          text_before: 'bar',
                          text_before: 'baz',
                          references: [r1, r2])
    assert(g.save)
    assert_equal(g.references, [r1, r2])
    assert_equal(g.references[0].cited_paper, b)
  end
end
