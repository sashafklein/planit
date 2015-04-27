class ItemSerializer < ActiveModel::Serializer
  attributes :id, :updated_at, :plan_id, :mark_id, :mark
  # has_one :plan, serializer: PlanSerializer
  # has_one :mark, serializer: MarkSerializer

  def mark
    PlaceSerializer.new( Place.find_by( id: object.mark.place_id ) ).as_json
  end
end