class PlaceOptionChooseJob < ActiveJob::Base
  
  def perform(place_option_id:)
    PlaceOption.find(place_option_id).choose!
  end
end