class PlaceValidator < ActiveModel::Validator
  def validate(record)
    if preexisting = Place.where.not(id: record.id).where(region: record.region, locality: record.locality).with_address(record.street_address).first
      record.errors[:uniqueness] << "This place is already in the database. ID: #{preexisting.id}"
    end
  end
end 