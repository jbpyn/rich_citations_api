# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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

  test 'should have a list of References' do
    a = Paper.new(uri: mk_random_uri)
    b = Paper.new(uri: mk_random_uri)
    c = Paper.new(uri: "http://example.org/b")
    a.references += [new_reference(number: 0, cited_paper: b),
                     new_reference(number: 1, cited_paper: c)]
    a.save
    assert_equal(a.references[0].cited_paper, b)
    assert_equal(a.references[0].citing_paper, a)
    assert_equal(a.references[1].cited_paper, c)
    assert_equal(a.references[1].citing_paper, a)
  end

  test 'should have CITING papers' do
    a = Paper.new(uri: mk_random_uri)
    b = Paper.new(uri: mk_random_uri)
    c = Paper.new(uri: mk_random_uri)
    new_reference(number: 0, citing_paper: a, cited_paper: c, save: true)
    new_reference(number: 1, citing_paper: b, cited_paper: c, save: true)

    assert_equal(c.citing_papers, [a, b])
  end    

  test 'should have CITED papers' do
    a = Paper.new(uri: mk_random_uri)
    b = Paper.new(uri: mk_random_uri)
    c = Paper.new(uri: mk_random_uri)
    a.references += [new_reference(number: 0, cited_paper: b),
                     new_reference(number: 1, cited_paper: c)]
    a.save

    assert_equal(a.cited_papers(true), [b, c])
  end
  
  test 'should update references_count' do
    a = Paper.new(uri: mk_random_uri)
    b = Paper.new(uri: mk_random_uri)
    c = Paper.new(uri: mk_random_uri)
    a.references += [new_reference(number: 0, cited_paper: b),
                     new_reference(number: 1, cited_paper: c)]
    a.save
    a.reload
    assert_equal(a.references_count, 2)
  end

  
  test 'should have a list of audit log entries' do
    u = User.new(full_name:'Smith, Just call me Smith')
    p = Paper.new(uri: mk_random_uri)
    p.audit_log_entries << AuditLogEntry.new(user:u)
    p.save
    assert_equal(p.audit_log_entries[0].user, u)
  end

  test 'should round trip bibliographic json' do
    a = Paper.create(uri: mk_random_uri, bibliographic: { 'red' => [1,2] } )
    assert_equal(a.bibliographic, { 'red' => [1,2] })

    a.reload
    assert_equal(a.bibliographic, { 'red' => [1,2] } )

    b = Paper.find(a.id)
    assert_equal(b.bibliographic, { 'red' => [1,2] } )
  end

  test 'can set bibliographic to nil' do
    a = Paper.create(uri: mk_random_uri, bibliographic: nil )
    assert_nil(a.bibliographic)

    b = Paper.find(a.id)
    assert_nil(b.bibliographic)
  end

  test 'Papers should be able to return their metadata' do
    uri = mk_random_uri
    p = Paper.new(uri: uri,
                  word_count: 101,
                  bibliographic: {'title' => 'Citing 1'})

    p.references << new_reference(number:0, bibliographic: {'title' => 'cited 1'})
    p.references << new_reference(number:1, bibliographic: {'title' => 'cited 2'})

    assert_equal({ 'uri'           => uri,
                   'bibliographic' => {'title' => 'Citing 1' },
                   'word_count'    => 101,
                   'references'    => [
                     { 'uri' => 'http://example.org/0', 'number' => 0, 'id' => 'ref.0',
                       'bibliographic' => { 'title' => 'cited 1' } },
                     { 'uri' => 'http://example.org/1', 'number' => 1, 'id' => 'ref.1',
                       'bibliographic' => { 'title' => 'cited 2'} }
                   ]
                 }, p.to_json)
  end

  test 'Papers should be able to return their metadata including cited paper metadata' do
    p = Paper.new(uri: 'http://example.org/a',
                  bibliographic: {'title' => 'Citing 1'})

    p.references << new_reference(number:0, bibliographic: {'title' => 'cited 1'})
    p.references << new_reference(number:1, bibliographic: {'title' => 'cited 2'})

    assert_equal({ 'uri'           => 'http://example.org/a',
                   'bibliographic' => {'title' => 'Citing 1' },
                   'references'    => [
                     {"uri"=>"http://example.org/0", "number"=>0, "id"=>'ref.0',
                      "bibliographic"=>{"title"=>"cited 1"} },
                     {"uri"=>"http://example.org/1", "number"=>1, "id"=>'ref.1',
                      "bibliographic"=>{"title"=>"cited 2"} }
                   ]
                 }, p.to_json)
  end

  test 'Can add citation groups to a paper' do
    r1 = new_reference(number:0, bibliographic: {'title' => 'cited 1'})
    r2 = new_reference(number:1, bibliographic: {'title' => 'cited 2'})
    p = Paper.new(uri: 'http://example.org/a',
                  bibliographic: { 'title' => 'Citing 1' },
                  references: [r1, r2],
                  citation_groups: [CitationGroup.new(references: [r1], group_id:'g1'),
                                    CitationGroup.new(references: [r2], group_id:'g2' )])
    assert(p.save)
  end

  test 'Citation groups are ordered in a paper' do
    r1 = new_reference(number:0, bibliographic: {'title' => 'cited 1'})
    r2 = new_reference(number:1, bibliographic: {'title' => 'cited 2'})
    g1 = CitationGroup.new(references: [r2], group_id:'g1')
    g2 = CitationGroup.new(references: [r1], group_id:'g12' )
    p = Paper.new(uri: 'http://example.org/a',
                  bibliographic: { 'title' => 'Citing 1' },
                  references: [r1, r2],
                  citation_groups: [g2, g1])
    assert(p.save)
    assert_equal(1, p.citation_groups[0].position)
    assert_equal(2, p.citation_groups[1].position)
    assert_equal([g2, g1], p.citation_groups)
  end

  test 'The schema should be valid' do
    assert_equal [], JSON::Validator.fully_validate_schema(Paper::JSON_SCHEMA)
  end

end
