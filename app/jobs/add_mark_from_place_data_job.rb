class AddMarkFromPlaceDataJob < ActiveJob::Base
  queue_as :completer

  def perform( user_id:, data: )

    user = User.find( user_id )
    
    return Rollbar.error("Failed to find given user", { user_id: user_id }) unless user

    mark = Mark.add_from_place_data!( user, data )

    return Rollbar.error("Insufficient Place data.", { data: data }) unless mark

    Pusher.trigger("add-mark-from-place-data-#{ mark.place.foursquare_id }", 'added', PlaceSerializer.new( mark.place ).as_json )

  end
end