class Plan

  include PseudoModel

  attr_accessor :legs, :bucket
  delegate :last_day, to: :last_leg

  def initialize(yaml)
    @legs = Leg.serialize(yaml.delete('legs').compact, self)
    if yaml['bucketed']
      @bucket = Leg.serialize(yaml.delete('bucketed').compact, self)
    end
    set_as_instance_variables( yaml, defaults )
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

  private

  def defaults
    { 
      maptype: '',
      tips: []
    }  
  end
end