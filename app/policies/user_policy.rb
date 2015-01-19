class UserPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def index?
    false
  end

  def show?
    true
    # scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    false
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

