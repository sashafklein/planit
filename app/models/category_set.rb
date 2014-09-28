class CategorySet
  
  attr_accessor :item
  delegate :category, :lodging?, :meal?, to: :item

  def initialize(item)
    @item = item 
  end

  def list
    l = []
    l << 'cafe' if cafe?
    l << 'sight' unless edible? || relaxation? || lodging?|| meal?
    l << 'food' if edible? || meal?
    l << 'drink' if bar?
    l << 'lodging' if lodging?
    l << 'camping' if camp?
    l << 'relaxation' if relaxation?
    l
  end

  private

  def method_missing(meth, *args, &block)
    collection = "#{meth.to_s.gsub('?','')}s"
    if respond_to? collection , true
      send(collection).include? category
    else
      super
    end
  end

  def edibles
    foods + camps + cafes + bars
  end

  def foods
    ['restaurant']
  end

  def camps
    ['campsite']
  end

  def bars
    ['bar', 'hotel bar']
  end

  def lodgings
    ['hotel', 'apartment', 'house', '']
  end

  def cafes
    ['coffee', 'café', 'tea', 'coffeeshop', 'teashop', 'coffee shop', 'tea shop']
  end

  def relaxations
    ['spa', 'hotel spa', 'hotel pool', 'bath', 'hotel bath']
  end

  def relaxation?
    relaxations.include?(category) || (category == 'resort' && !lodging)
  end
end