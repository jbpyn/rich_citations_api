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
                          'ref.1' => { 'ref' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {} },
                          'ref.2' => { 'ref' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {} },
                      } )

    assert_equal p.references.length, 2
    assert_equal p.references[0].ref, 'ref.1'
    assert_equal p.references[0].uri, 'http://example.com/c1'
    assert_equal p.references[1].ref, 'ref.2'
    assert_equal p.references[1].uri, 'http://example.com/c2'
  end

  test "it should rount trip metadata" do
    metadata = { 'uri'           => 'http://example.com/a',
                 'bibliographic' => { 'title' => 'Title' },
                 'more_stuff'    => 'Was here!',
                 'references'    => {
                    'ref.1' => { 'ref' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {}, 'index' => 1 },
                    'ref.2' => { 'ref' => 'ref.2', 'uri' => 'http://example.com/c2', 'bibliographic' => {}, 'index' => 2 },
                 }
               }

    p = Paper.new
    p.assign_metadata(metadata)

    assert_equal(p.metadata(true), metadata)
  end

end
