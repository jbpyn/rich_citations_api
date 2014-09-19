require 'test_helper'

class ApiControllerTest < ActionController::TestCase

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

  class ApiControlerGetTest < ApiControllerTest

    paper_uri = 'http://example.com/a'

    def create_paper(paper_uri)
      p = Paper.new
      p.assign_metadata( metadata(paper_uri) )
      p.save!
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

    test "It should reneder a 404 if you GET a paper that doesn't exist" do
      id = URI.encode_www_form_component(paper_uri)
      get :show, id:id, include:'cited'

      assert_response :not_found
    end

  end

  class ApiControlerPostTest < ApiControllerTest

    paper_uri = 'http://example.com/a'

    test "It should POST a new paper" do
      post :create, api:metadata(paper_uri)
      assert_response :created
    end

    test "It should create the paper's records" do
      post :create, api:metadata(paper_uri)

      paper = Paper.for_uri(paper_uri)
      assert_not_nil paper
      assert_equal   paper.references.length, 1
      assert Paper.exists?(uri:'http://example.com/c1')
    end

    test "It should fail if the paper already exists" do
      post :create, api:metadata(paper_uri)
      assert_response :created

      post :create, api:metadata(paper_uri)
      assert_response :forbidden
    end

    test "It should fail for missing metadata" do
      data = metadata(paper_uri)
      data.delete('uri')
      post :create, api:data

      assert_response :unprocessable_entity
    end

  end

end
