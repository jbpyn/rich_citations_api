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

class ReferenceTest < ActiveSupport::TestCase

  test 'can create a Reference' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    reference = Reference.new(extra: 'xyz', citing_paper: a, cited_paper: b, ref_id:'ref-1', number:3, uri:'uri://1')
    assert reference.save
  end

  test 'References are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')

    assert     new_reference(number:0, extra: 'foo', citing_paper: a, cited_paper: b).save
    assert     new_reference(number:1, extra: 'bar', citing_paper: a, cited_paper: c).save
    assert_not new_reference(number:2, extra: 'baz', citing_paper: a, cited_paper: b).save
  end

  test 'References numbers are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    assert     Reference.new(extra: 'foo', citing_paper: a, cited_paper: b, number:1, uri:'uri://1', ref_id:'ref.1').save
    assert_not Reference.new(extra: 'baz', citing_paper: a, cited_paper: c, number:1, uri:'uri://3', ref_id:'ref.2').save
  end

  test 'References URIs are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    assert     Reference.new(extra: 'foo', citing_paper: a, cited_paper: b, number:1, uri:'uri://1', ref_id:'ref.1').save
    assert_not Reference.new(extra: 'baz', citing_paper: a, cited_paper: c, number:3, uri:'uri://1', ref_id:'ref.3').save
  end

  test 'References Refs are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    r =     Reference.new(extra: 'foo', citing_paper: a, cited_paper: b, number:1, uri:'uri://1', ref_id:'ref.1')
    r.save
    assert r.save
    assert_not Reference.new(extra: 'baz', citing_paper: a, cited_paper: c, number:3, uri:'uri://2', ref_id:'ref.1').save
  end

  test 'should not save Reference without URI' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')

    c = Reference.new(extra: 'baz', citing_paper: a, cited_paper: b, number:3, ref_id:'ref.1')
    assert_not c.valid?
  end

  test 'should not save Reference a bad URI' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')

    c = Reference.new(extra: 'baz', citing_paper: a, cited_paper: b, number:3, ref_id:'ref.1', uri:'x')
    assert_not c.valid?
  end

  test 'should round trip extra json' do
    p = Paper.new(uri: 'http://example.org/a')

    a = new_reference(number:0, citing_paper:p, extra: { 'red' => [1,2] }, save:true )
    assert_equal(a.extra, { 'red' => [1,2] })

    a.reload
    assert_equal(a.extra, { 'red' => [1,2] } )

    b = Reference.find(a.id)
    assert_equal(b.extra, { 'red' => [1,2] } )
  end

  test 'can set extra to nil' do
    p = Paper.new(uri: 'http://example.org/a')

    a = new_reference(number:0, citing_paper:p, extra: nil, save:true)
    assert_nil(a.extra)

    b = Reference.find(a.id)
    assert_nil(b.extra)
  end

  test 'References should be able to return their metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_reference(number:3, bibliographic: {'title' => 'cited 1'}, citing_paper: p, extra:{ 'word_count' => 42})

    assert_equal(c1.metadata, {
                                  'uri'        => 'http://example.org/3',
                                  'id'         => 'ref.3',
                                  'number'     => 3,
                                  'word_count' => 42
                              } )
  end

  test 'References should be able to return their metadata including cited metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_reference(number:3, bibliographic: {'title' => 'cited 1'}, citing_paper: p, extra:{ 'word_count' => 42})

    assert_equal(c1.metadata(true), {
                                       'uri'           => 'http://example.org/3',
                                       'id'            => 'ref.3',
                                       'number'        => 3,
                                       'word_count'    => 42,
                                       'bibliographic' => {'title' => 'cited 1'}
                                   } )
  end

end
