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
    return false unless lat && lon
    [lat, lon].join(":")
  end

  def local_name_unique?
    if name && local_name
      local_name.downcase != name.downcase
    else
      true
    end
  end

  def previous(index)
    return nil if index == 0
    day.items[index - 1]
  end

  private

  def defaults
    { 
      travel_data: false, 
      address: false,
      street_address: false, 
      city: false, 
      state: false, 
      phone: false,
      local_phone: false,
      international_phone: false,
      category: false,
      travel_type: false,
      has_tab: false,
      tab_image: "tab_stand_in.png",
      lodging: false,
      website: false,
      source: false,
      source_url: false,
      notes: false,
      name: '<br>'.html_safe,
      local_name: false
    }
  end
end