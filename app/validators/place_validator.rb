class PlaceValidator < BaseValidator
  
  def validate(place)
    super
    validate_presence!(:lat, :lon, :country, :locality, :timezone_string, :feature_type)
    validate_any!(:names)
    validate_street_address_if_relevant!
  end

  private

  def validate_street_address_if_relevant!
    if place.destination? 
      place.errors[:base] << "Specific places need at least one street address" unless place.street_address
    end
  end

end 