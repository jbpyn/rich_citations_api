require 'test_helper'

class JsonUploadTest < ActionDispatch::IntegrationTest
  SANITIZER = Rails::Html::PermitScrubber.new
  SANITIZER.tags = %w[a em i strong b u cite q mark abbr sub sup s wbr]

  def setup
    @uri = 'http://example.org/a'
    @metadata = { 'uri'           => @uri,
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

  def mk_post_path(uri)
    uri_enc = URI.encode_www_form_component(uri)
    "/papers?api_key=841c5d42-2ca3-42fc-8eda-87fbccc1f4ca&uri=#{uri_enc}"
  end

  def deep_compare(doi_uri, new, original, path="")
    if new.is_a?(Array)
      new.each_index do |i|
        deep_compare(doi_uri, new[i], original[i], "#{path}[#{i}]")
      end
    elsif new.is_a?(Hash)
      new.each_key do |key|
        deep_compare(doi_uri, new[key], original[key], "#{path}/#{key}")
      end
    elsif new.is_a?(String) && (new.match(/T00:00:00.000Z$/))
      # ignore these time diffs
      assert_equal(new[0..9], original[0..9])
    elsif original.nil?
      # ignore when we have generated a URI
      unless new.match(/^cited:/)
        assert_equal(original, new, "#{doi_uri}: #{path}")
      end
    elsif new.is_a?(String)
      # check scrubbed version too
      scrubbed = Loofah.fragment(original).scrub!(SANITIZER).scrub!(:strip).scrub!(:nofollow).to_s
      if ((original != new ) && (scrubbed != new))
        assert_equal(original, new, "#{doi_uri}: #{path}")
      end
    else
      assert_equal(original, new, "#{doi_uri}: #{path}")
    end
  end

  def json_headers
    { 'Accept'       => Mime::JSON.to_s,
      'Content-Type' => Mime::JSON.to_s }
  end

  test 'complete JSON upload works' do
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', '*.json')).each do |json_file|
      doi_uri = 'http://dx.doi.org/10.1371/' + json_file.match(/(journal.*).json$/)[1]
      post('/papers?api_key=841c5d42-2ca3-42fc-8eda-87fbccc1f4ca',
           File.read(json_file).to_s,
           'Accept'       => Mime::JSON.to_s,
           'Content-Type' => Mime::JSON.to_s)
      assert_response(:created, @response.body)
      assert_equal("http://www.example.com/papers?uri=#{URI.encode_www_form_component(doi_uri)}",
                   @response.headers['Location'])
      get('/papers', {uri: doi_uri, include: 'cited'},
          'Accept' => Mime::JSON.to_s)
      original = MultiJson.load(File.read(json_file).to_s)
      # API will add truncated_before, truncated_after if they are empty
      original['citation_groups'].each do |g|
        context = g['context']
        context['truncated_before'] = false unless context.key?('truncated_before')
        context['truncated_after'] = false unless context.key?('truncated_after')
      end
      new = MultiJson.load(@response.body.to_s)
      deep_compare(doi_uri, new, original)
    end
  end

  test "It should fail if the paper already exists" do
    post mk_post_path(@uri), @metadata.to_json, json_headers
    assert_response :created

    post mk_post_path(@uri), @metadata.to_json, json_headers
    assert_response :forbidden
  end

  test 'Overwriting old data should work' do
    post mk_post_path(@uri), @metadata.to_json, json_headers
    assert_response :created

    new_metadata = @metadata.dup
    new_metadata['bibliographic'] = { 'title' => 'New Title' }

    put mk_post_path(@uri), new_metadata.to_json, json_headers
    assert_response :ok

    get mk_post_path(@uri), {}, json_headers
    assert_equal new_metadata, MultiJson.load(@response.body)
  end
end
