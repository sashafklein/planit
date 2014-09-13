class PseudoPlan

  include PseudoModel

  attr_accessor :legs, :bucket
  delegate :last_day, to: :last_leg

  def initialize(yaml)
    @legs = PseudoLeg.serialize(yaml.delete('legs').compact, self)
    if yaml['bucketed']
      @bucket = PseudoLeg.serialize(yaml.delete('bucketed').compact, self)
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
    legs.map(&:center_coordinate).join("+")
    # legs.map(&:coordinates).join("+")
  end

  def bucketed
    @bucketed ||= false
  end

  def flat_items
    legs.map(&:flat_items).flatten
  end

  private

  def defaults
    { 
      maptype: '',
      start_date: false,
      tips: []
    }  
  end
end