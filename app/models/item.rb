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
    if name && local_name
      local_name.downcase != name.downcase
    else
      true
    end
  end

  private

  def defaults
    { 
      travel_data: false, 
      street_address: false, 
      city: false, 
      state: false, 
      phone: false,
      category: false,
      travel_type: false,
      has_tab: false,
      tab_image: false,
      website: false,
      source: false,
      notes: false,
      name: '',
      local_name: false
    }
  end
end