class PlaceValidator < BaseValidator
  
  def validate(place)
    super
    validate_presence!(:lat, :lon, :timezone_string, :feature_type)
    validate_any!(:names)
    validate_street_address_if_relevant!
    validate_enough!(2, :country, :region, :subregion, :locality, :sublocality)
  end

  private

  def validate_street_address_if_relevant!
    if place.destination? 
      place.errors[:base] << "Specific places need at least one street address" unless place.street_address
    end
  end

end 