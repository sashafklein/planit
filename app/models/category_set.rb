class CategorySet
  
  ALL_CATEGORIES = %w( Food Drink Relax See Do Stay Money Transit Area Help Shop Other )
  attr_accessor :place
  delegate :category, :categories, to: :place

  def initialize(place)
    @place = place 
  end

  def set_meta_category
    meta_cat = []
    ALL_CATEGORIES.map(&:downcase).each do |meta|
      place.categories.each do |category|
        if categories_for(meta).map(&:downcase).include?(category.downcase)
          meta_cat << meta.capitalize
        end
      end
    end
    return meta_cat.uniq
  end

  private

  def categories_for(meta_category)
    Directories::Categories.new.list[meta_category]
  end

end