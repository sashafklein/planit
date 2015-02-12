class UserPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user, @record = user, record
  end

  def show?
    user
  end

  def places?
    user
  end

  def guides?
    user
  end

  def inbox?
    record == user
  end

  # def update?
  #   admin?
  # end

  # def edit?
  #   update?
  # end

  # def destroy?
  #   admin?
  # end

end

