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

  def show_icon
    if lodging && category.downcase == 'hotel'
      show_lodging_icon
    elsif lodging && category.downcase == 'apartment'
      show_lodging_icon
    elsif lodging && category.downcase == 'house'
      show_lodging_icon
    elsif lodging && category == ''
      show_lodging_icon
    elsif lodging && category.downcase == 'campsite'
      show_camping_icon
    elsif category == 'restaurant'
      show_food_icon
    elsif meal
      show_food_icon
    elsif category.downcase == 'coffee'
      show_coffeetea_icon
    elsif category.downcase == 'café'
      show_coffeetea_icon
    elsif category.downcase == 'tea'
      show_coffeetea_icon
    elsif category.downcase == 'coffeeshop'
      show_coffeetea_icon
    elsif category.downcase == 'teashop'
      show_coffeetea_icon
    elsif category.downcase == 'coffee shop'
      show_coffeetea_icon
    elsif category.downcase == 'tea shop'
      show_coffeetea_icon
    elsif category.downcase == 'bar'
      show_bar_icon
    elsif category.downcase == 'hotel bar'
      show_bar_icon
    end
  end

  def starred
    if planit_mark == "star"
      "_star"
    elsif planit_mark == "up"
      "_up"
    elsif planit_mark == "down"
      "_down"
    else
      ""
    end
  end

  def is_down?
    if planit_mark == "down"
      "down"
    end
  end

  def show_lodging_icon
    "hotel" + starred
  end

  def show_camping_icon
    "campsite" + starred
  end

  def show_food_icon
    "food" + starred
  end

  def show_bar_icon
    "bar" + starred
  end

  def show_coffeetea_icon
    "coffeetea" + starred
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
      category: '',
      travel_type: false,
      has_tab: false,
      planit_mark: '',
      tab_image: "tab_stand_in.png",
      lodging: false,
      website: false,
      source: false,
      source_url: false,
      notes: false,
      meal: false,
      name: '<br>'.html_safe,
      local_name: false
    }
  end
end