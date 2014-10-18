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
      meta: meta
    }

    render json: response.to_json, status: status
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Data-Type, X-Requested-With'
    headers['Access-Control-Max-Age'] = "1728000"
  end
end