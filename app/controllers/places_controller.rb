class PlacesController < ApplicationController
  
  before_action :load_place, only: [:show]

  def show
  end

  private

  def load_place
    @place = Place.find(params[:id])
  end

end