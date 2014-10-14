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

module Test
class Paper < ::Base
  public :sanitize_html, :normalize_uri
end
end

class BaseTest < ActiveSupport::TestCase

  def setup
    @model = Test::Paper.new
  end

  test 'should remove unwanted html tags' do
    assert_equal 'Text', @model.sanitize_html('<span>Text</span>')
    assert_equal 'Text', @model.sanitize_html('<form>Text</form>')
    assert_equal 'Text', @model.sanitize_html('<script>Text</script>')
    assert_equal nil,    @model.sanitize_html('<img src="foo"></img>')
  end

  test 'should accept listed tags' do
    assert_equal '<b>Text</b>',           @model.sanitize_html('<b>Text</b>')
    assert_equal '<strong>Text</strong>', @model.sanitize_html('<strong>Text</strong>')
    assert_equal '<q>Text</q>',           @model.sanitize_html('<q>Text</q>')
  end

  test 'should remove unknown html tags' do
    assert_equal 'Text', @model.sanitize_html('<fred>Text</fred>')
  end

  test 'should remove invalid attributes' do
    assert_equal '<b>Text</b>',           @model.sanitize_html('<b foo="bar">Text</b>')
  end

  test 'should add nofollow to link tags' do
    assert_equal '<a src="bar" rel="nofollow">Text</a>',           @model.sanitize_html('<a src="bar">Text</a>')
  end

  test 'should strip js link' do
    assert_equal '<a rel="nofollow">Text</a>',           @model.sanitize_html('<a src="javascript:foo">Text</a>')
  end

  test 'it should normalize URIs properly' do
    assert_equal 'http://example.org/~hello', @model.normalize_uri('http://EXAMPLE.org/%7ehello')
    assert_equal 'http://example.org/', @model.normalize_uri('http://example.org//'), 'remove useless trailing slash'
    assert_equal 'http://example.org/path/', @model.normalize_uri('http://example.org/path/'), 'do not remove trailing slash'
    assert_equal 'http://example.org/q', @model.normalize_uri('http://example.org/q?'), 'remove empty query'
    assert_equal 'http://example.org/q#a', @model.normalize_uri('http://example.org/q#a'), 'do remove fragment'
    assert_equal 'urn:isbn:3-900051-07-0', @model.normalize_uri('urn:isbn:3-900051-07-0'), 'works with URNs'
  end
end
