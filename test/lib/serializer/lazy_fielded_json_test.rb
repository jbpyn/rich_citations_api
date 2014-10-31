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

class LazyFieldedJsonTest < ActiveSupport::TestCase
  test 'build a hash' do
    t = Serializer::LazyFieldedJson.new([:foo])
    t.add(:foo) { 'bar' }
    assert_equal({ foo: 'bar' }.with_indifferent_access, t.build)
  end

  test 'will not call arg for unused fields' do
    foo_called = false
    bar_called = false
    t = Serializer::LazyFieldedJson.new([:foo])
    t.add(:foo) do
      foo_called = true
      'foo'
    end
    t.add(:bar) { bar_called = true }
    assert_equal({ foo: 'foo' }.with_indifferent_access, t.build)
    assert foo_called
    assert_not bar_called
  end
end
