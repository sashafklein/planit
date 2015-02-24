class PlaceValidator < ActiveModel::Validator
  
  attr_accessor :place
  def validate(place)
    @place = place
    validate_presence!(:lat, :lon, :country, :locality, :timezone_string, :feature_type)
    validate_any!(:names)
    validate_street_address_if_relevant
  end

  private

  def validate_presence!(*atts)
    atts.each do |att|
      if !place[att].is_defined?
        place.errors[:base] << "#{att.capitalize} can't be blank"
      end
    end
  end

  def validate_any!(*atts)
    atts.each do |att|
      if !place[att].compact.any?
        place.errors[:base] << "#{att.capitalize} can't be empty"
      end
    end
  end

  def validate_street_address_if_relevant
    if place.destination? 
      place.errors[:base] << "Specific places need at least one street address" unless place.street_address
    end
  end

end 