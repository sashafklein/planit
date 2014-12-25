class Plan < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  has_many :legs
  has_many :days, through: :legs
  has_many :items, dependent: :destroy

  has_many :moneyshots, class_name: 'Image', as: :imageable
  has_many :images, as: :imageable

  delegate :last_day, :departure, to: :last_leg
  delegate :arrival, to: :first_leg

  # PLANS. OPERATORS

  # PLAN OPERATORS

  # def has_travel?
  #   if legs.has_travel?
  #     return true
  #   end
  #   return nil
  # end

  def has_lodging?
    items.marks.where(lodging: true).any?
  end

  def first_leg
    legs.first
  end

  def last_leg
    legs.last
  end

  def moneyshot
    moneyshots.first
  end

  def coordinates
    items.coordinates
  end

  def trailblaze_date
    starts_at ? starts_at.strftime('%b %Y') : nil
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
