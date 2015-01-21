class ApplicationController < ActionController::Base

  include Pundit

  protect_from_forgery with: :exception
  before_action :update_sanitized_params, if: :devise_controller?

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name)
  end

  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
 
  private
 
  def permission_denied
    flash[:error] = "You can't do that."
    redirect_to root_path
  end

  def admin?
    current_user ? current_user.admin? : false
  end 

  def same_user?
    current_user == @user
  end
end
