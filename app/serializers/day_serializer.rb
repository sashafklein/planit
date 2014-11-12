class DaySerializer < ActiveModel::Serializer
  attributes :id, :place_in_trip

  # def place_in_trip
  #   object.place_in_trip
  # end
end
