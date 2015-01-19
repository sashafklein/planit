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
    true
  end

  def create?
    @user?
  end

  def new?
    create?
  end

  def update?
    @user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    @user.admin?
  end

end

