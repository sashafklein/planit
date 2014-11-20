class ItemSerializer < ActiveModel::Serializer
  has_one :day, serializer: DaySerializer
  has_one :plan, serializer: PlanSerializer

  attributes :leg, :weekday

  def leg
    object.day ? LegSerializer.new(object.leg) : nil
  end

  def weekday
    object.weekday
  end
end