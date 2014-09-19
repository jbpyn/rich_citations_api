require 'test_helper'

class PaperAssignMetadataTest < ActiveSupport::TestCase

  test "it should assign metadata to a paper" do
    p = Paper.new
    p.assign_metadata(
                      'uri'           => 'http://example.com/a',
                      'bibliographic' => { 'title' => 'Title' },
                      'more_stuff'    => 'Was here!'
                     )

    assert_equal p.uri,           'http://example.com/a'
    assert_equal p.bibliographic, { 'title' => 'Title' }
    assert_equal p.extended,      { 'more_stuff' => 'Was here!' }
  end

  test "it should create References" do
    p = Paper.new
    p.assign_metadata('references' => {
                          'ref.1' => { 'ref' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title'=>'1'} },
                          'ref.2' => { 'ref' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {'title'=>'1'} },
                      } )

    assert_equal p.references.length, 2
    assert_equal p.references[0].ref, 'ref.1'
    assert_equal p.references[0].uri, 'http://example.com/c1'
    assert_equal p.references[1].ref, 'ref.2'
    assert_equal p.references[1].uri, 'http://example.com/c2'
  end

  test "it should not create anything if it there is an error in a Reference" do
    assert_equal Paper.count, 0
    assert_equal Reference.count, 0

    p = Paper.new
    p.assign_metadata('references' => {
                'ref.1' => { 'ref' => 'ref.1', 'uri' => 'bad_uri', 'bibliographic' => {'title'=>'1'} },
            } )

    assert_equal p.save, false

    assert_equal Paper.count, 0
    assert_equal Reference.count, 0
  end

  test "it should not update a cited paper if there is an error in a Reference" do
    skip "Write this test when there are validations that can fail"
  end

  test "it should rount trip metadata" do
    metadata = { 'uri'           => 'http://example.com/a',
                 'bibliographic' => { 'title' => 'Title' },
                 'more_stuff'    => 'Was here!',
                 'references'    => {
                    'ref.1' => { 'ref' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title'=>'1'}, 'index' => 1 },
                    'ref.2' => { 'ref' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {'title'=>'2'}, 'index' => 2 },
                 }
               }

    p = Paper.new
    p.assign_metadata(metadata)

    assert_equal(p.metadata(true), metadata)
  end

  test "it should update metadata" do
    p = Paper.new
    saved = p.update_metadata( {
            'uri'           => 'http://example.com/a',
            'bibliographic' => { 'title' => 'Title' },
            'more_stuff'    => 'Was here!'
                               }, nil )
    assert saved
  end

  test "it should not update invalid metadata" do
    p = Paper.new
    saved = p.update_metadata( {
                                   # 'uri'           => 'http://example.com/a',
                                   'bibliographic' => { 'title' => 'Title' },
                                   'more_stuff'    => 'Was here!'
                               }, nil )
    assert !saved
    assert_equal Paper.count, 0
  end

  test "it should create an audit entry when updating metadata" do
    u = User.create!(full_name:'Will Smith')
    p = Paper.new
    p.update_metadata( {
                                   'uri'           => 'http://example.com/a',
                                   'bibliographic' => { 'title' => 'Title' },
                                   'more_stuff'    => 'Was here!'
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
                           'bibliographic' => { 'title' => 'Title' },
                           'more_stuff'    => 'Was here!'
                       }, u )
    assert_equal p.audit_log_entries.count, 0
    assert_equal u.audit_log_entries.count, 0
    assert_equal AuditLogEntry.count, 0
  end

end
