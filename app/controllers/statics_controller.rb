class StaticsController < ApplicationController
  
  before_action :authenticate_user!, only: [:save, :about, :invite]

  def save
  end

  def about
  end

  def invite
    redirect_to beta_path unless current_user.member? || current_user.admin?
  end

  def beta
    redirect_to invite_path if current_user.member?
  end

end