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

  test 'should have a list of audit log entries' do
    u = User.new(full_name:'Smith, Just call me Smith')
    p = Paper.new(uri: "http://example.org/a")
    u.audit_log_entries << AuditLogEntry.new(paper:p)
    u.save
    assert_equal(u.audit_log_entries[0].paper, p)
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
