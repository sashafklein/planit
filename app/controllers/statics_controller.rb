class StaticsController < ApplicationController
  
  before_action :authenticate_user!, only: [:save, :about, :invite]
  before_action :authenticate_admin!, only: [:invite]

  def save
  end

  def about
  end

  def invite
  end

  def beta
  end

end