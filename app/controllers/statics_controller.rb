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

end