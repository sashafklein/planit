class ItemSerializer < ActiveModel::Serializer
  has_one :day, serializer: DaySerializer
  has_one :plan, serializer: DaySerializer

  attributes :leg, :hours, :weekday

  def leg
    object.leg ? LegSerializer.new(object.leg) : nil
  end

  def weekday
    object.weekday
  end
end