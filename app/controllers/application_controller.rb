class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  # protect_from_forgery 
  protect_from_forgery with: :exception
  before_filter :update_sanitized_params, if: :devise_controller?

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name)
  end


  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
 
  # Enforces access right checks for individuals resources
  after_filter :verify_authorized, :except => :index
 
  # Enforces access right checks for collections
  after_filter :verify_policy_scoped, :only => :index
 
 
  private
 
  def permission_denied
    head 403
  end
 
end
