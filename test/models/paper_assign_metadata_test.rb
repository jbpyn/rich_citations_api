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

class PaperAssignMetadataTest < ActiveSupport::TestCase
  DUMMY_CONTEXT = {
    'text_before' => 'Lorem ipsum',
    'truncated_before' => false,
    'citation' => '[1]',
    'text_after' =>'dolor',
    'truncated_after' => true
  }

  test "it should assign metadata to a paper" do
    p = Paper.new
    uri = mk_random_uri
    p.assign_metadata('uri'           => uri,
                      'uri_source'    => 'foo',
                      'bib_source'    => 'bar',
                      'word_count'    => 101,
                      'bibliographic' => { 'title' => 'Title' })

    assert_equal uri, p.uri
    assert_equal p.bibliographic, { 'title' => 'Title' }
    assert_equal p.uri_source, 'foo'
    assert_equal p.bib_source, 'bar'
    assert_equal 101, p.word_count
  end

  test "it should clean html attributes" do
    p = Paper.new
    p.assign_metadata(
        'uri'           => mk_random_uri,
        'bibliographic' => {
            'title'           => '<span>Title</span>',
            'container-title' => '<span>Publication</span>',
            'abstract'        => '<span>Abstract</span>',
            'subtitle'        => ['<span>Subtitle 1</span>', '<span>Subtitle 2</span>']
        },
    )

    assert_equal p.bibliographic, { 'title' => 'Title', 'container-title' => 'Publication', 'abstract' => 'Abstract',
                                    'subtitle' => ['Subtitle 1', 'Subtitle 2'] }
  end

  test "it should normalize URIs" do
    p = Paper.new
    p.assign_metadata(
      'uri'           => 'http://EXAMPLE.COM/%7ehello',
      'bibliographic' => {},
    )

    assert_equal 'http://example.com/~hello', p.uri
  end

  test "it should create References" do
    p = Paper.new
    p.assign_metadata('uri' => 'http://example.com/a',
                      'bibliographic' => {},
                      'references' => [
                          { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title'=>'1'}, 'number' => 1 },
                          { 'id' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {'title'=>'1'}, 'number' => 2 },
                      ] )

    assert_equal p.references.size, 2
    assert_equal p.references[0].ref_id, 'ref.1'
    assert_equal p.references[0].uri,   'http://example.com/c1'
    assert_equal p.references[1].ref_id, 'ref.2'
    assert_equal p.references[1].uri,   'http://example.com/c2'
  end

  test "it should not create anything if it there is an error in a Reference" do
    p = Paper.new
    p.assign_metadata('references' => [
                { 'id' => 'ref.1', 'uri' => 'bad_uri', 'bibliographic' => {'title'=>'1'} },
            ] )

    assert_equal p.save, false
  end

  test "it should not update a cited paper if there is an error in a Reference" do
    cited = papers(:paper_a)
    paper = Paper.new
    paper.assign_metadata('references' => [
                { 'id' => 'ref.1', 'uri' => cited.uri, 'bibliographic' => {'title'=>'1'} },
            ] )


    cited.reload
    assert_equal cited.bibliographic, {}
  end

  test 'it should work with references that have an accessed_at field' do
    p = Paper.new
    p.assign_metadata('uri' => mk_random_uri,
                      'bibliographic' => {},
                      'references' => [
                        { 'id' => 'ref.1',
                          'uri' => 'http://example.com/c1',
                          'bibliographic' => {'title'=>'1'},
                          'accessed_at' => '2012-04-23T18:25:43.511Z',
                          'number' => 1
                        }
                      ])

    assert_equal p.references[0].accessed_at, DateTime.parse('2012-04-23T18:25:43.511Z')
  end
  
  test "it should create Citation Groups" do
    p = Paper.new
    p.update_metadata({
            'uri' => mk_random_uri,
            'bibliographic' => {},
            'references' => [
                { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title'=>'1'} , 'number' => 1},
                { 'id' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {'title'=>'1'} , 'number' => 2}
            ],
            'citation_groups' => [
                { 'id' => 'group-1', 'context' => DUMMY_CONTEXT, 'section' => 'First',  'references' => ['ref.1','ref.2'] },
                { 'id' => 'group-2', 'context' => DUMMY_CONTEXT, 'section' => 'Second', 'references' => ['ref.2'] }
            ]}, nil)

    assert_equal p.citation_groups.size, 2
    assert_equal p.citation_groups[0].group_id, 'group-1'
    assert_equal p.citation_groups[1].group_id, 'group-2'
    assert_equal p.citation_groups[0].truncated_before, DUMMY_CONTEXT['truncated_before']
    assert_equal p.citation_groups[0].truncated_after, DUMMY_CONTEXT['truncated_after']
    assert_equal p.citation_groups[0].text_before, DUMMY_CONTEXT['text_before']
    assert_equal p.citation_groups[0].text_after, DUMMY_CONTEXT['text_after']
    assert_equal p.citation_groups[0].citation, DUMMY_CONTEXT['citation']
    assert_equal p.references[0], p.citation_groups[0].references[0]
    assert_equal p.references[1], p.citation_groups[0].references[1]
    assert_equal p.references[1], p.citation_groups[1].references[0]
    assert_equal 1, p.references[0].mention_count
    assert_equal 2, p.references[1].mention_count
  end

  test "it should not create anything if it there is an error in a Citation Group" do
    p = Paper.new
    p.assign_metadata(
            'references' => [
                { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title'=>'1'} },
                { 'id' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {'title'=>'1'} },
            ],
            'citation_groups' => [
                { 'original_citation' => '[1],[2]', 'section' => 'First',  'references' => ['ref.1','ref.2'] },
            ])

    assert_equal p.save, false
  end

  test "it should not update a cited paper if there is an error in a Citation Group" do
    cited = papers(:paper_a)
    paper = Paper.new
    paper.assign_metadata(
            'references' => [
                { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title'=>'1'} },
            ],
            'citation_groups' => [
                { 'original_citation' => '[1]', 'section' => 'First',  'references' => ['ref.1'] },
            ])

    assert_equal paper.save, false

    cited.reload
    assert_equal cited.bibliographic, {}
  end

  test "it should round trip metadata" do
    metadata = { 'uri'           => mk_random_uri,
                 'bibliographic' => { 'title' => 'Title' },
                 'references'    => [
                    { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'number' => 1,
                      'bibliographic'   => {'title'=>'1'},
                      'citation_groups' => ['group-1']               },
                    { 'id' => 'ref.2', 'uri' => 'http://example.com/c2', 'number' => 2,
                      'bibliographic'   => {'title'=>'2'},
                      'citation_groups' => ['group-1', 'group-2']               }
                 ],
                 'word_count' => 201,
                 'citation_groups' => [
                    { 'id' => 'group-1', 'context' => DUMMY_CONTEXT, 'section' => 'First',  'references' => ['ref.1','ref.2'] },
                    { 'id' => 'group-2', 'context' => DUMMY_CONTEXT, 'section' => 'Second', 'references' => ['ref.2'] },
                 ]
               }

    p = Paper.new
    p.assign_metadata(metadata)
    p.save!
    p.reload

    assert_equal(p.to_json, metadata)
  end

  test "it should update metadata" do
    p = Paper.new
    saved = p.update_metadata( {
            'uri'           => 'http://example.com/a',
            'bibliographic' => { 'title' => 'Title' },
                               }, nil )
    assert saved
  end

  test "it should not update invalid metadata" do
    old_paper_count = Paper.count
    p = Paper.new
    saved = p.update_metadata( {
                                   # 'uri'           => 'http://example.com/a',
                                   'bibliographic' => { 'title' => 'Title' }
                               }, nil )
    assert !saved
    assert_equal old_paper_count, Paper.count
  end

  test "it should create an audit entry when updating metadata" do
    u = User.create!(full_name:'Will Smith')
    p = Paper.new
    p.update_metadata( {
                                   'uri'           => 'http://example.com/a',
                                   'bibliographic' => { 'title' => 'Title' }
                               }, u )
    assert_equal p.audit_log_entries.count, 1
    assert_equal u.audit_log_entries.count, 1
    assert_equal AuditLogEntry.count, 1
  end

  test "it should not create an audit entry when updating with invalid metadata" do
    u = User.create!(full_name:'Will Smith')
    p = Paper.new
    p.update_metadata( {
                           # 'uri'           => 'http://example.com/a',
                           'bibliographic' => { 'title' => 'Title' }
                       }, u )
    assert_equal p.audit_log_entries.count, 0
    assert_equal u.audit_log_entries.count, 0
    assert_equal AuditLogEntry.count, 0
  end

  test 'can create 2 papers that reference the same paper with the same number' do
    shared = { 'uri_source'    => 'foo',
               'bib_source'    => 'bar',
               'word_count'    => 101,
               'bibliographic' => {},
               'references'    => [ { 'id' => 'ref.1',
                                      'uri' => 'http://example.com/c1',
                                      'number' => 1,
                                      'bibliographic' => {}
                                    } ],
               'citation_groups' => [
                 { 'id' => 'group-1', 'context' => DUMMY_CONTEXT, 'section' => 'First',  'references' => ['ref.1'] }
               ]
             }
    p1 = Paper.new
    p1.assign_metadata(shared.merge('uri' => 'http://example.com/a'))
    p1.save!
    p2 = Paper.new
    p2.assign_metadata(shared.merge('uri' => 'http://example.com/b'))
    p2.save!
  end
end
