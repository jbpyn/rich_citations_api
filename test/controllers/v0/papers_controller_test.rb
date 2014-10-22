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

class ::V0::PapersControllerTest < ActionController::TestCase

  def setup
    @controller = V0::PapersController.new
  end

  def metadata(uri)
    { 'uri'           => uri,
      'bibliographic' => { 'title' => 'Title' },
      'references'    => [
        { 'id' => 'ref.1',
          'uri' => 'http://example.com/c1',
          'bibliographic' => {'title' => 'Title'},
          'number' => 1,
          'accessed_at' => '2012-04-23T18:25:43.511Z'
        }
      ]
    }
  end

  def metadata_with_group(uri)
    { 'uri'           => uri,
      'bibliographic' => { 'title' => 'Title' },
      'references'    => [
        { 'id' => 'ref.1',
          'uri' => 'http://example.com/c1',
          'bibliographic' => {'title' => 'Title'},
          'number' => 1,
          'accessed_at' => '2012-04-23T18:25:43.511Z'
        }
      ],
      'citation_groups' => [
        { 'id' => 'group-1',
          'context' => {
            'text_before' => 'Lorem ipsum',
            'truncated_before' => false,
            'citation' => '[1]',
            'text_after' =>'dolor',
            'truncated_after' => true
          },
          'section' => 'First',
          'references' => ['ref.1']
        }
      ]
    }
  end

  class ::V0::PapersControlerGetTest < ::V0::PapersControllerTest
    paper_uri = 'http://example.com/a'

    def setup
      super
      @request.headers['Accept'] = Mime::JSON
      @request.headers['Content-Type'] = Mime::JSON
    end

    def create_paper(uri)
      p = Paper.new
      p.assign_metadata( metadata(uri) )
      p.save!
    end

    test "It should not authenticate the user" do
      @controller.expects(:authentication_required!).never
      get :show, id:'123'
    end

    test "It should GET a paper" do
      create_paper(paper_uri)

      get :show, uri: paper_uri

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, metadata(paper_uri)
    end

    test "It should GET a paper with */* accept" do
      @request.headers['Accept'] = '*/*'
      create_paper(paper_uri)

      get :show, uri: paper_uri

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, metadata(paper_uri)
    end

    test "It should GET a paper via DOI" do
      doi = '10.1/123'
      doi_uri = "http://dx.doi.org/#{URI.encode_www_form_component(doi)}"
      create_paper(doi_uri)

      get :show, doi: doi

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, metadata(doi_uri)
    end

    test "It should GET a paper including cited metadata" do
      create_paper(paper_uri)

      get :show, uri: paper_uri, include: 'cited'

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, metadata(paper_uri)
    end

    test 'It should output CSV if requested' do
      p = Paper.new
      p.assign_metadata(metadata_with_group(paper_uri))
      p.save!

      get :show, uri: paper_uri, format: 'csv'

      assert_response :success
      assert_equal    'text/csv', @response.content_type
      assert_equal    "citing_paper_uri,citation_id,reference_id,reference_number,original_reference,citation_group_id,cited_paper_uri,cited_paper_uri_source,word_position,section,type,title,journal,author_count,author1,author2,author3,author4,author5,author_string
http://example.com/a,ref.1_1,ref.1,1,,group-1,http://example.com/c1,,,First,,Title,,0,,,,,,\"\"
", @response.body
    end

    test "It should render a 400 if you don't provide the uri or doi param to a GET request" do
      id = URI.encode_www_form_component(paper_uri)
      get :show

      assert_response :bad_request
    end

    test "It should render a 404 if you GET a paper that doesn't exist" do
      uri = URI.encode_www_form_component(paper_uri)
      get :show, uri:uri

      assert_response :not_found
    end

  end

  class ::V0::PapersControlerPostTest < ::V0::PapersControllerTest

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

    test "It should reject invalid JSON" do
      post :create, ({'foo' => 'bar'}).to_json
      assert_response(:unprocessable_entity)
    end
    
    test "It should round trip data via the Location header" do
      uri = URI.encode_www_form_component(paper_uri)
      post :create, metadata(paper_uri).to_json
      assert_equal("http://test.host/papers?uri=#{uri}", response.headers['Location'])
      route = Rails.application.routes.recognize_path(response.headers['Location'])
      assert_equal('show', route[:action])
      assert_equal('v0/papers', route[:controller])
      assert_equal(paper_uri, Rack::Utils.parse_nested_query(URI.parse(response.headers['Location']).query)['uri'])
                   
      get :show, uri: paper_uri
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

    test "It should fail for missing reference metadata" do
      data = metadata(paper_uri)
      data['references'].first.delete('id')
      post :create, data.to_json

      assert_response :unprocessable_entity
    end

    test "It should fail for extra metadata" do
      data = metadata(paper_uri)
      data['foo'] = 'bar'
      post :create, data.to_json

      assert_response :unprocessable_entity
    end

    test "It should fail for extra reference metadata" do
      data = metadata(paper_uri)
      data['references'].first['foo'] = 'bar'
      post :create, data.to_json

      assert_response :unprocessable_entity
    end

  end

end
