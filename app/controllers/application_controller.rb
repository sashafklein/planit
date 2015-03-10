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

  def redirect_back(key: nil, msg: nil)
    flash[key] = msg if key && msg
    redirect_to :back || root_path
  end

  def not_authorized_redirect
    flash[:error] = "Woops! Doesn't look like that page is yours!"
    redirect_to root_path
  end 

  def authenticate_admin!
    not_authorized_redirect unless admin?
  end 

  def permission_denied
    flash[:error] = "Sorry! No public access to this page. Sign in to continue."
    redirect_to root_path
  end

  def admin?
    current_user ? current_user.admin? : false
  end 

  def member?
    current_user ? current_user.member? : false
  end 

  def same_user?
    current_user == @user
  end
end
