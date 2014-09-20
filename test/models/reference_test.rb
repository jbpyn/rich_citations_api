require 'test_helper'

class ReferenceTest < ActiveSupport::TestCase

  test 'can create a Reference' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    reference = Reference.new(text: 'xyz', citing_paper: a, cited_paper: b, ref_id:'ref-1', number:3, uri:'uri://1')
    assert reference.save
  end

  test 'References are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')

    assert     new_reference(number:0, text: 'foo', citing_paper: a, cited_paper: b).save
    assert     new_reference(number:1, text: 'bar', citing_paper: a, cited_paper: c).save
    assert_not new_reference(number:2, text: 'baz', citing_paper: a, cited_paper: b).save
  end

  test 'References numbers are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    assert     Reference.new(text: 'foo', citing_paper: a, cited_paper: b, number:1, uri:'uri://1', ref_id:'ref.1').save
    assert_not Reference.new(text: 'baz', citing_paper: a, cited_paper: c, number:1, uri:'uri://3', ref_id:'ref.2').save
  end

  test 'References URIs are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    assert     Reference.new(text: 'foo', citing_paper: a, cited_paper: b, number:1, uri:'uri://1', ref_id:'ref.1').save
    assert_not Reference.new(text: 'baz', citing_paper: a, cited_paper: c, number:3, uri:'uri://1', ref_id:'ref.3').save
  end

  test 'References Refs are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    r =     Reference.new(text: 'foo', citing_paper: a, cited_paper: b, number:1, uri:'uri://1', ref_id:'ref.1')
    r.save
    puts r.errors.full_messages
    assert r.save
    assert_not Reference.new(text: 'baz', citing_paper: a, cited_paper: c, number:3, uri:'uri://2', ref_id:'ref.1').save
  end

  test 'should not save Reference without URI' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')

    c = Reference.new(text: 'baz', citing_paper: a, cited_paper: b, number:3, ref_id:'ref.1')
    assert_not c.valid?
  end

  test 'should not save Reference a bad URI' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')

    c = Reference.new(text: 'baz', citing_paper: a, cited_paper: b, number:3, ref_id:'ref.1', uri:'x')
    assert_not c.valid?
  end

  test 'should round trip text json' do
    p = Paper.new(uri: 'http://example.org/a')

    a = new_reference(number:0, citing_paper:p, text: { 'red' => [1,2] }, save:true )
    assert_equal(a.text, { 'red' => [1,2] })

    a.reload
    assert_equal(a.text, { 'red' => [1,2] } )

    b = Reference.find(a.id)
    assert_equal(b.text, { 'red' => [1,2] } )
  end

  test 'can set text to nil' do
    p = Paper.new(uri: 'http://example.org/a')

    a = new_reference(number:0, citing_paper:p, text: nil, save:true)
    assert_nil(a.text)

    b = Reference.find(a.id)
    assert_nil(b.text)
  end

  test 'References should be able to return their metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_reference(number:3, bibliographic: {'title' => 'cited 1'}, citing_paper: p, text:{ 'word_count' => 42})

    assert_equal(c1.metadata, {
                                  'uri'        => 'http://example.org/3',
                                  'id'         => 'ref.3',
                                  'number'     => 3,
                                  'word_count' => 42
                              } )
  end

  test 'References should be able to return their metadata including cited metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_reference(number:3, bibliographic: {'title' => 'cited 1'}, citing_paper: p, text:{ 'word_count' => 42})

    assert_equal(c1.metadata(true), {
                                       'uri'           => 'http://example.org/3',
                                       'id'            => 'ref.3',
                                       'number'        => 3,
                                       'word_count'    => 42,
                                       'bibliographic' => {'title' => 'cited 1'}
                                   } )
  end

end
