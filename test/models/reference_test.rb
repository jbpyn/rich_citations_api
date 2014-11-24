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
    reference = Reference.new(citing_paper: a, cited_paper: b, ref_id:'ref-1', number:3)
    assert reference.save
  end

  test 'References numbers are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    assert     Reference.new(citing_paper: a, cited_paper: b, number:1, ref_id:'ref.1').save
    assert_raise ActiveRecord::RecordNotUnique do
      Reference.new(citing_paper: a, cited_paper: c, number:1, ref_id:'ref.2').save
    end
  end

  test 'References Refs are unique for a paper combination' do
    a = Paper.new(uri: 'http://example.org/a')
    b = Paper.new(uri: 'http://example.org/b')
    c = Paper.new(uri: 'http://example.org/c')
    r =     Reference.new(citing_paper: a, cited_paper: b, number:1, ref_id:'ref.1')
    r.save
    assert r.save
    assert_raise ActiveRecord::RecordNotUnique do
      Reference.new(citing_paper: a, cited_paper: c, number:3, ref_id:'ref.1').save
    end
  end

  test 'References should be able to return their metadata including cited metadata' do
    p  = Paper.new(uri: 'http://example.org/a')
    c1 = new_reference(number: 3, bibliographic: { 'title' => 'cited 1' },
                       citing_paper: p, uri: 'http://example.org/3')

    assert_equal({ 'uri'           => 'http://example.org/3',
                   'id'            => 'ref.3',
                   'number'        => 3,
                   'bibliographic' => { 'title' => 'cited 1' }
                 }, c1.to_json)
  end
end
