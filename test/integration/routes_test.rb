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

class RoutesTest < ActionDispatch::IntegrationTest

  class DefaultRoutesTest < RoutesTest

    # Default routes can only be tested in one direction

    test 'GET request' do
      assert_recognizes({ controller: 'v0/papers', action: 'show', uri:'test' },
                        { path: '/papers', method: :get },
                        { uri: 'test'  })
    end

    test 'POST request' do
      assert_recognizes({ controller: 'v0/papers', action: 'create' },
                        { path: '/papers', method: :post })
    end

  end

  class V0RoutesTest < RoutesTest

    test 'GET request' do

      assert_routing( { path: '/v0/papers', method: :get },
                      { controller: 'v0/papers', action: 'show', uri:'test' },
                      {},
                      { uri: 'test'  }   )
    end

    test 'POST request' do
      assert_routing(  { path: '/v0/papers', method: :post },
                       { controller: 'v0/papers', action: 'create' }  )
    end
  end

end