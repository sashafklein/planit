class ItemPolicy < ApplicationPolicy
  attr_reader :user, :item

  def initialize(user, item)
    @user = user
    @item = item
  end

  def index?
    false
  end

  def show?
    if @item.private == true
      @user.admin? || @user.items.include?(@item)
    else
      true
    end
    # scope.where(:id => record.id).exists?
  end

  def create?
    @user?
  end

  def new?
    create?
  end

  def update?
    @user.admin? || @user.items.include?(@item)
  end

  def edit?
    update?
  end

  def destroy?
    @user.admin? || @user.items.include?(@item)
  end

end

