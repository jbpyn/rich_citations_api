require 'test_helper'

class CitationGroupTest < ActiveSupport::TestCase
  test 'can create a citation group' do
    r1 = Reference.new(text: 'foo', citing_paper: papers(:d), cited_paper: papers(:e), ref:'ref-1', index: 1, uri:'uri://1')
    r2 = Reference.new(text: 'bar', citing_paper: papers(:d), cited_paper: papers(:f), ref:'ref-1', index: 2, uri:'uri://2')

    g = CitationGroup.new(citing_paper: papers(:d),
                          section: 'Foo',
                          text: '[1,2]',
                          ellipses_before: true,
                          ellipses_after: false,
                          text_before: 'bar',
                          text_before: 'baz',
                          references: [r1, r2])
    assert(g.save)
    assert_equal([r1, r2], g.references)
    assert_equal(g.references[0].cited_paper, papers(:e))
  end

  test 'ordering is added for references' do
    r1 = Reference.new(text: 'foo', citing_paper: papers(:d), cited_paper: papers(:e), ref:'ref-1', index: 1, uri:'uri://1')
    r2 = Reference.new(text: 'bar', citing_paper: papers(:d), cited_paper: papers(:f), ref:'ref-1', index: 2, uri:'uri://2')
    g = CitationGroup.new(citing_paper: papers(:d),
                          references: [r1, r2])
    assert(g.save)
    assert_equal(0, g.citation_group_references[0].ordering)
    assert_equal(1, g.citation_group_references[1].ordering)
  end

  test 'references are ordered by ordering' do
    g = CitationGroup.new(citing_paper: papers(:d))
    g.citation_group_references << CitationGroupReference.new(reference: references(:ref_1), ordering: 1)
    g.citation_group_references << CitationGroupReference.new(reference: references(:ref_2), ordering: 0)
    assert(g.save)
    assert_equal([references(:ref_2), references(:ref_1)], g.references)
  end
end
