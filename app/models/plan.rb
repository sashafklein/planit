class Plan < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  has_many :legs
  has_many :days, through: :legs
  has_many :items, as: :groupable

  has_many :moneyshots, class_name: 'Image', as: :imageable
  has_many :images, as: :imageable

  delegate :last_day, :departure, to: :last_leg
  delegate :arrival, to: :first_leg

  def first_leg
    legs.first
  end

  def last_leg
    legs.last
  end

  def moneyshot
    moneyshots.first
  end

  def overview_coordinates
    legs.map(&:coordinates).join("+")
  end

  def trailblaze_date
    starts_at ? starts_at.strftime('%b %Y') : nil
  end

  def maptype
    '' #todo
  end

  def bucket
    legs.where(name: nil).first #todo -- majorly incomplete
  end

  def total_days
    days.count
  end
end
