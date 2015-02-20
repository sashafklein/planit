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
    item.published? ? member? : admin? || owns?
  end

  def create?
    member?
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

