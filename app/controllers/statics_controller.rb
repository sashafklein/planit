class StaticsController < ApplicationController
  
  before_action :authenticate_user!, only: [:save]

  def save
  end

end