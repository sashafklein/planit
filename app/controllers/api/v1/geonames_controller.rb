class Api::V1::GeonamesController < ApiController

  def search
    return permission_denied_error unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:query].try(:length)

    query = params[:query].to_s

    # res = HTTParty.get "http://api.geonames.org/search?q=#{ query }&fuzzy=0.8&username=#{ username }&lang=en&type=json&maxRows=10&style=full"
    res = HTTParty.get "http://api.geonames.org/search?q=#{ query }&featureClass=P&username=#{ username }&lang=en&type=json&maxRows=25&style=full"
    render json: res.body
  end

  def find
    return permission_denied_error unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:id].try(:length)

    id = params[:id].to_s

    res = HTTParty.get "http://api.geonames.org/getJSON?geonameId=#{ id }&username=#{ username }&lang=en&type=json&style=full"
    render json: res.body
  end

  def point
    return permission_denied_error unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:lat].try(:length) && params[:lon].try(:length)

    lat = params[:lat].to_i
    lon = params[:lon].to_i

    # http://api.geonames.org/findNearbyPlaceNameJSON?lat=35.7111057142935&lng=139.796369075775&username=planit
    res = HTTParty.get "http://api.geonames.org/findNearbyPlaceNameJSON?lat=#{ lat }&lng=#{ lon }&radius=10&username=#{ username }&lang=en&maxRows=10&style=full"
    render json: res.body
  end

  private

  def username
    "planit"
  end

end