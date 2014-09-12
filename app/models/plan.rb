class Plan < ActiveRecord::Base

  belongs_to :user

  delegate :last_day, to: :last_leg

  def moneyshot
    moneyshots.first
  end

  def last_leg
    legs.last
  end

  def overview_coordinates
    legs.map(&:coordinates).join("+")
  end

  def bucketed
    @bucketed ||= false
  end

  def flat_items
    legs.map(&:flat_items).flatten
  end

end
