class ItinerariesController < ApplicationController
  
  before_action :load_yaml_data, only: [:show]

  def show
    @marker_coordinates = @data.map_locations.map{ |loc| coords_from(loc) }.join('+')
    @slugged_title = params[:id]
  end

  def new
  end

  def jmt
    redirect_to itinerary_path('john-muir-trail')
  end


  private

  def load_yaml_data
    file_path = File.join(Rails.root, 'app', 'models', 'itineraries', 'yaml', "#{params[:id]}.yml")

    if !File.exists? file_path
      flash[:error] = "No itinerary exists by that name."
      redirect_to root_path
    else
      @data = OpenStruct.new YAML.load_file( file_path )
    end
  end

  def coords_from(address)
    loc = Geocoder.search(address).first.data["geometry"]["location"]
    [ loc['lat'], loc['lng'] ].join(":")
  end
end