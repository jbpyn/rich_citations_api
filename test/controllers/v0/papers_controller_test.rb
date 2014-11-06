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

    test "It should not authenticate the user" do
      @controller.expects(:authentication_required!).never
      get :show, id:'123'
    end

    test "It should GET a paper" do
      get :show, uri: papers(:paper_a).uri

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, papers(:paper_a).to_json
    end

    test "It should GET a paper with */* accept" do
      @request.headers['Accept'] = '*/*'
      get :show, uri: papers(:paper_a).uri

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, papers(:paper_a).to_json
    end

    test "It should GET a paper via DOI" do
      doi = '10.1234/1'

      get :show, doi: doi

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, papers(:paper_a).to_json
    end

    test "It should GET a paper including cited metadata" do
      get :show, uri: papers(:paper_a).uri, include: 'cited'

      assert_response :success
      assert_equal    @response.content_type, Mime::JSON
      assert_equal    @response.json, papers(:paper_a).to_json
    end
    
    test 'it should pretty print JSON when asked' do
      get :show, uri: papers(:paper_a).uri, pretty: 't'

      assert_response :success
      assert_equal Mime::JSON, @response.content_type
      assert_equal MultiJson.dump(papers(:paper_a).to_json, pretty: true),
                   @response.body
    end

    test 'It should GET random papers' do
      get :show, random: 10, include: 'cited'
      assert_response :success
      assert_equal Mime::JSON, @response.content_type
      assert_equal([papers(:paper_a).to_json], @response.json)
    end

    test 'It should return only uris when requested' do
      get :show, doi: '10.1234/1', fields: 'uri'
      assert_equal Mime::JSON, @response.content_type
      assert_response :success
      assert_equal({ 'uri' => 'http://dx.doi.org/10.1234%2F1' }, @response.json)
    end

    test 'It should return only uris when requested with fields[paper]' do
      get :show, doi: '10.1234/1', fields: { paper: 'uri' }
      assert_equal Mime::JSON, @response.content_type
      assert_response :success
      assert_equal({ 'uri' => 'http://dx.doi.org/10.1234%2F1' }, @response.json)
    end

    test 'It should return random docs with uris only when requested' do
      get :show, random: 10, fields: 'uri'
      assert_equal Mime::JSON, @response.content_type
      assert_response :success
      assert_equal([{ 'uri' => 'http://dx.doi.org/10.1234%2F1' }], @response.json)
    end

    test 'It should return all docs with uris when requested' do
      get :show, all: 't', fields: 'uri'
      assert_equal Mime::JSON, @response.content_type
      assert_response :success
      assert_equal([{ 'uri' => 'http://dx.doi.org/10.1234%2F1' }], @response.json)
    end

    test 'It should return all citing & cited docs with uris when requested' do
      get :show, all: 't', fields: 'uri', nonciting: 't'
      assert_equal Mime::JSON, @response.content_type
      assert_response :success
      assert_equal([{ 'uri' => 'http://dx.doi.org/10.1234%2F1' },
                    { 'uri' => 'http://dx.doi.org/10.1234%2F2' },
                    { 'uri' => 'http://dx.doi.org/10.1234%2F3' },
                    { 'uri' => 'http://dx.doi.org/10.1234%2F4' },
                    { 'uri' => 'http://dx.doi.org/10.1234%2F5' },
                    { 'uri' => 'http://dx.doi.org/10.1234%2F6' }], @response.json)
    end

    test 'It should output CSV if requested' do
      csv_resp = <<'EOS'
"citing_paper_uri","mention_id","citation_group_id","citation_group_word_position","citation_group_section","reference_number","reference_id","reference_mention_count","reference_uri","reference_uri_source","reference_type","reference_title","reference_journal","reference_issn","reference_author_count","reference_author1","reference_author2","reference_author3","reference_author4","reference_author5","reference_author_string","reference_original_text"
"http://dx.doi.org/10.1234%2F1","ref-1-1","a_1","11","Introduction","1","ref-1","1","uri://foo","","","","","","0","","","","","","",""
"http://dx.doi.org/10.1234%2F1","ref-2-1","a_1","11","Introduction","2","ref-2","2","uri://bar","","","","","","0","","","","","","",""
EOS
      get :show, uri: papers(:paper_a).uri, format: 'csv'
      # is there a better way to ensure that a streaming response has finished?
      sleep(1)
      assert_response :success
      assert_equal 'text/csv', @response.content_type
      assert_equal csv_resp, @response.body
    end

    test 'it should dump random CSV' do
      csv_resp = <<-'EOS'
