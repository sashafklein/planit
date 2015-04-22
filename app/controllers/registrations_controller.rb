class RegistrationsController < Devise::RegistrationsController
  def create
    if AcceptedEmail.find_by(email: sign_up_params[:email])
      super
    else
      MailListEmail.waitlist!( sign_up_params )
      redirect_and_flash root_path, error: "Planit is in private beta. We'll get back in touch shortly"
    end
  end

  protected

  def after_sign_up_path_for(resource)
    update_share if session[:share_id]
    get_back_path! || root_path
  end
end