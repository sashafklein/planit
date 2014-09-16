class PseudoItem

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

  def is_lodging?
    if lodging 
      return true
    elsif category.downcase == 'hotel'
      return true
    elsif lodging && category.downcase == 'bed & breakfast'
      return true
    elsif lodging && category.downcase == 'apartment'
      return true
    elsif lodging && category.downcase == 'house'
      return true
    elsif lodging && category.downcase == 'resort'
      return true
    elsif lodging && category == ''
      return true
    else
      return false
    end
  end

  def is_camping?
    if lodging && category.downcase == 'campsite'
      return true
    elsif category.downcase == 'campsite'
      return true
    else
      return false
    end
  end

  def is_food?
    if category.downcase['restaurant']
      return true
    elsif category.downcase == 'deli / bodega'
      return true
    elsif meal
      return true
    else
      return false
    end
  end

  def is_relax?
    categories = ['spa', 'hotel spa', 'hotel pool', 'bath', 'hotel bath']
    if categories.include?(category.downcase) || (category.downcase == 'resort' && !lodging)
      true
    else 
      false
    end
  end

  def is_bar?
    if category.downcase == 'bar'
      return true
    elsif category.downcase == 'hotel bar'
      return true
    else
      return false
    end
  end

  def is_coffeetea?
    if category.downcase == 'coffee'
      return true
    elsif category.downcase == 'café'
      return true
    elsif category.downcase == 'tea'
      return true
    elsif category.downcase == 'coffeeshop'
      return true
    elsif category.downcase == 'teashop'
      return true
    elsif category.downcase == 'coffee shop'
      return true
    elsif category.downcase == 'tea shop'
      return true
    else
      return false
    end
  end

  def is_sight?
    if is_coffeetea? 
      return false
    elsif is_lodging? 
      return false
    elsif is_camping? 
      return false
    elsif is_food? 
      return false
    elsif is_bar? 
      return false
    elsif is_relax? 
      return false
    else 
      return true
    end
  end

  def show_icon
    if category
      if is_lodging? 
        show_lodging_icon
      elsif is_camping?
        show_camping_icon 
      elsif is_food?
        show_food_icon 
      elsif is_coffeetea?
        show_coffeetea_icon 
      elsif is_bar?
        show_bar_icon
      elsif is_relax?
        show_relax_icon
      elsif planit_mark != ''
        show_sight_icon
      end
    else
      starred
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
      friends_recos?
    end
  end

  def friends_recos?
    if downby && recoby
      "_up"
    elsif recoby
      "_star"
    elsif downby
      "_down"
    else
      ''
    end
  end

  def is_down?
    if planit_mark == "down"
      "down"
    end
  end

  def show_sight_icon
    "sight" + starred
  end

  def show_relax_icon
    "relax" + starred
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
      county: false, 
      state: false, 
      country: false, 
      phone: false,
      local_phone: false,
      international_phone: false,
      category: '',
      travel_type: false,
      has_tab: false,
      planit_mark: false,
      tab_image: "tab_stand_in.png",
      lodging: false,
      website: false,
      source: false,
      source_url: false,
      rating: false,
      downby: false,
      recoby: false,
      notes: false,
      meal: false,
      name: '<br>'.html_safe,
      local_name: false
    }
  end
end