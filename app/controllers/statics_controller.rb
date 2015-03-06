class StaticsController < ApplicationController
  
  before_action :authenticate_user!, only: [:save, :waitlist, :welcome]

  def save
  end

  def welcome
  end

  def waitlist
  end

  def privacy
  end

end