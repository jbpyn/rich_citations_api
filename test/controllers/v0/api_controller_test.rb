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

class ::V0::ApiControllerTest < ActionController::TestCase

  def setup
    @controller = V0::ApiController.new
  end

  def metadata(paper_uri)
    { 'uri'           => paper_uri,
      'bibliographic' => { 'title' => 'Title' },
      'more_stuff'    => 'Was here!',
      'references'    => [
          { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title' => 'Title'}, 'number' => 1 },
      ]
    }
  end

  class ::V0::ApiControlerGetTest < ::V0::ApiControllerTest
    paper_uri = 'http://example.com/a'

    def setup
      super
      @request.headers['Accept'] = Mime::JSON
      @request.headers['Content-Type'] = Mime::JSON
    end

    def create_paper(paper_uri)
      p = Paper.new
      p.assign_metadata( metadata(paper_uri) )
      p.save!
    end

    test "It should not authenticate the user" do
      @controller.expects(:authentication_required!).never
      get :show, id:'123'
    end

    test "It should GET a paper" do
      create_paper(paper_uri)

      id = URI.encode_www_form_component(paper_uri)
      get :show, id:id

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json,
                     { 'uri'           => paper_uri,
                       'bibliographic' => { 'title' => 'Title' },
                       'more_stuff'    => 'Was here!',
                       'references'    => [
                           { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'number' => 1 },
                       ]
                     }
    end

    test "It should GET a paper including cited metadata" do
      create_paper(paper_uri)

      id = URI.encode_www_form_component(paper_uri)
      get :show, id:id, include:'cited'

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json,
          { 'uri'           => paper_uri,
            'bibliographic' => { 'title' => 'Title' },
            'more_stuff'    => 'Was here!',
            'references'    => [
                { 'id' => 'ref.1', 'uri' => 'http://example.com/c1', 'bibliographic' => {'title' => 'Title'}, 'number' => 1 },
            ]
          }
    end

    test "It should render a 404 if you GET a paper that doesn't exist" do
      id = URI.encode_www_form_component(paper_uri)
      get :show, id:id, include:'cited'

      assert_response :not_found
    end

  end

  class ::V0::ApiControlerPostTest < ::V0::ApiControllerTest

    paper_uri = 'http://example.com/a'

    def setup
      super
      @controller.stubs :authentication_required!
      @request.headers['Accept'] = Mime::JSON
      @request.headers['Content-Type'] = Mime::JSON
    end

    test "It should require authentication" do
      @controller.expects :authentication_required!
      post :create, metadata(paper_uri).to_json
    end

    test "It should POST a new paper" do
      post :create, metadata(paper_uri).to_json
      assert_response :created
    end

    test "It should round trip data via the Location header" do
      id = URI.encode_www_form_component(paper_uri)
      post :create, metadata(paper_uri).to_json
      assert_equal("http://test.host/papers?id=#{id}", response.headers['Location'])
      route = Rails.application.routes.recognize_path(response.headers['Location'])
      assert_equal('show', route[:action])
      assert_equal('v0/api', route[:controller])
      assert_equal(paper_uri, Rack::Utils.parse_nested_query(URI.parse(response.headers['Location']).query)['id'])
                   
      get :show, id: paper_uri
      assert_response :success
      assert_equal @response.content_type, Mime::JSON
    end

    test "It should create an audit log entry" do
      user = User.create(full_name:'A User')
      @controller.stubs authenticated_user:user

      post :create, metadata(paper_uri).to_json

      paper = Paper.for_uri(paper_uri)
      assert_equal paper.audit_log_entries.count, 1
      assert_equal user.audit_log_entries.count,  1
      assert_equal AuditLogEntry.count, 1
    end

    test "It should not create an audit log entry if the metadata is invalid" do
      user = User.create(full_name:'A User')
      @controller.stubs authenticated_user:user

      data = metadata(paper_uri)
      data.delete('uri')
      post :create, data.to_json

      paper = Paper.for_uri(paper_uri)
      assert_equal user.audit_log_entries.count,  0
      assert_equal AuditLogEntry.count, 0
    end

    test "It should create the paper's records" do
      post :create, metadata(paper_uri).to_json
      paper = Paper.for_uri(paper_uri)
      assert_not_nil paper
      assert_equal   paper.references.length, 1
      assert Paper.exists?(uri:'http://example.com/c1')
    end

    test "It should fail if the paper already exists" do
      post :create, metadata(paper_uri).to_json
      assert_response :created

      post :create, metadata(paper_uri).to_json
      assert_response :forbidden
    end

    test "It should fail for missing metadata" do
      data = metadata(paper_uri)
      data.delete('uri')
      post :create, data.to_json

      assert_response :unprocessable_entity
    end

  end

end
