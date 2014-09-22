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
