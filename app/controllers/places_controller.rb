class PlacesController < ApplicationController

  before_action :load_place, only: [:show]
  before_action :authenticate_user!, only: [:new, :show]

  def show
  end

  def new
  end

  def index
    if current_user
      redirect_to user_path(current_user)+"/places"
    else
      redirect_to new_user_session_path
    end
  end

  private

  def load_place
    @place = Place.includes(:images).find(params[:id])
  end
end