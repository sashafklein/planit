class ItemSerializerWithHours < ItemSerializer
  
  def mark
    PlaceSerializerWithHours.new( Place.find_by( id: object.mark.place_id ) ).as_json
  end
end