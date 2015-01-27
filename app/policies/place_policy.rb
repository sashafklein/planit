class PlacePolicy < ApplicationPolicy
  attr_reader :user, :place

  def initialize(user, place)
    @user = user
    @place = place
  end

  def index?
    false
  end

  def show?
    user
  end

  def create?
    user
  end

  def update?
    admin?
  end

end

