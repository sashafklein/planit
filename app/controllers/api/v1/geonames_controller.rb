class Api::V1::GeonamesController < ApiController

  def search
    return permission_denied_error unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:query].try(:length)

    query = params[:query].to_s

    url = URI.parse("http://api.geonames.org/search?q=#{ query }&fuzzy=0.8&username=#{ username }&lang=en&type=json&maxRows=10")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    render json: res.body
  end

  def point
    return permission_denied_error unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:lat].try(:length) && params[:lon].try(:length)

    lat = params[:lat].to_i
    lon = params[:lon].to_i

    url = URI.parse("http://api.geonames.org/findNearbyPlaceNameJSON?lat=#{ lat }&lng=#{ lon }&radius=10&username=#{ username }&lang=en&maxRows=10")
    # url = URI.parse("http://api.geonames.org/citiesJSON?north=#{ lat + 0.0075 }&south=#{ lat - 0.0075 }&east=#{ lon + 0.0125 }&west=#{ lon - 0.0125 }&username=planit&lang=en&style=full")
    puts url
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    render json: res.body
  end

  private

  def username
    "planit"
  end

end