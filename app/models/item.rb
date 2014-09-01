class Item

  include PseudoModel

  attr_accessor :day

  delegate :leg, :plan, to: :day

  def initialize(hash, day)
    @day = day
    set_as_instance_variables( hash, defaults )
  end
  
  def self.serialize(item_array, day)
    item_array.map do |item|
      new(item, day)
    end
  end

  def coordinate
    [lat, lon].join(":")
  end

  def local_name_unique?
    return '' unless name && local_name
    local_name.downcase != name.downcase
  end

  def local_name
    @local_name ||= ''
  end

  def name
    @name ||= ''
  end

  private

  def defaults
    { 
      travel_data: false, 
      street_address: false, 
      city: false, 
      state: false, 
      phone: false,
      category: false 
    }
  end
end