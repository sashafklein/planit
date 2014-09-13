class Icon
  
  attr_accessor :category, :is_lodging, :is_meal, :planit_mark

  def initialize(category, is_lodging, is_meal, planit_mark)
    @category, @is_lodging, @is_meal, @planit_mark = category, is_lodging, is_meal, planit_mark
  end

  def filename
    if is_lodging 
      if lodging_categories.include? category
        lodging_icon
      elsif camp_categores.include? category
        camping_icon
      end
    elsif food_categories.include?(category) || is_meal
      food_icon
    elsif cafe_categories.include? category
      coffee_tea_icon
    elsif bar_categories.include?(category)
      bar_icon
    elsif planit_mark != ''
      starred
    end
  end

  private

  def food_categories
    ['restaurant']
  end

  def camp_categories
    ['campsite']
  end

  def bar_categories
    ['bar', 'hotel bar']
  end

  def lodging_categories
    ['hotel', 'apartment', 'house', '']
  end

  def cafe_categories
    ['coffee', 'café', 'tea', 'coffeeshop', 'teashop', 'coffee shop', 'tea shop']
  end

  def starred
    return '' if planit_mark.blank?
    "_#{planit_mark}"
  end

  def lodging_icon
    "hotel#{starred}"
  end

  def camping_icon
    "campsite#{starred}"
  end

  def food_icon
    "food#{starred}"
  end

  def bar_icon
    "bar#{starred}"
  end

  def coffee_tea_icon
    "coffeetea#{starred}"
  end
end