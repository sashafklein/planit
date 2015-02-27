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
    member?
  end

  def create?
    member?
  end

  def update?
    admin?
  end

end

