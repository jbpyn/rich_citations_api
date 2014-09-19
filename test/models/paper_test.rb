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
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/c")
    a.references += [ new_reference( index:0, cited_paper:b, text: { 'blue' => 2 } ),
                      new_reference( index:1, cited_paper:c, text: { 'red' =>  1 } ) ]
    a.save
    assert_equal(a.references[0].cited_paper, b)
    assert_equal(a.references[0].citing_paper, a)
    assert_equal(a.references[0].text, { 'blue' =>  2 })
    assert_equal(a.references[1].cited_paper, c)
    assert_equal(a.references[1].citing_paper, a)
    assert_equal(a.references[1].text, { 'red' =>  1 })
  end

  test 'should have CITING papers' do
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/c")
    new_reference( index:0, citing_paper:a, cited_paper:c, text: { 'blue' => 2 }, save:true )
    new_reference( index:0, citing_paper:b, cited_paper:c, text: { 'red'  => 3 }, save:true )

    assert_equal(c.citing_papers, [a, b])
  end    

  test 'should have CITED papers' do
    a = Paper.new(uri: "http://example.org/a")
    b = Paper.new(uri: "http://example.org/b")
    c = Paper.new(uri: "http://example.org/c")
    a.references += [ new_reference( index:0, cited_paper:b, text: { 'blue' => 2 } ),
                      new_reference( index:1, cited_paper:c, text: { 'red'  =>  1 } ) ]
    a.save

    assert_equal(a.cited_papers(true), [b, c])
  end

  test 'should have a list of audit log entries' do
    u = User.new(full_name:'Smith, Just call me Smith')
    p = Paper.new(uri: "http://example.org/a")
    p.audit_log_entries << AuditLogEntry.new(user:u)
    p.save
    assert_equal(p.audit_log_entries[0].user, u)
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

  test 'Papers should be able to return their metadata' do
    p = Paper.new(uri: 'http://example.org/a',
                  bibliographic: {'title' => 'Citing 1'},
                  extended:      { 'groups' => [1,2] }              )

    p.references << new_reference(index:0, bibliographic: {'title' => 'cited 1'}, text:{ 'word_count' => 42} )
    p.references << new_reference(index:1, bibliographic: {'title' => 'cited 2'}, text:{ 'word_count' => 24} )

    assert_equal(p.metadata, {
                                 'uri'           => 'http://example.org/a',
                                 'groups'        => [1, 2],
                                 'bibliographic' => {'title' => 'Citing 1' },
                                 'references'    => {
                                                      'ref.0' => {"word_count"=>42, "uri"=>"http://example.org/0", "index"=>0, "ref"=>"ref.0"},
                                                      'ref.1' => {"word_count"=>24, "uri"=>"http://example.org/1", "index"=>1, "ref"=>"ref.1"},
                                                    }
                             } )
  end

  test 'Papers should be able to return their metadata including cited paper metadata' do
    p = Paper.new(uri: 'http://example.org/a',
                  bibliographic: {'title' => 'Citing 1'},
                  extended:      { 'groups' => [1,2] }              )

    p.references << new_reference(index:0, bibliographic: {'title' => 'cited 1'}, text:{ 'word_count' => 42} )
    p.references << new_reference(index:1, bibliographic: {'title' => 'cited 2'}, text:{ 'word_count' => 24} )

    assert_equal(p.metadata(true), {
                                 'uri'           => 'http://example.org/a',
                                 'groups'        => [1, 2],
                                 'bibliographic' => {'title' => 'Citing 1' },
                                 'references'    => {
                                                       'ref.0' => {"word_count"=>42, "uri"=>"http://example.org/0", "index"=>0, "ref"=>'ref.0',
                                                                   "bibliographic"=>{"title"=>"cited 1"} },
                                                       'ref.1' => {"word_count"=>24, "uri"=>"http://example.org/1", "index"=>1, "ref"=>'ref.1',
                                                                   "bibliographic"=>{"title"=>"cited 2"} }
                                                    }
                             } )
  end

end
