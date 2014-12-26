class ItemSerializer < ActiveModel::Serializer
  has_one :day, serializer: DaySerializer
  has_one :plan, serializer: PlanSerializer
  has_one :mark, serializer: MarkSerializer

  attributes :leg, :weekday

  def leg
    object.day ? LegSerializer.new(object.leg) : nil
  end

  def weekday
    object.weekday
  end
end