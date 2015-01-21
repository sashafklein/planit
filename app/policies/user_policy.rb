class UserPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user, @record = user, record
  end

  def show?
    user
  end

  def bucket?
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

