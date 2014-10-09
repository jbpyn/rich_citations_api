require 'test_helper'

class JsonUploadTest < ActionDispatch::IntegrationTest
  test 'complete JSON upload works' do
    json_file = File.join(Rails.root, 'test', 'fixtures', 'journal.pone.0000000.json')
    post('/papers?api_key=841c5d42-2ca3-42fc-8eda-87fbccc1f4ca',
         File.read(json_file).to_s,
         'Accept'       => Mime::JSON.to_s,
         'Content-Type' => Mime::JSON.to_s)
    assert_response(:created, @response.body)
    assert_equal('http://www.example.com/papers?uri=http%3A%2F%2Fdx.doi.org%2F10.1371%2Fjournal.pone.0000000',
                 @response.headers['Location'])
    get('/papers', {uri: 'http%3A%2F%2Fdx.doi.org%2F10.1371%2Fjournal.pone.0000000'},
        'Accept' => Mime::JSON.to_s)
    original = MultiJson.load(File.read(json_file).to_s)
    new = MultiJson.load(@response.body.to_s)
    assert_equal(original['references'][0], new['references'][0])
  end

  test 'complete JSON upload works (2)' do
    json_file = File.join(Rails.root, 'test', 'fixtures', 'journal.pone.0107541.json')
    post('/papers?api_key=841c5d42-2ca3-42fc-8eda-87fbccc1f4ca',
         File.read(json_file).to_s,
         'Accept'       => Mime::JSON.to_s,
         'Content-Type' => Mime::JSON.to_s)
    assert_response(:created, @response.body)
    assert_equal('http://www.example.com/papers?uri=http%3A%2F%2Fdx.doi.org%2F10.1371%2Fjournal.pone.0107541',
                 @response.headers['Location'])
  end
end
