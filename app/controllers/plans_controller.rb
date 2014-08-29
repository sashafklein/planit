class PlansController < ApplicationController
  
  before_action :load_yaml_data, only: [:show, :print]

  def show
  end

  def new
  end

  def jmt
    redirect_to plan_path('john-muir-trail')
  end

  def welcome
  end

  def print
  end


  private

  def load_yaml_data
    file_path = File.join(Rails.root, 'app', 'models', 'plans', 'yaml', "#{params[:id]}.yml")

    if !File.exists? file_path
      flash[:error] = "No plan exists by that name."
      redirect_to root_path
    else
      @data = OpenStruct.new YAML.load_file( file_path )
      @marker_coordinates = @data.map_locations.map{ |loc| coords_from(loc) }.compact.join('+')
      @slugged_title = params[:id]
    end
  end

  def coords_from(address)
    first_one = Geocoder.search(address).first
    if first_one
      loc = first_one.data["geometry"]["location"]
      [ loc['lat'], loc['lng'] ].join(":")
    else
      nil
    end
  end
end