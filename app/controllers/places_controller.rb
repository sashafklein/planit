class PlacesController < ApplicationController
  
  before_action :load_place, only: [:show]
  before_action :authenticate_user!, only: [:new]

  def show
  end

  def new
  end

  private

  def load_place
    @place = Place.find(params[:id])
  end

end