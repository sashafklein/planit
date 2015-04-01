class StaticsController < ApplicationController
  
  before_action :authenticate_user!, only: [:save, :about, :invite]

  def about
    redirect_to save_path
  end

  def save
    redirect_to beta_path unless current_user_is_active
  end

  def button
    redirect_to beta_path unless current_user_is_active
  end

  def invite
    redirect_to beta_path unless current_user_is_active
  end

  def feedback
    redirect_to beta_path unless current_user_is_active
  end

  def beta
    redirect_to invite_path if current_user_is_active
  end

  def auto_signin
    return redirect_to root_path if current_user
    return to_beta unless params[:email] && params[:token]
    return to_beta unless user = User.find_by(email: params[:email])
    return to_beta unless params[:token] == user.auto_signin_token    

    sign_in(:user, user)
    redirect_and_flash places_user_path(user), success: "You've been successfully signed in."
  end

  private

  def to_beta(msg=nil)
    flash[:error] = msg if msg
    redirect_to beta_path
  end

end