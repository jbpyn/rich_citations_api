class ApiController < ::ApplicationController

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
