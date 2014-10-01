require 'test_helper'
 
class JsonUploadTest < ActionDispatch::IntegrationTest
  test 'complete JSON upload works' do
    json_file = File.join(Rails.root, 'test', 'fixtures', 'journal.pone.0000000.json')
    post('/papers?api_key=841c5d42-2ca3-42fc-8eda-87fbccc1f4ca',
         File.read(json_file).to_s,
         { 'Content-Type' => 'application/json' })
    assert_response(:ok, @response.body)
  end
end
