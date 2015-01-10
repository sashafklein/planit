class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :update_sanitized_params, if: :devise_controller?
  
  def after_sign_in_path_for(resource)
    new_plan_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_plan_path
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name)
  end

end
