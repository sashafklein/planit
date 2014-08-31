class Plan

  include PseudoModel

  attr_accessor :legs
  delegate :last_day, to: :last_leg

  def initialize(yaml)
    @legs = Leg.serialize(yaml.delete('legs').compact, self)

    set_as_instance_variables yaml
  end

  def moneyshot
    moneyshots.first
  end

  def last_leg
    legs.last
  end

  def overview_coordinates
    legs.map(&:coordinates).join("+")
  end

  def bucketed
    @bucketed ||= false
  end
end