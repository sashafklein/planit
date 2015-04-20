class Api::V1::FoursquareController < ApiController

  def search
    return permission_denied_error unless current_user
    return error(500, "Insufficient search params") unless params[:near] && params[:query]
   
    client = Foursquare2::Client.new( api_version: Env.foursquare_version_number, client_id: Env.foursquare_client_id, client_secret: Env.foursquare_client_secret, locale: 'en' )
    response = client.explore_venues( near: params[:near], query: params[:query], venuePhotos: true ).to_sh.super_fetch(:groups, 0, :items) || []
    
    render json: response.map{ |v| Completers::ApiVenue::FoursquareExploreVenue.new(v).serialize([:image_url, :images, :foursquare_id]) }
  end

end