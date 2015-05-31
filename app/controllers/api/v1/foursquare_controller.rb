class Api::V1::FoursquareController < ApiController

  def search
    return permission_denied_error(line: __LINE__) unless current_user
    return error(message: "Insufficient search params", line: __LINE__) unless params[:near].present? && params[:query].present?
    render json: Apis::Foursquare.new.explore( params.slice(:near, :query).merge({ limit: 6, locale: 'en', venuePhotos: 1 }) )
  rescue => e
    line = number = file = method = nil
    begin 
      line = e.backtrace.find{ |l| l.include?('code/planit') }
      number = line.split(".rb:").last.split(":").first
      file = line.split(".rb:").first.gsub("/Users/sasha/code/planit/", '') + '.rb'
      method = line.split("`").last.gsub("'", '')
    end
    error(message: e.message, line: number, meta: { file: file, method: method })
  end

end