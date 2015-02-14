class PlaceValidator < ActiveModel::Validator
  
  attr_accessor :record
  def validate(record)
    @record = record
    validate_presence!(:lat, :lon, :country, :locality)
    validate_any!(:street_addresses, :names)
  end

  private

  def validate_presence!(*atts)
    atts.each do |att|
      if !record[att].is_defined?
        record.errors[:base] << "#{att.capitalize} can't be blank"
      end
    end
  end

  def validate_any!(*atts)
    atts.each do |att|
      if !record[att].compact.any?
        record.errors[:base] << "#{att.capitalize} can't be empty"
      end
    end
  end

end 