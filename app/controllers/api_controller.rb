class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  respond_to :json, :js
  
  private

  def permission_denied_error
    error(403, 'Permission Denied!')
  end

  def error(status=500, message = 'Something went wrong', meta = {})
    response = {
      response_type: "ERROR",
      message: message,
      meta: meta,
      error: true,
      controller: self.class.to_s,
      code: status
    }

    render json: response.to_json, status: status
  end

  def success
    render json: { success: true }
  end

  def default_serializer_options
    { root: false }
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'

    if request.headers['Access-Control-Request-Headers'] 
      headers['Access-Control-Allow-Headers'] = request.headers['Access-Control-Request-Headers'] 
    end
    
    headers['Access-Control-Max-Age'] = "1728000"
    headers.except!('X-Frame-Options')
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end