"citing_paper_uri","mention_id","citation_group_id","citation_group_word_position","citation_group_section","reference_number","reference_id","reference_mention_count","reference_uri","reference_uri_source","reference_type","reference_title","reference_journal","reference_issn","reference_author_count","reference_author1","reference_author2","reference_author3","reference_author4","reference_author5","reference_author_string","reference_original_text"
"http://dx.doi.org/10.1234%2F1","ref-1-1","a_1","11","Introduction","1","ref-1","1","uri://foo","","","","","","0","","","","","","",""
"http://dx.doi.org/10.1234%2F1","ref-2-1","a_1","11","Introduction","2","ref-2","2","uri://bar","","","","","","0","","","","","","",""
EOS
      get :show, random: 10, format: 'csv'
      # is there a better way to ensure that a streaming response has finished?
      sleep(1)
      assert_response :success
      assert_equal Mime::CSV, @response.content_type
      assert_equal csv_resp, @response.body
    end
    
    test 'It should output CSV Citegraph fields if requested' do
      get :show, format: 'csv', fields: 'citegraph', all: 't'
      assert_response :success
      # is there a better way to ensure that a streaming response has finished?
      sleep(1)
      assert_equal 'text/csv', @response.content_type
      assert_equal "\"citing_paper_uri\",\"reference_uri\",\"mention_count\"
\"http://dx.doi.org/10.1234%2F1\",\"http://dx.doi.org/10.1234%2F2\",\"1\"
\"http://dx.doi.org/10.1234%2F1\",\"http://dx.doi.org/10.1234%2F3\",\"2\"
", @response.body.to_s
    end

    test 'It should output CSV with only a URI field if requested' do
      get :show, format: 'csv', fields: 'uri', all: 't'
      assert_response :success
      # is there a better way to ensure that a streaming response has finished?
      sleep(1)
      assert_equal 'text/csv', @response.content_type
      assert_equal "\"citing_paper_uri\"
\"http://dx.doi.org/10.1234%2F1\"
", @response.body.to_s
    end

    test 'It should output CSV for nonciting paper with only a URI field if requested' do
      get :show, format: 'csv', fields: 'uri', all: 't', nonciting: 't'
      assert_response :success
      # is there a better way to ensure that a streaming response has finished?
      sleep(1)
      assert_equal 'text/csv', @response.content_type
      assert_equal "\"citing_paper_uri\"
\"http://dx.doi.org/10.1234%2F1\"
\"http://dx.doi.org/10.1234%2F2\"
\"http://dx.doi.org/10.1234%2F3\"
\"http://dx.doi.org/10.1234%2F4\"
\"http://dx.doi.org/10.1234%2F5\"
\"http://dx.doi.org/10.1234%2F6\"
", @response.body.to_s
    end

    test 'It should output JSONP if requested' do
      get :show, uri: papers(:paper_a).uri, format: 'js'

      assert_response :success
      assert_equal 'text/javascript', @response.content_type
      assert_equal 'jsonpCallback({"uri":"http://dx.doi.org/10.1234%2F1","bibliographic":{},"references":[{"number":1,"uri":"uri://foo","id":"ref-1","citation_groups":["a_1"],"bibliographic":{}},{"number":2,"uri":"uri://bar","id":"ref-2","citation_groups":["a_1"],"bibliographic":{}}],"citation_groups":[{"id":"a_1","word_position":11,"section":"Introduction","context":{"truncated_before":false,"text_before":"foo","citation":"baz","text_after":"bar","truncated_after":false},"references":["ref-1","ref-2"]}]});',
                   @response.body
    end

    test 'It should accept a callback name for JSONP' do
      get :show, uri: papers(:paper_a).uri, callback:'myCallbackName', format: 'js'

      assert_response :success
      assert_equal 'text/javascript', @response.content_type
      assert_equal 'myCallbackName({"uri":"http://dx.doi.org/10.1234%2F1","bibliographic":{},"references":[{"number":1,"uri":"uri://foo","id":"ref-1","citation_groups":["a_1"],"bibliographic":{}},{"number":2,"uri":"uri://bar","id":"ref-2","citation_groups":["a_1"],"bibliographic":{}}],"citation_groups":[{"id":"a_1","word_position":11,"section":"Introduction","context":{"truncated_before":false,"text_before":"foo","citation":"baz","text_after":"bar","truncated_after":false},"references":["ref-1","ref-2"]}]});',
                   @response.body
    end

    test "It should render a 400 if you don't provide the uri or doi param to a GET request" do
      id = URI.encode_www_form_component(papers(:paper_a).uri)
      get :show

      assert_response :bad_request
    end

    test "It should render a 404 if you GET a paper that doesn't exist" do
      get :show, uri: 'http://example.org/NOSUCHPAPER'

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
    end

    test "It should create an audit log entry" do
      user = User.create(full_name:'A User')
      @controller.stubs authenticated_user:user

      post :create, metadata(paper_uri).to_json

      paper = Paper.find_by(uri: paper_uri)
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

      paper = Paper.find_by(uri: paper_uri)
      assert_equal user.audit_log_entries.count,  0
      assert_equal AuditLogEntry.count, 0
    end

    test "It should create the paper's records" do
      post :create, metadata(paper_uri).to_json
      paper = Paper.find_by(uri: paper_uri)
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
