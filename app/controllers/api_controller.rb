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

class ApiController < ::ApplicationController

  # protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token # Allow JSONP requests

  protected

  def authentication_required!
    if authenticated_user.blank?
      message = get_api_key ? 'Not Authorized' : 'Api-Key not provided'
      render status: :unauthorized, text:message
    end
  end

  def authenticated_user
    # Not using a nil test since nil is a valid value
    if ! defined? @authenticated_user
      api_key = get_api_key
      @authenticated_user = api_key && User.for_key(api_key)

      if @authenticated_user
        logger.info("Authenticated user: #{@authenticated_user.display}")
      else
        logger.info('No user authenticated.')
      end
    end

    @authenticated_user
  end

  private

  def get_api_key
    if request.headers['Authorization'] && request.headers['Authorization'].start_with?('api-key ')
      request.headers['Authorization'][8..-1]
    else
      params['api-key'] || params['api_key']
    end
  end

end
