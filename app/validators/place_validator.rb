class PlaceValidator < ActiveModel::Validator
  
  attr_accessor :record
  def validate(record)
    @record = record
    validate_presence(:lat, :lon, :names, :country)
  end

  private

  def validate_presence(*atts)
    atts.each do |att|
      if !record[att].present? && !record[att] == false
        record.errors[:base] << "#{att.capitalize} can't be blank"
      end
    end
  end

end 