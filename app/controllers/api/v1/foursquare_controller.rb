class Api::V1::FoursquareController < ApiController

  def search
    return permission_denied_error(line: __LINE__) unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:near].present? && params[:query].present?
    render json: Apis::Foursquare.new.explore( params.slice(:near, :query).merge({ limit: 6, locale: 'en', venuePhotos: 1 }) )
  rescue => e
    line = begin e.backtrace.first.split(".rb:").last.split(":").first; rescue; nil; end
    error(message: e.message, line: line)
  end

end