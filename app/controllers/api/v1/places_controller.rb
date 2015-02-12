class Api::V1::PlacesController < ApiController

  def show
    permission_denied_error unless current_user

    @place = Place.find(params[:id])
    render json: @place, serializer: PlaceSerializer
  end

  def index
    permission_denied_error unless current_user

    @places = params[:conditions] ? Place.where( JSON.parse(params[:conditions]) ) : Place.all
    render json: @places, each_serializer: PlaceSerializer
  end

end