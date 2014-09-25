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

class JsonAttributesTest < ActiveSupport::TestCase

  test "it should know it's attributes" do
    paper = Paper.new
    assert(paper.json_attribute_fields, [:bibliographic, :extra ])
    assert(Paper.json_attribute_fields, [:bibliographic, :extra ])
  end

  test "it should read the attribute as JSON" do
    p = Paper.new
    p.write_attribute('bibliographic','{ "a":1 }')
    assert_equal p.bibliographic, { 'a' => 1 }
  end

  test "it should write the attribute as JSON" do
    p = Paper.new
    p.bibliographic = { 'a' => 1 }
    assert_equal p.read_attribute('bibliographic'),'{ "a":1}'
  end

  test "it should round-trip JSON" do
    p = Paper.new('http://example.com/a')
    p.bibliographic = { 'a' => 1 }
    assert_equal p.bibliographic, { 'a' => 1 }
    p.save!
    assert_equal p.bibliographic, { 'a' => 1 }

    q = Paper.find(p.id)
    assert_equal q.bibliographic, { 'a' => 1 }
  end

  test "it should the attribute to nil" do
    p = Paper.new('http://example.com/a')
    p.bibliographic = { 'a' => 1 }
    assert_equal p.bibliographic, { 'a' => 1 }
    p.save!

    p.bibliographic = nil
    assert_nil p.bibliographic
    p.save!

    q = Paper.find(p.id)
    assert_nil q.bibliographic
  end

  test "it should reload JSON" do
    p = Paper.new(uri:'http://example.com/a')
    p.bibliographic = { 'a' => 1 }
    p.save!

    q = Paper.find(p.id)
    q.bibliographic = { 'a' => 2, 'b' => 3 }
    q.save!
\
    assert_equal p.bibliographic, { 'a' => 1 }

    p.reload
    assert_equal p.bibliographic, { 'a' => 2, 'b' => 3 }
  end

end
