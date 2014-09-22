require 'test_helper'

class CitationGroupTest < ActiveSupport::TestCase
  test 'can create a citation group' do
    r1 = Reference.new(extra: 'foo', citing_paper: papers(:d), cited_paper: papers(:e), ref_id:'ref-1', number: 1, uri:'uri://1')
    r2 = Reference.new(extra: 'bar', citing_paper: papers(:d), cited_paper: papers(:f), ref_id:'ref-1', number: 2, uri:'uri://2')

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
    r1 = Reference.new(extra: 'foo', citing_paper: papers(:d), cited_paper: papers(:e), ref_id:'ref-1', number: 1, uri:'uri://1')
    r2 = Reference.new(extra: 'bar', citing_paper: papers(:d), cited_paper: papers(:f), ref_id:'ref-1', number: 2, uri:'uri://2')
    g = CitationGroup.new(citing_paper: papers(:d),
                          references: [r1, r2])
    assert(g.save)
    assert_equal(1, g.citation_group_references[0].position)
    assert_equal(2, g.citation_group_references[1].position)
  end

  test 'references are ordered by ordering' do
    g = CitationGroup.new(citing_paper: papers(:d))
    g.citation_group_references << CitationGroupReference.new(reference: references(:ref_1), position: 2)
    g.citation_group_references << CitationGroupReference.new(reference: references(:ref_2), position: 1)
    assert(g.save)
    assert_equal([references(:ref_2), references(:ref_1)], g.references)
  end

  test 'citation_group destroys citation_group_references, but not references ' do
    r1 = Reference.new(extra: 'foo', citing_paper: papers(:d), cited_paper: papers(:e), ref_id:'ref-1', number: 1, uri:'uri://1')
    g = CitationGroup.new(citing_paper: papers(:d),
                          references: [r1])
    g.save
    cgr = g.citation_group_references[0]
    assert(g.destroy)
    assert(cgr.destroyed?)
    assert_not(r1.destroyed?)
  end
end
