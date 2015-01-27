class ItemPolicy < ApplicationPolicy
  attr_reader :user, :item

  def initialize(user, item)
    @user = user
    @item = item
  end

  def record
    item
  end

  def show?
    item.published? ? user : admin? || owns?
  end

  def create?
    user
  end

  def new?
    create?
  end

  def update?
    admin? || owns?
  end

  def edit?
    update?
  end

  def destroy?
    admin? || owns?
  end

end

