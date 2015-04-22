class Api::V1::FoursquareController < ApiController

  def search
    return permission_denied_error(line: __LINE__) unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:near].try(:length) && params[:query].try(:length)

    client = Foursquare2::Client.new( { client_id: Env.foursquare_client_id, client_secret: Env.foursquare_client_secret, locale: 'en' }.merge(version) )
    response = client.explore_venues( { near: params[:near], query: params[:query], venuePhotos: true }.merge(version) ).to_sh.super_fetch(:groups, 0, :items) || []

    render json: response.map{ |v| Completers::ApiVenue::FoursquareExploreVenue.new(v).serialize([:image_url, :images, :foursquare_id]) }
  rescue => e
    line = begin e.backtrace.first.split(".rb:").last.split(":").first; rescue; nil; end
    error(message: e.message, line: line, meta: { fs_version: Env.foursquare_version_number })
  end

  private

  def version
    { api_version: Env.foursquare_version_number || '20140806' }
  end

end