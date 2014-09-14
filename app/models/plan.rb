class Plan < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  has_many :legs
  has_many :days, through: :legs
  has_many :items, through: :legs

  delegate :last_day, :departure, to: :last_leg
  delegate :arrival, to: :first_leg

  def moneyshots
    []
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

  def overview_coordinates
    legs.map(&:coordinates).join("+")
  end
end
