class HelperTest < ActiveSupport::TestCase
  test 'should remove unwanted html tags' do
    assert_equal 'Text', Serializer::Helper.sanitize_html('<span>Text</span>')
    assert_equal 'Text', Serializer::Helper.sanitize_html('<form>Text</form>')
    assert_equal 'Text', Serializer::Helper.sanitize_html('<script>Text</script>')
    assert_equal nil,    Serializer::Helper.sanitize_html('<img src="foo"></img>')
  end

  test 'should accept listed tags' do
    assert_equal '<b>Text</b>',           Serializer::Helper.sanitize_html('<b>Text</b>')
    assert_equal '<strong>Text</strong>', Serializer::Helper.sanitize_html('<strong>Text</strong>')
    assert_equal '<q>Text</q>',           Serializer::Helper.sanitize_html('<q>Text</q>')
  end

  test 'should remove unknown html tags' do
    assert_equal 'Text', Serializer::Helper.sanitize_html('<fred>Text</fred>')
  end

  test 'should remove invalid attributes' do
    assert_equal '<b>Text</b>',           Serializer::Helper.sanitize_html('<b foo="bar">Text</b>')
  end

  test 'should add nofollow to link tags' do
    assert_equal '<a src="bar" rel="nofollow">Text</a>',           Serializer::Helper.sanitize_html('<a src="bar">Text</a>')
  end

  test 'should strip js link' do
    assert_equal '<a rel="nofollow">Text</a>',           Serializer::Helper.sanitize_html('<a src="javascript:foo">Text</a>')
  end

  test 'it should normalize URIs properly' do
    assert_equal 'http://example.org/~hello', Serializer::Helper.normalize_uri('http://EXAMPLE.org/%7ehello')
    assert_equal 'http://example.org/', Serializer::Helper.normalize_uri('http://example.org//'), 'remove useless trailing slash'
    assert_equal 'http://example.org/path/', Serializer::Helper.normalize_uri('http://example.org/path/'), 'do not remove trailing slash'
    assert_equal 'http://example.org/q', Serializer::Helper.normalize_uri('http://example.org/q?'), 'remove empty query'
    assert_equal 'http://example.org/q#a', Serializer::Helper.normalize_uri('http://example.org/q#a'), 'do remove fragment'
    assert_equal 'urn:isbn:3-900051-07-0', Serializer::Helper.normalize_uri('urn:isbn:3-900051-07-0'), 'works with URNs'
  end
end
