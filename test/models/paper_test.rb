require 'test_helper'

class PaperTest < ActiveSupport::TestCase
  test 'should not save Paper without URI' do
    paper = Paper.new
    assert_not paper.save
  end

  test 'should not save Paper a bad URI' do
    paper = Paper.new(uri: "x")
    assert_not paper.save
  end
end
