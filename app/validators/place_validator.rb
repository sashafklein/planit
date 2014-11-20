class PlaceValidator < ActiveModel::Validator
  
  def validate(record)
    validate_lat_presence(record)
    validate_lon_presence(record)
    validate_name_presence(record)
  end

  private

  def validate_lat_presence(record)
    if !record.lat.present?
      record.errors[:base] << "Lat can't be blank"
    end
  end

  def validate_lon_presence(record)
    if !record.lon.present?
      record.errors[:base] << "Lon can't be blank"
    end
  end

  def validate_name_presence(record)
    if !record.name
      record.errors[:base] << "Names can't be blank"
    end
  end
end 