class DaySerializer < ActiveModel::Serializer
  attributes :id, :place_in_trip
  has_many :items, serializer: ItemSerializer

  def place_in_trip
    object.place_in_trip
  end
end
