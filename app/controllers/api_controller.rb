class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  respond_to :json, :js
  
  private

  def permission_denied_error
    error(403, 'Permission Denied!')
  end

  def error(status, message = 'Something went wrong', meta = {})
    response = {
      response_type: "ERROR",
      message: message,
      meta: meta
    }

    render json: response.to_json, status: status
  end
end