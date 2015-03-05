class Plan < BaseModel

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user

  has_many :legs
  has_many :days, through: :legs
  has_many :items, dependent: :destroy
  
  has_many_polymorphic table: :images, name: :imageable
  has_many_polymorphic table: :sources

  boolean_accessor :published
  delegate :last_day, :departure, to: :last_leg
  delegate :arrival, to: :first_leg

  def source
    sources.first
  end

  def best_image
    images.first || Image.where(imageable_type: 'Place', imageable_id: items.marks.places.pluck(:id)).first
  end

  def has_lodging?
    items.marks.where(lodging: true).any?
  end

  def first_leg
    legs.first
  end

  def last_leg
    legs.last
  end

  def coordinates
    items.coordinates
  end

  def maptype
    '' #todo
  end

  def bucket
    Item.where(day_id: nil, plan_id: self.id)
  end

  def total_days
    days.count
  end

  def remove_all_traces!
    items.marks.places.destroy_all
    items.marks.destroy_all
    destroy
  end

end
