class ApplicationController < ActionController::Base

  include Pundit

  protect_from_forgery with: :exception
  before_action :update_sanitized_params, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if current_user.valid_password?(current_user.reset_password_token)
      edit_user_registration_path + current_user.tokened_email
    else
      root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name)
    devise_parameter_sanitizer.for(:account_update).push(:first_name, :last_name)
  end

  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  rescue_from ActiveRecord::RecordNotFound, with: :catch_500_error

  def catch_404_error
    details = []
    details << "To: #{ request.url }" if request.url
    details << "From: #{ request.referrer }" if request.referrer
    @details = details.join("\n")

    respond_to do |format|
      format.html { render template: 'errors/404', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

  def catch_500_error
    controller_class = self.class.to_s.demodulize.split("Controller")[0].singularize
    
    if Object.const_defined?( controller_class ) && controller_class.constantize < ActiveRecord::Base
      @object = controller_class.downcase
    else
      @object = 'record'
    end
    
    report_error "500 coming from #{request.referrer}."

    respond_to do |format|
      format.html { render template: 'errors/500', status: 500 }
      format.all  { render nothing: true, status: 500 }
    end
  end

  def log(msg:, test: false)
    Logger.new(STDOUT).info(msg) unless (Rails.env.test? && !test)
  end

  private

  def redirect_and_flash(path, flash_hash)
    flash[ flash_hash.keys.first ] = flash_hash.values.first
    redirect_to path 
  end

  def redirect_back(key: nil, msg: nil)
    flash[key] = msg if key && msg
    redirect_to(request.referer.present? ? :back : root_path )
  end

  def not_authorized_redirect
    flash[:error] = "Woops! Doesn't look like that page is yours!"
    redirect_to root_path
  end 

  def authenticate_member!
    not_authorized_redirect unless member? || admin?
  end

  def authenticate_admin!
    not_authorized_redirect unless admin?
  end 

  def permission_denied
    flash[:error] = "Sorry! No public access to this page. Sign in to continue."
    redirect_to root_path
  end

  def current_user_is_active
    admin? || member?
  end

  def current_user_owns(record=nil)
    if @user && current_user_is_active
      @user == current_user
    elsif record && current_user_is_active
      record.user_id == current_user.id
    end
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

  def report_error(message)
    Rollbar.log('error', message)
  end

  def qs_path(path, qs_hash={})
    return path unless qs_hash.any?
    querystring = qs_hash.map{ |k, v| [k,v].join("=") }.join("&")
    [path, querystring].join("?")
  end

  def save_back_path!
    session[:saved_back_path] = URI(request.referer || root_path).path
  end

  def get_back_path!
    session.delete(:saved_back_path)
  end
end
