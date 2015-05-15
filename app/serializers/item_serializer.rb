class ItemSerializer < BaseSerializer
  attributes :id, :plan_id, :mark_id, :mark, :meta_category, 
    :updated_at, :start_date, :end_date, :start_time, :end_time, :confirmation
  # has_one :plan, serializer: PlanSerializer
  # has_one :mark, serializer: MarkSerializer

  def mark
    PlaceSerializer.new( Place.find_by( id: object.mark.place_id ) ).as_json
  end

end