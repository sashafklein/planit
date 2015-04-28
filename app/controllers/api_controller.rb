class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  respond_to :json, :js
  
  private

  rescue_from StandardError do |e| 
    api_rescue(e)
  end

  def permission_denied_error(meta: {}, line: nil)
    error(status: 403, message: 'Permission Denied!', meta: meta, line: line)
  end

  def error(status: 500, message: 'Something went wrong', meta: {}, line: nil)
    response = {
      response_type: "ERROR",
      message: message,
      meta: meta,
      error: true,
      controller: self.class.to_s,
      line: line,
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

  def api_rescue(e)
    relevant_backtrace_line = e.backtrace.find{ |l| l.include?('/api/v1/') }
    line = relevant_backtrace_line ? relevant_backtrace_line.split('.rb:').last : nil
    error(status: 500, line: line, meta: { error_class: e.class.to_s, error_message: e.message })
  end
end