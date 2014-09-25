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

class ApiTestController < ::ApiController
  before_action :authentication_required!, :only => [ :with_authentication ]
  def with_authentication
    render status: 299, text:'OK'
  end
  def no_authentication
    render status: 299, text:'OK'
  end
  public :authenticated_user
end

class ApiControllerTest < ActionController::TestCase

  def setup
    @controller = ApiTestController.new
  end

  def with_mock_routes
    with_routing do |set|
      set.draw do
        get '/test/no_authentication',   controller:'api_test', action:'no_authentication'
        get '/test/with_authentication', controller:'api_test', action:'with_authentication'
      end

      yield
    end
  end

  test "should not require authentication by default" do
    with_mock_routes do
      get :no_authentication
      assert_response 299
    end
  end

  test "should require authentication when needed" do
    with_mock_routes do
      get :with_authentication
      assert_response :unauthorized
    end
  end

  test "should return an appropriate error message on authentication failure" do
    with_mock_routes do
      get :with_authentication, 'api_key' => nil
      assert_response :unauthorized
      assert_equal @response.body, 'Api-Key not provided'

      get :with_authentication, 'api_key' => 'abcd-1234'
      assert_response :unauthorized
      assert_equal @response.body, 'Not Authorized'
    end
  end

  test "should accept an Api Key in the Authorization header" do
    with_mock_routes do
      u = User.create!(full_name:'A User')
      @request.headers['Authorization'] = 'api-key ' + u.api_key
      get :with_authentication
      assert_response 299
      assert @controller.authenticated_user == u
    end
  end

  test "should accept an Api Key in the api_key parameter" do
    with_mock_routes do
      u = User.create!(full_name:'A User')
      get :with_authentication, 'api_key' => u.api_key
      assert_response 299
      assert @controller.authenticated_user == u
    end
  end

  test "should accept an Api Key in the api-key parameter" do
    with_mock_routes do
      u = User.create!(full_name:'A User')
      get :with_authentication, 'api-key' => u.api_key
      assert_response 299
      assert @controller.authenticated_user == u
    end
  end

end
