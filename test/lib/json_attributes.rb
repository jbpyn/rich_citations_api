require 'test_helper'

class JsonAttributesTest < ActiveSupport::TestCase

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

  test "it should reload JSON" do
    p = Paper.new('http://example.com/a')
    p.bibliographic = { 'a' => 1 }
    p.save!

    q = Paper.find(p.id)
    q.bibliographic = { 'a' => 2, 'b' => 3 }
    q.save!

    p.reload
    assert_equal p.bibliographic, { 'a' => 2, 'b' => 3 }
  end

end
