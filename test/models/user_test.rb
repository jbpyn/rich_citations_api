require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should be valid" do
    u = User.new(full_name:'Fred Flintstone', email:'test@example.com')
    assert u.valid?
  end

  test "should have an api_key" do
    u = User.create!(full_name:'Fred Flintstone', email:'test@example.com')
    assert u.api_key.present?
  end

  test "should require either an email or a full_name" do
    u1 = User.new(full_name:'Fred Flintstone' )
    assert u1.valid?
    u2 = User.new(email:    'test@example.com')
    assert u2.valid?
    u3 = User.new( )
    assert ! u3.valid?
  end

  test "should validate the email" do
    u = User.new(email: 'bad_email')
    u.valid?
    assert u.errors.include?(:email)
  end

  test "should find a user by api_key" do
    u = User.create!(full_name:'Fred Flintstone' )
    assert_not_nil User.for_key( u.api_key)
  end

  test "should return nil if it cannot find a user" do
    assert_nil User.for_key('not_a_valid_api_key')
  end

  test "it should return a display value based on the name and email" do
    u = User.new(full_name:'Fred Flintstone')
    assert_equal u.display, 'id:: name:Fred Flintstone'

    u = User.new(email:'fred@flintstone.com')
    assert_equal u.display, 'id:: email:fred@flintstone.com'

    u = User.new(full_name:'Fred Flintstone', email:'fred@flintstone.com')
    assert_equal u.display, 'id:: name:Fred Flintstone, email:fred@flintstone.com'
  end

end
